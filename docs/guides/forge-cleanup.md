# forge-cleanup

Interactive one-shot maintenance that removes stale forge development artefacts — scratch files in `/tmp/`, unused worktrees, uncommitted changes, untracked files, and local feature/fix/chore/hotfix branches with no upstream. Asks the user before every removal.

## When to load

- "clean up forge" / "forge cleanup" / "clean stale artefacts"
- Before starting a new forge session to clear old worktrees and branches
- After a PR merge to remove the merged feat branch and its worktree
- When `git status` shows clutter or `.worktrees/` has accumulated directories

## How it works

1. **Detect candidates** — runs five detection commands in sequence (see `skills/forge-cleanup/SKILL.md:15-40`):
   - Scratch files: `ls /tmp/pr-review-*.md /tmp/resolve-*.md /tmp/review-*.diff /tmp/forge-*.md /tmp/*.loop.out 2>/dev/null`
   - Stale worktrees: iterates `.worktrees/*/`, checks if branch is unmerged to `main` and not on `origin`
   - Uncommitted changes: `git status --porcelain`
   - Untracked files: `git ls-files --others --exclude-standard`
   - Local branches: `git for-each-ref` filtered for `feat/*`, `fix/*`, `chore/*`, `hotfix/*` with no upstream, excluding current branch

2. **Ask per candidate** — for each match, prints `Found: <type> <path-or-name>` and prompts `Remove it? [y/N] >`. Only `y`/`Y` proceeds.

3. **Act on confirmed removals** — executes the matching command from `skills/forge-cleanup/SKILL.md:45-52`:
   - Scratch file → `rm -f <path>`
   - Stale worktree → `git worktree remove <path> --force` then `git branch -D <branch>` if still local
   - Uncommitted changes → `git checkout -- <path>` (file) or `git reset --hard HEAD` (repo, asks again)
   - Untracked file → `rm -f <path>`
   - Local branch → `git branch -D <branch>`

4. **Final pull** — `git checkout main && git pull`, then reports summary with counts and current commit SHA.

## Files in this skill

- `skills/forge-cleanup/SKILL.md` — Main skill definition with detection commands, confirmation flow, removal actions, and boundary rules.

## See also

- **forge** — Orchestrator that creates the worktrees and branches this skill cleans up; defines the `.worktrees/` layout and branch naming (`feat/`, `fix/`, etc.) at `skills/forge/SKILL.md:100-115`.
- **using-git-worktrees** — Manages worktree creation/removal referenced by forge's Work phase; cleanup uses `git worktree remove` directly.
- **subagent-driven-development** — Owns the parallel worktree workflow that produces the artefacts forge-cleanup targets.

## Notes

- The skill sets `disable-model-invocation: true` — it runs as a pure shell workflow, no LLM calls.
- Detection for stale worktrees checks `git merge-base --is-ancestor "$BRANCH" main` (unmerged) AND `git branch -r --contains "$BRANCH"` (not on origin); if both true, the worktree is offered for removal.
- Current branch is explicitly protected in the branch detection `awk` filter (`$1 != "'"$(git branch --show-current)"'"`).
- No `--yes` flag bypass exists; the skill is interactive by design per `skills/forge-cleanup/SKILL.md:75-76`.