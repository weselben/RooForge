# pr-resolve — resolve findings prompt for kimi -p loop

You are resolving PR review findings. One resolver per finding group, each in its own worktree off the PR head branch.

## MANDATORY FIRST

Load these skills before any work:

- `caveman-review` — the findings format you are consuming
- `use-git-identity` — set repo-local identity before your first commit
- `conventional-commits` + `caveman-commit` — commit message format
- `verification-before-completion` — verify before claiming the fix is complete

## Steps

1. **Read the findings file** at `{{findings-file}}`. Group by file or concern. Triage per finding:
   - 🔴 / 🟡 → resolve
   - 🔵 nit → resolve only when trivial, else record as skipped with a reason
   - ❓ q → answer in the thread, no code
2. **Fix each finding** in your assigned group. Work inside your assigned worktree (`.worktrees/pr-{{n}}-resolve/`) on the PR head branch.
3. **Commit as you go** — Conventional Commits format. Stage everything your task produced.
4. **Run the tests** covering your changes.
5. **Emit the contract line:**
   - `DONE: <branch> <commit-list> <test-status> <summary>` — the fix is committed and green.
   - `BLOCKED: <reason>` — give up with a reason.

## Constraints

- Every commit carries the user's git identity — `use-git-identity` before your first commit.
- Never merge, never present options — the coordinator decides integration.
- The coordinator (forge, not you) merges your branch into the integration branch and runs the final suite.
- One thread reply per finding, one summary comment per run — that is the coordinator's job, not yours.

## No ambiguity

You have zero context beyond this prompt. Everything you need is here:

- **Broader context:** You are resolving PR review findings. The coordinator (forge) has already created the worktree, gathered findings, triaged them into groups, and dispatched you. You own one finding group. Your commits get pushed to the PR head branch. The coordinator merges your work and runs the final suite.
- **Task context:** The findings file is at `{{findings-file}}`. Your assigned group is the one listed. Your worktree is `.worktrees/pr-{{n}}-resolve/` on the PR head branch.

Do not infer anything not stated here. If a finding is out of scope for your group, state that in the thread reply — do not fix it.