---
name: git-issue-tracker
description: Issue-tracker integration point for git-tracked repos. Premade with GitHub operations (gh CLI — native sub-issues for parent/child, native blocked_by dependencies for blocking, frontier queries). Load whenever a skill or workflow (e.g. wayfinder) needs to publish to, read from, or wire relationships on the repo's issue tracker. Replace the operations below if your tracker isn't GitHub.
---

# Issue tracker

This skill is the **tracker integration point** for any workflow that needs to talk to the repo's issue tracker (wayfinder, triaging, etc.). It is **premade with GitHub operations** — swap the body for Jira / Linear / a local-markdown tracker as needed; keep the headings so consuming skills keep working.

The GitHub operations below are adapted from [mattpocock/skills — issue-tracker-github.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md), with endpoint details verified against the live API.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies (backticks in inline `--body` strings get eaten by shell expansion).
- **Read an issue**: `gh issue view <number> --comments`.
- **List issues**: `gh issue list --state open` with `--label` filters as needed.
- **Comment**: `gh issue comment <number> --body "..."`.
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."` (create labels first with `gh label create` — editing with a nonexistent label fails).
- **Close**: `gh issue close <number> --comment "..."`.
- **Numeric database id**: several endpoints below need the issue's database id, _not_ its `#number` or `node_id`: `gh api repos/<owner>/<repo>/issues/<number> --jq .id`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.

## Wayfinding operations

Used by the wayfinder skill. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Destination / Notes / Decisions-so-far / Fog body. `gh issue create --label wayfinder:map`.

- **Child ticket**: an issue linked to the map as a **native GitHub sub-issue** — do this, don't just mention `#1` in the body:

  ```bash
  gh api repos/<owner>/<repo>/issues/<map-number>/sub_issues \
    -F sub_issue_id=<child-database-id>
  ```

  The map's children are then queryable via `gh api repos/<owner>/<repo>/issues/<map-number>/sub_issues --jq '.[].number'` and render as sub-issues in the GitHub UI. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`/`domain-modeling`). Once claimed, the ticket is assigned to the driving dev.

- **Blocking**: GitHub's **native issue dependencies** — the canonical, UI-visible representation:

  ```bash
  gh api --method POST repos/<owner>/<repo>/issues/<blocked-number>/dependencies/blocked_by \
    -F issue_id=<blocker-database-id>
  ```

  Read a ticket's blockers via `gh api repos/<owner>/<repo>/issues/<number>/dependencies/blocked_by --jq '.[].number'` (and the reverse via `.../dependencies/blocking`). Prefer these dedicated endpoints over the `issue_dependencies_summary` field on the issue object, which can lag right after a write. A ticket is unblocked when every blocker is closed.

- **Frontier query**: list the map's open children via the sub-issues endpoint above, drop any with an open blocker (from `dependencies/blocked_by`) or an assignee; first in map order wins.

- **Claim**: `gh issue edit <number> --add-assignee @me` — the session's first write.

- **Resolve**: `gh issue comment <number> --body "<answer>"`, then `gh issue close <number>`, then append a context pointer (gist + link) to the map's Decisions-so-far.
