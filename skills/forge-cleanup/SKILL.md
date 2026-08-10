---
name: forge-cleanup
description: Remove stale forge artefacts — scratch files, unused worktrees, uncommitted changes, untracked files, local branches. Asks before each removal.
source: local://authored
disable-model-invocation: true
---

# Forge Cleanup

One-shot maintenance. Removes stale forge development artefacts. Asks the user before every removal.

## Steps

### 1. Detect candidates

Collect every stale artefact in the repo:

```bash
# 1. Scratch files (least destructive)
ls /tmp/pr-review-*.md /tmp/resolve-*.md /tmp/review-*.diff /tmp/forge-*.md /tmp/*.loop.out 2>/dev/null

# 2. Stale worktrees
# For each .worktrees/<slug>/ check: branch not merged to main AND branch not on origin
for d in .worktrees/*/; do
  [ -d "$d" ] || continue
  BRANCH=$(cd "$d" && git branch --show-current)
  git merge-base --is-ancestor "$BRANCH" main 2>/dev/null || git branch -r --contains "$BRANCH" 2>/dev/null | grep -q . || echo "$d"
done

# 3. Uncommitted changes (main repo)
git status --porcelain

# 4. Untracked files (main repo)
git ls-files --others --exclude-standard

# 5. Local branches (feat/*, fix/*, chore/*, hotfix/* with no upstream, excluding current)
git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads | awk '$2 == "" && $1 ~ /^(feat|fix|chore|hotfix)\// && $1 != "'"$(git branch --show-current)"'" {print $1}'
```

### 2. Ask per candidate (one at a time)

For each candidate, format and ask:

```
Found: <type> <path-or-name>
Remove it? [y/N] >
```

Only proceed on `y` or `Y`. Skip on anything else. Continue to next candidate.

### 3. Act on confirmed removals

| Type | Command |
|------|---------|
| Scratch file | `rm -f <path>` |
| Stale worktree | `git worktree remove <path> --force` (then `git branch -D <branch>` if branch still local) |
| Uncommitted changes | `git checkout -- <path>` (file-level) or `git reset --hard HEAD` (repo-level — ask again) |
| Untracked file | `rm -f <path>` |
| Local branch | `git branch -D <branch>` |

Log each action: `Removed <type>: <path-or-name>`.

### 4. Final pull

After all confirmed removals:

```bash
git checkout main
git pull
```

Report:
```
Cleanup complete.
Removed: N scratch, N worktrees, N uncommitted, N untracked, N branches
On main at <commit-sha>
```

## Rules

- **One candidate at a time.** Never batch-confirm.
- **Default is NO.** Empty input = skip.
- **Current branch protected.** Never offer to delete the branch the user is on.
- **Worktree branches** — if the worktree branch isn't on `origin`, offer to delete it after removing the worktree.
- **Uncommitted changes** — offer file-by-file first; if many, offer repo-level `reset --hard` as a second question.
- **No auto-confirm.** Even `--yes` flag doesn't bypass; this skill is interactive by design.

## Boundaries

Forge Cleanup does not:
- Touch committed history (no `git rebase`, no `git commit --amend`)
- Push anything (no `git push`)
- Modify remote state
- Delete `main`, `master`, or the current branch
- Touch other users' worktrees

It only removes local stale artefacts the user explicitly confirms.