---
name: use-git-identity
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/use-git-identity/SKILL.md
description: Set the git identity (name + email) before any commit, amend, or rebase. Apply repo-local on first commit; use `-c` for one-offs.
---

# Use Git Identity

Every commit on this machine uses one identity — author AND committer:

```
name:  weselben/rooforge
email: bengottwaldi04@gmail.com
```

## Apply

**First commit in a repo** — set repo-local (never `--global` unless asked):

```bash
git config user.name "weselben/rooforge"
git config user.email "bengottwaldi04@gmail.com"
```

**One-off** (no config touch):

```bash
git -c user.name="weselben/rooforge" -c user.email="bengottwaldi04@gmail.com" commit ...
```

**Fix authorship of an existing commit:**

```bash
git config user.name "weselben/rooforge"
git config user.email "bengottwaldi04@gmail.com"
git commit --amend --reset-author --no-edit
```

**Rewrite pushed history:** `git push --force-with-lease` — confirm with user first unless they asked for the force push.

## Boundaries

- Set `user.name` and `user.email` before every commit. A failed `git commit` from a missing identity means this skill was skipped.
- Force-pushes that rewrite history require explicit user confirmation.