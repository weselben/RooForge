# Determinism sampling — git-issue-tracker

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/git-issue-tracker.log` (gitignored).

## Sample

- **Task:** dry-run the exact `gh` commands to create a `wayfinder:research` child ticket on map #31 titled "T5 survey MCP servers for GitHub"; identify always-same commands vs judgment inputs. No writes. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:29:38Z, exit 0, 59 log lines (incl. model reasoning).
- **Outcome:** model produced the five-step command sequence (create → database-id lookup → sub_issues wiring → blocked_by skip → claim) verbatim from the skill, and correctly skipped step 4 (no blocker specified).

## Observed meta-decisions

- Read `skills/git-issue-tracker/SKILL.md` first.
- Followed the skill's own distinction between `#number` and database id — explicitly flagged "number ≠ database id" before the sub_issues call.
- Skipped the `blocked_by` call with a reason ("no blocker specified") — a conditional the skill enumerates.
- Treated owner/repo as a placeholder (`<owner>/<repo>`) rather than guessing — correct dry-run behaviour.
- Did **not** execute any `gh` command (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Create issue (`gh issue create --title --body --label`) | low — title/body/label inputs vary | full — command shape fixed | **MCP tool `forge_mcp.issue_create(title, body, labels)`** — typed wrapper over `gh`. | input: title, body, labels; output: `{number, url}`. |
| 2 | Database-id lookup (`gh api ... --jq .id`) | none | full — fixed | **MCP tool** — folded into every op that needs an id. | input: issue number; output: database id. |
| 3 | Sub-issue wiring (`POST .../sub_issues`) | none | full — fixed endpoint | **MCP tool `forge_mcp.sub_issue_add(map, child)`**. | input: map number + child number; output: success. |
| 4 | Blocking wiring (`POST .../dependencies/blocked_by`) | low — whether it applies | full — fixed endpoint | **MCP tool `forge_mcp.blocked_by_add(blocked, blocker)`**; skip-when-none is a caller rule. | input: two issue numbers; output: success. |
| 5 | Frontier query (open children, drop blocked/assigned, first in map order) | none | full — fixed pipeline | **MCP tool `forge_mcp.frontier(map)`** — pure composition of reads + filter rules. | input: map number; output: `{frontier: [numbers]}`. |
| 6 | Claim (`--add-assignee @me`) | none | full — fixed | **MCP tool `forge_mcp.claim(number)`**. | input: issue number; output: success. |
| 7 | Resolve (comment + close + map Decisions-so-far append) | low — the answer content is judgment | command shapes fixed | **MCP tool `forge_mcp.resolve(number, answer)`** for the mechanics; the answer text stays model-authored. | input: number + answer; output: success. |
| 8 | Branch association (slug derivation, `## Feat branch` pointer, fallback lookups) | none | full — fixed rule chain | **MCP tool `forge_mcp.map_branch(map)`** — three-step lookup exactly as specified. | input: map number; output: branch name or none. |
| 9 | Title/body/label content | high — wording | label enum is fixed | **keep-as-model** for wording; label pick is a fixed enum (`wayfinder:research` etc.). | input: ticket nature; output: label from enum. |

## Notes

- Git-issue-tracker is a **pure adapter**: every operation is a fixed `gh` invocation with typed inputs. The sample confirms it — the model's entire contribution was plugging in values and skipping an inapplicable step.
- This is the single strongest MCP candidate in the skill set: every row of the seam table except #9 (content wording) maps 1:1 to a typed tool. ADR 0005's "tracker/infra → MCP" policy was written for exactly this skill.
- The `number ≠ database id` trap is precisely the kind of thing a typed tool eliminates permanently — the tool should accept the human-facing number and do the lookup internally.
- The frontier query (step 5) deserves special attention for wayfinder: it is the map's core read operation and is fully deterministic — a natural first tool for `forge-mcp`.