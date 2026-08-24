# ADR 0005: Mechanism assignment policy — three types, MCP-first

Status: Accepted (supersedes 2026-08-18 version)
Date: 2026-08-24 (supersedes)
Decision Makers: weselben + agent

## Context

ADR 0005 (2026-08-18) committed to a five-mechanism palette: MCP tool,
Node (.js) wrapper, AgentSwarm, loops (migrated to Node), and keep-as-model.
The T3 mechanism matrix lock (issue #34) reduced that palette to three
types. The reductions came from T3 wave 1 (MCP-only collapse), T3 wave 2
(hard honesty gates folded into MCP tools), and the per-skill assignments
in `docs/dev/agents/determinism-seams-summary.md` cross-checked against
the T2 user reviews (issue #33).

The remaining decision is to encode the reduced palette into policy so
that future step decisions stop re-litigating the same trade-offs.

## Decision

Per-step mechanism assignment follows this fixed three-type policy:

### Type 1: MCP tool on `forge-mcp`

All infrastructure, tracker, file-system, git, scanner, linter, and
wrapper operations are typed tools on `forge-mcp`. **Not shell scripts;
not standalone Node wrappers; not separate Python helpers.** Reasons:

- Hidden inputs (database ids, dependency wires, job queue ids) belong
  in typed tool calls, not in skill prose.
- Cross-skill reuse (label setup, frontier query, claim, resolve,
  commit-message linter, worktree creation, identity setup, verify)
  is consolidated in one server.
- Hard honesty gates (T3 wave 2) are MCP server responsibilities — the
  server is the only place where the audit log, the gate, and the typed
  error with remediation guidance can live.
- The forge-mcp job queue (T3 wave 3, in-process + sqlite at
  `${XDG_STATE_HOME:-~/.local/state}/forge-mcp/jobs.db`) needs the
  server's process boundary to enforce atomic claim via map-aware
  session tracking (T18 trust model).
- Per-repo dynamic tools declared in `.forge/mcp_tools.yaml` (T18) let
  the server register only what the current repo uses — no bloat in
  LLM context.

**Specific folded-in sub-features** (previously separate mechanisms):

- **Shell scripts** — folded into MCP tools. No standalone `.sh`
  scripts for pipeline operations after this ADR.
- **Standalone Node wrappers** for `kimi -p` — folded into
  `forge_mcp.run_loop` (T4 prototype, rescoped by T3 wave 1).
- **Linters** — exposed as `forge_mcp.lint(text, ruleset)` with a
  fixed ruleset catalog (`conventional-commits`, `caveman`,
  `ste100`, `frontend-design-ai-defaults`, `verification-honesty`,
  etc.). One tool, many rulesets.
- **Harness-class deterministic behaviours** (auto-load always-on
  skills, slash-command mode parsing, plan-mode approval gate) —
  remain in the harness. No MCP surface needed; the harness already
  enforces them.

### Type 2: AgentSwarm builtin

Parallel subagent fan-out uses the harness's native AgentSwarm with
`{{item}}` templates. **Not a custom dispatcher; not a different
mechanism.** T1 sampling found AgentSwarm is the canonical fan-out
across 8 skills (cross-cutting finding #5). Per-skill callers go
through `forge_mcp.spawn` (T2-E), which is a thin shim over AgentSwarm
adding audit logging, ticket reservation, and flow-prefix injection —
the underlying dispatch mechanism stays AgentSwarm.

### Type 3: Keep-as-model

Genuine judgement steps stay model-driven, with a stated rationale.
The keep-as-model residue is uniform across all 35 sampled skills
(T1 matrix): naming and summarizing (commit subjects, PR TL;DRs,
destinations), slicing and decomposition (vertical slices, design
trees, domains), prioritization and proportionality, creative and
design choices. **No new judgement categories.** Anything not in this
list is over-reach and should re-route to Type 1 or Type 2.

### Linter and harness as dynamic sub-features

Linters and harness-class behaviours are **not** new mechanism types.
They are dynamic sub-features:

- **Linters** live in MCP under `forge_mcp.lint({text, ruleset})`. Per
  ruleset is a script loaded from `skills/<skill>/linters/` or
  bundled in `forge-mcp`'s default catalog. Same Type 1 server,
  different tool.
- **Harness-class** behaviours (auto-load, slash-command parse, plan
  approval gate) stay in the harness. They require no MCP surface
  and no wrapper.

### Skill collapse, carefully

When T1/T3 analysis shows a skill's entire work collapses to one or
a few tool calls, the skill may be deleted and replaced. The collapse
is **never blanket** — each candidate earns its collapse via the T2
user review (issue #33). Once approved, the skill folder becomes
docs-only (`SKILL.md` + `templates/` + `tests/` where relevant), or
is deleted entirely. Locked collapses from T2 (proposals, awaiting
user sign-off):

- `dispatching-parallel-agents` → docs-only (T2-E shim in MCP).
- `use-git-identity` → docs-only (`forge_mcp.git_identity` does the work).
- `subagent-driven-development` → fold candidate (T2-J-adjacent).
- `loops` → docs + templates + smoke tests; executable in
  `forge_mcp.run_loop` (T2-J).
- `verification-before-completion` → docs-only (skill enforces honesty
  invariants as rules; tool enforces them as gates via Type 1 modes).
- `forge-cleanup`, `forge-init`, `forge-setup`, `forge-docs`
  (folder-setup part) → MCP tools (`forge_mcp.init_repo`,
  `forge_mcp.cleanup_repo` per T2-D).
- `git-issue-tracker` → docs-only; all ops go through `forge_mcp.tracker.*`.
- `forge-flow` → folded into systemprompt field + flow-prefix scheme
  (T2-G); no skill folder.

The collapse list is open — T3 matrix lock is the moment these become
binding. Until then, the skill folder survives even if its work has
moved to MCP.

### Shared premade-prompt templates

Templates live in `skills/loops/templates/` for shared ones (review-loop,
resolve-loop, commit-message, grill-loop), with per-skill custom parts in
`skills/<skill>/templates/` where the skill keeps a docs-only folder.

## Consequences

**Positive**
- Three types, applied mechanically — step decisions stop being debates.
- The MCP-first collapse shrinks the pipeline's custom surface (no shell
  scripts, no standalone wrappers, no separate linter binaries).
- Skill collapse path gives a concrete route to less bloat (T2 answer
  pattern).
- Template homes are fixed, so new premade prompts have an obvious
  place to live.

**Negative**
- Some steps will sit awkwardly on a boundary (e.g. a mostly-judgement
  operation with one typed-output need). The T3 matrix lock adjudicates
  these case by case.
- Committing to MCP-first means every new infra op needs a forge-mcp
  PR — but that's the cost of typed I/O and audit logging.
- The keep-as-model residue is small (T1 found it ~30% of seams) but
  irreducible — judgement stays judgement.

**Risks**
- Over-eager collapse could delete a skill whose prose carries
  subtle judgement the sampling pass missed. Mitigation: each collapse
  is a T2 ticket with HITL user approval, plus the per-skill artifacts
  in `docs/dev/agents/determinism-<skill>.md` document the rationale.

## Related

- Wayfinder map: issue #31
- Tickets: #33 (T2 surface proposal, spawned #85–#94 for sub-decisions),
  #34 (T3 mechanism matrix lock)
- ADR 0004 (sampling criterion), ADR 0006 (forge-mcp), ADR 0007
  (loops migration — now rescoped: skill folder survives as docs +
  templates, executable folds into `forge_mcp.run_loop`)
- ADR 0008 (OpenAI-compat endpoint — Deferred)
- T7 (#38, verify tool), T18 (#83, trust model)