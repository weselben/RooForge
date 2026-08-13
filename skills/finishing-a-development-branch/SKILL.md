---
name: finishing-a-development-branch
source: https://raw.githubusercontent.com/obra/superpowers/main/skills/finishing-a-development-branch/SKILL.md
description: "Finish a development branch — commit, verify, push, open PR. PR is the only path. Load when implementation is complete and tests pass. Triggers: \"finish this branch\", \"wrap up\", \"open a PR\"."
---

# Finishing a Development Branch

Pick the variant that matches your role:

| Role | Variant |
|------|---------|
| Subagent in an assigned worktree | **Subagent Variant** — commit, verify, report |
| Coordinator after swarm completes | **Coordinator Variant** — push + open PR |
| Solo work, no swarm | Coordinator Variant, single branch |

**Leading word: done when.** Every step ends on a checkable criterion.

**Hard rule: NEVER merge to `main`/`master`.** Main receives changes only via pull request.

## Subagent Variant

You run inside a worktree the coordinator assigned. You do not merge, push, or present options.

1. **Commit all work.** Stage everything; use `caveman-commit` + `conventional-commits`.
2. **Verify a clean tree.** `git status` must show nothing to commit, working tree clean.
3. **Run the test suite.** `npm test` / `cargo test` / `pytest` / `go test ./...`. If tests fail, fix or report verbatim — do not claim completion on a red suite.
4. **Report these four items:**
   - Branch name
   - Commit list (SHA + subject, one per line)
   - Test status (command run, pass/fail)
   - One-paragraph summary of what changed and why

**Done when:** the four-item report is delivered. Commits already live in the shared object store — the coordinator handles the rest.

## Coordinator Variant

### 1. Verify tests

Run the full suite. If tests fail, report failures and stop — everything below comes after a green suite. Load `verification-before-completion` — "tests passed earlier" is not evidence.

**Done when:** suite is green on the tree you're about to integrate.

### 2. Detect environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

| State | Meaning |
|-------|---------|
| `GIT_DIR == GIT_COMMON` | Normal repo, no worktree cleanup needed |
| `GIT_DIR != GIT_COMMON`, named branch | Worktree — cleanup is provenance-based (Step 5) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Externally managed — leave in place |

### 3. Confirm base branch

The base is whatever the forked work split from — integration branch for swarm work. If unknown, ask: "This branch split from `<best guess>` — correct?" Confirm before merging.

### 4. Merge each subagent branch

For each branch a subagent reported (cross-reference `subagent-driven-development`):

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git checkout <integration-branch>
git merge --squash <task-branch>
git commit -m "<conventional-commit>"
```

After all branches merged, run full suite on the merged result. **Red:** stop, leave everything in place, investigate (nothing pushed, local + recoverable).

**If merge conflicts occur during merge**, load `resolving-merge-conflicts` — it handles steps 1–3, and for multi-branch conflicts delegates to `subagent-driven-development` to unblock in parallel.

### 5. Push and create PR

`git push -u origin <integration-branch>` (detached: `git push origin HEAD:refs/heads/<new>`), follow `creating-pull-requests`. Keep worktrees for PR feedback.

**Done when:** PR URL returned, AI disclosure in place, worktrees preserved for PR feedback.

### 6. Cleanup workspaces

Runs only if work is discarded (explicit request). All other paths preserve worktrees.

- `GIT_DIR == GIT_COMMON`: nothing to clean.
- `.worktrees/` or `worktrees/`: `git worktree remove "$path" && git worktree prune`.
- Otherwise: host environment owns it — leave in place.

**Done when:** `.worktrees/` holds only in-flight work.