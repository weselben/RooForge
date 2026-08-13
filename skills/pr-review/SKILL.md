---
name: pr-review
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/pr-review/SKILL.md
description: "Review a GitHub PR or local branch inside a worktree — hard-rule validation, then a kimi -p review loop producing caveman-review findings. PR mode posts ONE review under the authenticated user's identity; local mode returns findings. Triggers: \"review this PR\", \"review <repo>#<n>\", \"PR review\", \"review branch <name>\"."
---

# pr-review — worktree-isolated PR review

Two phases: **validate** (deterministic hard rules) then **review** (a `kimi -p` loop producing caveman-review findings). Everything inside a worktree — main checkout never touched. Framework- and language-agnostic.

**Leading word: validate-then-review.** Hard rules first (no LLM), then the loop.

Two modes, picked by the first arg to `scripts/review-loop.sh`:

- **PR mode** (target = `owner/repo#n`) — full pipeline: validate → review → post → handoff. The remote PR is the source of truth; `pr-resolve` reads it.
- **local mode** (target = branch or slug) — review only. Findings land in a scratch file for the calling orchestrator's fix loop.

## Steps

1. **WORKTREE** — `using-git-worktrees` Step 0. If already isolated on PR head, stay. Otherwise read PR head metadata (`gh pr view <n> --json headRefName,headRefOid`) and create `.worktrees/pr-<n>-review/` on a branch tracking PR head.
2. **VALIDATE** — `scripts/validate.sh <diff-file>` where `<diff-file>` comes from `gh pr diff <n>`. Hard rules only: secret patterns, diff sanity. Every `FAIL:` becomes a 🔴 finding.
3. **REVIEW** — `scripts/review-loop.sh <pr-ref> <worktree> [max_iter]`. Renders `scripts/templates/review-loop.md` via `../loops/scripts/cavemanize.sh`, drives `../loops/scripts/run_loop.sh`. Reviewer loads `caveman-review`; writes findings to `${TMPDIR:-/tmp}/pr-review-<n>.md` — scratch, never committed.
4. **POST** — submit ONE review with inline comments:
   - Get head SHA: `HEAD_SHA=$(gh pr view <n> --json headRefOid --jq '.headRefOid')`
   - Submit review with inline comments via `gh api repos/{owner}/{repo}/pulls/<n>/reviews --method POST` (passes inline comments in JSON `comments[]` array: `{path, line, side: "RIGHT", body}` for each finding). The top-level review body holds the summary; inline comments appear as line-anchored annotations in the GitHub UI Files tab.
   - Author identity from `gh api user -q .login` (weselben on this host) — never bot, never agent self-branding.
   - Fallback when `gh pr review` doesn't accept inline payload: post top-level `gh pr review <n> --comment --body-file <scratch-file>` plus a `gh api repos/{owner}/{repo}/pulls/<n>/comments` per finding for inline visibility.
   - Group findings by file. Delete scratch file after.
5. **HANDOFF** — report: review URL, counts by severity, next step (`pr-resolve` for 🔴/🟡). Run `using-git-worktrees` cleanup on the review worktree.

**Done when:** review URL returned (with inline comments visible in the PR Files tab), scratch file deleted, worktree removed.

## Scripts — `scripts/`

| Script | Role |
|---|---|
| `scripts/validate.sh <diff-file>` | Hard-rule pass: secret patterns, diff sanity on added lines only. Prints `PASS:`/`FAIL:`; exit 0 always. |
| `scripts/review-loop.sh <target> <worktree> [max_iter]` | Renders `templates/review-loop.md` via `../loops/scripts/cavemanize.sh`, drives `../loops/scripts/run_loop.sh`. |
| `scripts/templates/review-loop.md` | The `kimi -p ""` payload: MANDATORY FIRST skill loads, no-plan-mode, mode-aware diff reading, `DONE:`/`BLOCKED:` contract. |

## Hard rules

- Reviews run inside a worktree. Reviewer subagent that never entered one is a process violation.
- Reviewer never modifies code. Findings only; fixes are `pr-resolve`'s job.
- ONE review per run. All findings in a single `gh pr review --comment` body.
- Posted review is the source of truth. Findings never committed; scratch lives outside tree.
- `kimi -p` machinery (cavemanize, run_loop, status contract) lives in `loops` — load it.
- Comment format lives in `caveman-review` — load it.
- Public GitHub text — everything posted — goes through `ste100`.

## Boundaries

- Does not approve or request-changes — `--comment` reviews only; verdict is the user's.
- Does not fix findings — that is `pr-resolve`.
- Does not replace CI — `validate.sh` is hard rules, not a build.