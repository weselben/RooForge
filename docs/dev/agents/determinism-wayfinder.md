# Determinism sampling — wayfinder

Sampling pass per ADR 0004. Raw stdout at `.tmp-determinism/logs/wayfinder.log` (gitignored).

## Sample

- **Task:** chart mode for "plan a payment idempotency effort"; produce Destination, Notes, first 3 tickets, and the judgment-vs-mechanical split.
- **Run:** `kimi -p` on 2026-08-18T01:30:53Z, exit 0, 122 lines.
- **Outcome:** model produced a clean destination one-liner, a notes line naming the right skills, three ticket titles with `wayfinder:<type>` labels (one `research`, two `grilling`), and a precise split of judgment vs mechanical phases.

## Observed meta-decisions

- Walked steps 1–6 of chart mode, including the "stop here" boundary (correctly did not pretend to resolve).
- Made a **real** meta-decision on ticket typing: chose `research` for the survey ticket because it unblocks the two `grilling` tickets — the model articulated the blocking relationship in plain prose.
- Labeled the **destination** as judgment (correct), the **frontier slicing** as judgment (correct), the **tracker ops** (label create, issue create, sub-issue wire, blocked_by wire, assign claim) as mechanical (correct).
- Did **not** modify files.

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Name the destination (grilling + domain-modeling) | high — shapes the whole map | none | **keep-as-model** — ADR 0005 #5 explicitly lists chart-mode grilling and fog graduation. | output: one-line destination string; gate: passes the "two-minute elevator pitch" check. |
| 2 | Map the frontier (breadth-first grilling) | high — what's sharp vs fog, what slices to ticket now | none | **keep-as-model** — fog graduation is in ADR 0005 #5. | output: list of sharp questions + list of fog patches. |
| 3 | Create the map issue (label `wayfinder:map`, body template) | none — template fill | full | **MCP `forge_mcp.create_map(repo, title, body)`** — typed body parts (`destination`, `notes`, `decisions[]`). | input: `repo`, `title`, typed body parts; output: `{number, url}`; gate: label applied. |
| 4 | Run `setup-repo-gh-cli.sh` to create `wayfinder:*` labels | none — shell script | full | **shell script** as-is; idempotent per its own contract. | exit 0 if labels exist or are created. |
| 5 | Create tickets (one per sharp question) as child issues | ticket-body content is judgment | issue-creation + label application + sub-issue wiring (two-pass) | **MCP `forge_mcp.create_ticket(repo, parent_number, title, type, body)`**; type drives the `wayfinder:<type>` label. | input: typed; output: `{number, url}`; gate: sub-issue relationship present. |
| 6 | Wire blocking in a second pass (needs ids) | none — `gh api .../dependencies/blocked_by` | full | **MCP `forge_mcp.add_blocking(repo, blocked_number, blocker_numbers[])`** — native issue dependencies. | input: `repo`, `blocked`, `blocker[]`; output: `{added: number[]}`; gate: each dependency recorded. |
| 7 | Claim first ticket (assign-self) | none — `gh issue edit --add-assignee @me` | full | **MCP `forge_mcp.claim(repo, issue_number, assignee)`** — typed claim. | input: `repo`, `number`, `assignee`; output: `{ok: bool}`; gate: assignee field equals caller. |
| 8 | Dispatch one `deep-research` subagent per research ticket | homogeneous fan-out over ticket titles | full dispatch shape | **AgentSwarm `{{item}}`** — `prompt_template` with one research subagent per item, ticket title as `{{item}}`. | input: list of ticket titles + bodies; output: per-ticket report file; cap 10 parallel. |
| 9 | Resolve a ticket (work-through-map path, separate session) | high — which finding wins, what the answer is | none | **keep-as-model** — the resolve path is the same judgment as the chart path; ADR 0005 keeps it. | output: resolution comment + close + Decisions-so-far append. |
| 10 | Append context pointer to map's Decisions-so-far | none — fixed body shape | full | **MCP `forge_mcp.append_decision(repo, map_number, gist, ticket_number)`** | input: typed; output: `{comment_id}`; gate: comment visible on map issue. |
| 11 | "Stop" boundary after chart | none — rule, not a call | full | **skill invariant**, no replacement. | n/a. |

## Notes

- The **chart-mode judgment** is concentrated in steps 1, 2, 5 (ticket body content) and 9 (resolve). Everything else is tracker ops, dispatch, or invariant.
- The observed output suggested **two real MCP opportunities** the SKILL.md does not yet call out: typed `create_map` (current body is a markdown blob) and typed `append_decision` (current is a raw `gh issue comment`).
- The `setup-repo-gh-cli.sh` label script is already deterministic; no work needed.
- Research subagent dispatch is a textbook AgentSwarm case (homogeneous fan-out, `{{item}}` over ticket list).