# ADR 0006: Build `forge-mcp` — a custom MCP server for tracker operations

Status: Accepted (amended 2026-08-24)
Date: 2026-08-18 (original) · 2026-08-24 (amended)
Decision Makers: weselben + agent

## Context

Tracker operations in the forge pipeline (label setup, map/ticket CRUD,
sub-issue wiring, native blocking, frontier queries, claim, resolve,
branch association) are currently prose-described `gh` commands inside
`skills/git-issue-tracker/SKILL.md`. Every skill that touches the tracker
re-derives these commands from prose — model judgment applied to what
is fundamentally a typed API surface.

ADR 0005 assigns tracker/infra operations to an MCP server. No MCP
server exists in the pipeline today (only the peripheral
`mcp/pdf-curl-server.*` for docs fetching).

The 2026-08-24 amendment adds: (a) the trust model locked in T18
(#83), and (b) the timeout-estimator deferral note from T3 wave 4
(ADR 0008 endpoint is Deferred; the estimator that called it has no
upstream).

## Decision

Build **`forge-mcp`**, a custom MCP server exposing tracker operations
and the full Type 1 surface from ADR 0005 as typed tools. The exact
tool surface is proposed from the T1 sampling findings (issue #32),
reviewed line-by-line by the user (issue #33), and only approved
entries are built. This decision commits to the server's existence and
its trust model; tool-by-tool approval lives in T2 → T6.

### Trust model (added 2026-08-24, from T18 #83)

- **Repo auto-detection**: `forge-mcp` reads the current working
  directory, detects the git remote's owner/repo, and scopes tool
  surface + audit log to that repo. No global config required.
- **Per-repo dynamic tools**: declared in
  `.forge/mcp_tools.yaml` at the repo root. When the file is
  absent, the corresponding tools are unregistered on the fly — no
  bloat in LLM context. The default catalog (cross-skill shared
  tools) is always available.
- **Auth**: reuses the existing `gh auth status` token. No new
  credential surface. Tool calls that hit the GitHub API go through
  the same authenticated `gh` process the agent would have used.
- **Audit log split**:
  - Local write tools (issue create, label add, blocking wire, etc.)
    → `/tmp/forge-mcp/audit.jsonl`.
  - Remote upstream LLM requests (for the proposed but Deferred
    `/v1/chat/completions` endpoint — see ADR 0008) →
    `/var/log/forge-mcp/upstream.log`. Even with the endpoint
    deferred, the path is reserved so re-lighting ADR 0008 doesn't
    require new paths.
- **Atomic claim via map-aware session tracking**: forge-mcp owns a
  sqlite database at
  `${XDG_STATE_HOME:-~/.local/state}/forge-mcp/jobs.db`. Each agent
  reserves a ticket with its `kimi -p` session id when starting work;
  no two agents can claim the same ticket. The reservation releases
  on close or on stale-session timeout (default 30 min, configurable
  per repo).

### Timeout estimator (deferred with ADR 0008)

T3 wave 4 specified `forge_mcp.estimate_timeout(task_profile)` to
size job timeouts via the ADR 0008 OpenAI-compat endpoint. ADR 0008
is **Deferred** (2026-08-18); the endpoint is not live. Until ADR
0008 reactivates or a different mechanism lands, timeout sizing is
**caller-passed only** — `forge_mcp.run_loop({timeout_ms})` and
`forge_mcp.spawn({timeout_ms})` accept a `timeout_ms` integer;
absence → 5 min default. The estimator tool is reserved in name
(`forge_mcp.estimate_timeout`) but unimplemented; callers must not
rely on it. When ADR 0008 reactivates, the estimator ships in the
same release that lights the endpoint.

### Job queue (added 2026-08-24, from T3 wave 3)

forge-mcp owns a job queue backed by sqlite at
`${XDG_STATE_HOME:-~/.local/state}/forge-mcp/jobs.db` (same file as
the trust-model DB). Job lifecycle:

1. Caller invokes `forge_mcp.run_loop({template, inputs, ...})` or
   `forge_mcp.spawn({...})`.
2. Server enqueues a job with status `queued`, returns `{job_id}`.
3. Server worker pool drains the queue, transitions to `running`.
4. On completion, `completed` + result; on error, `failed` + typed
   error.
5. On stale-session timeout (configurable per repo), `abandoned`.

The queue is in-process + sqlite; no separate worker daemon.
Cross-process coordination uses sqlite's WAL mode. The queue survives
forge-mcp restarts; abandoned jobs are re-queued once.

### Tool surface

Approved from T2 (#33) → built in T6. First tool set covers:

- `forge_mcp.tracker.*` — issue CRUD, label setup, sub-issue wiring,
  blocking, frontier, claim, resolve, branch association.
- `forge_mcp.git_identity` — read resolved identity + coauthor (T2-H).
- `forge_mcp.init_repo` / `forge_mcp.cleanup_repo` — repo setup +
  cleanup (T2-D).
- `forge_mcp.git_diff` / `forge_mcp.git_commit` — commit-message
  pipeline (T2-C).
- `forge_mcp.run_loop` — template render + `kimi -p` + contract
  loop (T2-C, T2-J). Feasible as designed (Node port of `run_loop.sh`
  inside forge-mcp; job queue + `timeout_ms` + audit all fit).
- `forge_mcp.spawn` — **headless `kimi -p` fan-out executor** (T2-E
  amended 2026-08-24). NOT an AgentSwarm shim — MCP cannot wrap
  AgentSwarm (in-process harness primitive). `spawn({template, items[],
  work_dir, timeout_ms})` → N parallel child kimi processes through the
  job queue. Main chat remains master orchestrator. Loses:
  secondary-model pool, in-process startup, `resume_agent_ids`.
  Recursion guard: `FORGE_MCP_DEPTH` env marker.
- AgentSwarm stays harness-native (main chat). For resume/pool cases
  (SDD fix loops, deep-research refinement), AgentSwarm dispatches stay
  inside the harness; optional `forge_mcp.session_reserve` /
  `session_release` sidecars wrap the call for audit.
- `forge_mcp.lint({text, ruleset})` — generic linter with ruleset
  catalog.
- `forge_mcp.verify({mode, target})` — single tool with modes
  (evidence / spec_drift / coverage / docs_alignment / all) (T2-I,
  supersedes T7's narrow signature).
- `forge_mcp.detect_map(repo)` / `forge_mcp.find_feat_branch` —
  map+branch lookup.
- `forge_mcp.record_adr` / `forge_mcp.open_adr_pr` — domain-modeling
  automation (T2-F).
- `forge_mcp.worktree_create` / `forge_mcp.merge_state` /
  `forge_mcp.merge_resolve` — worktree + merge utilities.

Server registration follows the existing `mcp/*.sh` / `mcp/*.ps1`
launcher convention. Audit log rotation handled by `logrotate` or
equivalent on the host.

## Consequences

**Positive**
- Typed I/O replaces prose-derived `gh` invocations; hidden inputs
  (database ids) stop being model-managed.
- One server consolidates what was scattered across skill bodies.
- Trust model (T18) gives every tool call an audit trail and an
  atomic claim guarantee.
- Job queue (T3 wave 3) makes async work first-class — silent
  background blocking the main chat without busy-waiting.
- Deferred tool-surface decision keeps this ADR stable even as the
  surface evolves.

**Negative**
- A new runtime component to install, register, and maintain.
- sqlite at a fixed path is a host prerequisite (satisfied by default
  on Linux/macOS, needs explicit setup on Windows).
- Skills must be re-pointed at the server (follow-up effort, out of
  scope of the map).
- Timeout estimator gap means callers must think about timeouts
  until ADR 0008 reactivates.

**Risks**
- If the T2 review rejects most candidates, the server ships thin and
  the build cost outweighs the benefit. Mitigation: the frontier query
  alone has enough cross-skill reuse to justify the skeleton.
- Audit log growth at `/tmp/forge-mcp/audit.jsonl` and
  `/var/log/forge-mcp/upstream.log` requires a rotation policy;
  default is 100 MB rotated, 5 generations retained.
- The job queue's stale-session timeout is a heuristic; misconfigured
  values either leak abandoned jobs or evict active ones. Default is
  conservative (30 min); per-repo override available.

## Related

- Wayfinder map: issue #31
- Tickets: #33 (T2 surface proposal, awaiting user sign-off),
  #34 (T3 mechanism matrix lock), #37 (T6 build)
- ADR 0005 (three-type policy), ADR 0007 (loops migration — now
  rescoped to docs-only + templates; executable in
  `forge_mcp.run_loop`)
- ADR 0008 (OpenAI-compat endpoint — Deferred; timeout estimator
  unimplemented until ADR 0008 reactivates)
- T7 (#38, verify tool — superseded by `forge_mcp.verify` modes),
  T18 (#83, trust model — encoded here)
- Per-skill artifacts: `docs/dev/agents/determinism-<skill>.md` (T1)