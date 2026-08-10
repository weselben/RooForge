# git-issue-tracker

Issue-tracker integration point for git-tracked repos. Provides pre-made GitHub operations via the `gh` CLI — issue CRUD, native sub-issues for parent/child relationships, native `blocked_by` dependencies, and frontier queries — plus wayfinder-specific operations for map/ticket lifecycle. Designed so consuming skills (wayfinder, triaging) can publish to, read from, and wire relationships on the repo's issue tracker without reimplementing the plumbing. The body is swappable: replace the GitHub commands with Jira, Linear, or a local-markdown tracker while keeping the headings so downstream skills keep working.

## When to load

- A skill or workflow needs to **publish to**, **read from**, or **wire relationships** on the repo's issue tracker.
- **Wayfinder** is active and needs to create maps, child tickets, blocking dependencies, or frontier queries.
- You are starting a session where forge's step 2 (Resolve — work one ticket) will close tickets and append context pointers to the map's Decisions-so-far.
- Any situation where `gh issue` commands appear in another skill's instructions — this skill owns that layer.

## How it works

1. **Basic issue operations** — create, read, list, comment, label, close issues via `gh issue` subcommands. The skill specifies a heredoc for multi-line bodies to avoid shell-expansion issues with backticks (line 16).
2. **Numeric database ID** — some wayfinder endpoints require the issue's database `id`, not its `#number` or `node_id`. Retrieved via:
   ```
   gh api repos/<owner>/<repo>/issues/<number> --jq .id
   ```
3. **Map creation** — a single issue labelled `wayfinder:map` holds Destination / Notes / Decisions-so-far / Fog. Created with `gh issue create --label wayfinder:map`.
4. **Child ticket creation** — child issues are linked to the map as native GitHub sub-issues via the sub_issues endpoint (not by mentioning `#N` in the body):
   ```
   gh api repos/<owner>/<repo>/issues/<map-number>/sub_issues \
     -F sub_issue_id=<child-database-id>
   ```
   Children are queryable via `.../sub_issues --jq '.[].number'` and render in the GitHub UI.
5. **Blocking dependencies** — uses GitHub's native issue dependencies, not a field on the issue object:
   ```
   gh api --method POST repos/<owner>/<repo>/issues/<blocked-number>/dependencies/blocked_by \
     -F issue_id=<blocker-database-id>
   ```
   A ticket is unblocked when every blocker is closed.
6. **Frontier query** — list the map's open children, drop any with an open blocker or an assignee; first in map order wins.
7. **Claim** — `gh issue edit <number> --add-assignee @me` — the session's first write on a ticket.
8. **Resolve** — comment with the answer, close the issue, then append a context pointer (gist + link) to the map's Decisions-so-far.

## Files in this skill

- `SKILL.md` — sole file; contains all conventions, basic GitHub operations, and wayfinder-specific operations (map, child ticket, blocking, frontier query, claim, resolve). 58 lines.

## See also

- **wayfinder** — primary consumer; this skill owns the tracker plumbing that wayfinder uses for map/ticket lifecycle.
- **forge** — orchestrator that invokes wayfinder at step 1 (Map) and resolves tickets at step 2 (Resolve); both steps depend on this skill's operations.
- **conventional-commits** — commit messages follow Conventional Commits when squash-merging resolved tickets into the feat branch.

## Notes

- The skill directory contains only `SKILL.md` (no companion scripts or templates). All logic is declarative — the agent interprets the commands at runtime.
- The `blocked_by` dependency endpoints require the issue's **database id** (not `#number`). The skill calls this out explicitly (line 24) but this is a common footgun if missed.
- The skill explicitly says to prefer the dedicated `dependencies/blocked_by` endpoints over the `issue_dependencies_summary` field on the issue object, which can lag after a write.
- No references to other skills are broken; wayfinder and forge are the two consumers, and both exist in the skills collection.
