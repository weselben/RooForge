---
name: using-git-worktrees
source: https://github.com/obra/superpowers/tree/main/skills/using-git-worktrees
description: "Create an isolated git worktree for feature work. Detect existing isolation first; only create if needed. Triggers: \"worktree\", \"isolate\", \"parallel implementation\", \"subagent dispatch\"."
---

# Using Git Worktrees

**Detect first.** Check whether you're already isolated; only create a worktree if the answer is no. Subagents work only in their assigned worktree; the coordinator integrates and cleans up.

## Steps

### Step 0: Detect existing isolation

Run before creating anything — already-isolated work (linked worktree, submodule, harness-managed workspace) doesn't get a second worktree.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside submodules. Verify:

```bash
git rev-parse --show-superproject-working-tree 2>/dev/null
```

- If `GIT_DIR != GIT_COMMON` (and not a submodule) → report the path and branch, **skip to Step 2**.
- If `GIT_DIR == GIT_COMMON` (or in a submodule) → ask for consent unless the user already declared a worktree preference; if they decline, work in place and **skip to Step 2**.

**Done when:** isolation state is known and either (a) you're already isolated, or (b) you have consent to create.

### Step 1: Create the worktree

**Directory selection** (priority order):

1. Explicit user preference
2. Existing `.worktrees/` (preferred) or `worktrees/` at project root
3. Default: `.worktrees/`

**Safety:** verify the directory is git-ignored before creating. If not ignored: add to `.gitignore`, commit, then proceed.

**Sync before you branch:**

```bash
git fetch origin
git pull --ff-only origin main
git pull --ff-only origin "$BASE_BRANCH"
```

Run at the start of any orchestrated run. If ff-pull fails, stop and report — do not merge or rebase silently.

**Create:**

```bash
path="$LOCATION/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

If permission error: work in place, run setup + baseline tests.

**Done when:** `pwd` is inside the new worktree on the new branch.

### Step 2: Project setup

Auto-detect and run:

```bash
[ -f package.json ] && npm install
[ -f Cargo.toml ] && cargo build
[ -f requirements.txt ] && pip install -r requirements.txt
[ -f pyproject.toml ] && poetry install
[ -f go.mod ] && go mod download
```

**Done when:** setup commands complete.

### Step 3: Verify clean baseline

Run the project's test suite (`npm test` / `cargo test` / `pytest` / `go test ./...`).

- **Green:** report ready — worktree path, tests passing.
- **Red:** report failures and ask whether to proceed or investigate.

**Done when:** tests pass or user explicitly proceeds past failures.

## Parallel Subagents

When a coordinator dispatches multiple subagents:

- Directory: `.worktrees/<task-slug>/`, branch: `<task-slug>`
- Branch from the PR integration branch (`dev`, `feat/*`, `fix/*`) — **never** from `main`/`master`

```bash
git worktree add ".worktrees/$TASK_SLUG" -b "$TASK_SLUG" "$INTEGRATION_BRANCH"
```

Git worktrees share the object store: subagent commits are immediately visible to the coordinator.

## Cleanup when work lands

Worktrees are disposable. Remove when work has landed — PR opened from its branch, or branch merged into integration branch:

```bash
git worktree remove "$path"
git branch -d "$BRANCH_NAME"
```

- **Trigger is "work landed", never "phase finished".** A branch with no PR and no merge stays — in-flight is not bloat.
- After PR merges, delete remote branch: `git push origin --delete "$BRANCH_NAME"` (skip for integration branch).
- Coordinator (forge) runs cleanup — subagents never remove their own worktree.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Already in linked worktree | Skip creation (Step 0) |
| In a submodule | Treat as normal repo (Step 0 guard) |
| Native worktree tool available | Use it |
| No native tool | Git worktree fallback |
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check instructions, default `.worktrees/` |
| Directory not ignored | Add to `.gitignore` + commit |
| Permission error on create | Work in place |
| Tests fail during baseline | Report failures + ask |
| Dispatching parallel subagents | One worktree per subagent, off integration branch |
| Before branching | Sync: `git fetch origin` + ff-pull `main` and base branch |
| PR opened / branch merged | Coordinator removes worktree + branch |
| Work in flight (no PR, no merge) | Leave alone — in-flight is not bloat |

## Failure Modes

| Excuse | Reality |
|--------|---------|
| "I'm obviously not in a worktree" | Run Step 0. Harness isolation and submodules fool eyeballing. |
| "The directory is surely ignored" | Run `git check-ignore`. Unignored = whole tree in repo. |
| "Any directory name works" | Explicit instructions > existing dir > `.worktrees/` default. |
| "Baseline tests can wait" | Dirty baseline makes every later failure ambiguous. |
| "Branch off `main`" | Subagent branches come from integration branch. |
| "Leave the worktree — might need it" | Once PR/merge exists, it's bloat. Coordinator removes. |
| "Syncing is optional" | Stale base turns integration into archaeology. Fetch + ff-pull. |