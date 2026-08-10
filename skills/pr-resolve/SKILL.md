---
name: pr-resolve
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/pr-resolve/SKILL.md
description: "Resolve PR review findings — reads caveman-review findings, dispatches one resolver subagent per finding group into its own worktree, commits under user's git identity, pushes to PR head branch, replies under each review thread with the resolving commit SHA. Triggers: \"resolve review comments\", \"fix PR feedback\", \"address review findings\"."
---

# pr-resolve — turn review findings into pushed commits

`pr-resolve` consumes what `pr-review` produces. Findings in, resolved threads out. Every resolver works in its own worktree off the PR head branch; every commit carries the user's git identity; every resolved finding gets a thread reply naming the commit SHA.

**Leading word: triage.** Each finding becomes resolve / skip / answer — never batched into the summary and left silent.

## Steps

1. **WORKTREE** — `using-git-worktrees` Step 0. If not isolated on PR head, create `.worktrees/pr-<n>-resolve/` tracking PR head.
2. **COLLECT** — gather actionable findings from **inline review comments** (`gh api repos/{owner}/{repo}/pulls/<n>/comments --paginate --jq '.[] | select(.in_reply_to_id == null and .position != null) | {id, path, line, body, user, diff_hunk}'`, unresolved only). Fall back to `docs/reviews/pr-<n>.md` if present. Group by file or concern. Triage: 🔴/🟡 → resolve; 🔵 nit → resolve if trivial else skip with reason; ❓ q → answer in thread.
3. **DISPATCH** — swarm mode, one resolver subagent per group, each in its own worktree off PR head. Driven by `scripts/resolve-loop.sh <findings-file> <worktree> [max_iter]` (kimi -p via `../loops/scripts/run_loop.sh`). Each resolver loads `use-git-identity`, `conventional-commits`, `caveman-commit`, `verification-before-completion`; sets repo-local identity before first commit. Cap 10 parallel.
4. **INTEGRATE** — merge resolver branches into PR-head worktree (`--no-ff`), run test suite on merged result (`verification-before-completion`). Clean + green → continue. Red → one fix round through failing group, then report BLOCKED if still red.
5. **PUSH + REPLY** — push PR head branch. For each resolved inline comment, post a thread reply: `gh api repos/{owner}/{repo}/pulls/comments/<comment-id>/replies -f body="Resolved in <sha> — <one-line what changed>"`. For inline comments skipped with reason or answered ❓ questions, post the corresponding thread reply. **One thread reply per inline comment.** Finish with ONE summary top-level review body listing resolved/skipped/answered counts. Done when every inline thread has exactly one reply and the summary exists. Per the gh-cli output contract, the PR URL is the first line of the user-visible reply as a Markdown link, with the summary comment URL on the second.
6. **CLEANUP** — `using-git-worktrees` cleanup: `git worktree remove` + `git branch -d`. The `-d` refusal on unmerged branches is the safety check.

**Done when:** every thread has one reply, summary comment URL exists, worktrees removed.

## Scripts — `scripts/`

| Script | Role |
|---|---|
| `scripts/resolve-loop.sh <findings-file> <worktree> [max_iter]` | Swarm-mode. Renders `templates/resolve-loop.md` via `../loops/scripts/cavemanize.sh`, drives `../loops/scripts/run_loop.sh`. |
| `scripts/templates/resolve-loop.md` | The `kimi -p ""` payload: MANDATORY FIRST skill loads, worktree confinement, `DONE:`/`BLOCKED:` contract. |

## Hard rules

- Every resolver spawns inside its own worktree off PR head — never main checkout, never shared worktree.
- Commits carry the user's identity (`use-git-identity`, repo-local config) — never `agent`, never bot.
- One thread reply per finding, one summary comment per run. Threads are where the reviewer looks.
- Findings format is `caveman-review`'s contract; loop machinery is `loops`'s. Load both.
- Public GitHub text goes through `ste100`.
- Push goes to PR head branch only. Never main, never a fork the user doesn't own.

## Boundaries

- Does not produce findings — that is `pr-review`.
- Does not resolve findings outside PR scope — out-of-scope gets a thread reply explaining why, not a commit.
- Does not merge the PR — the user merges.