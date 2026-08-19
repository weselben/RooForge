# using-git-worktrees

`Skill(skill='using-git-worktrees')` (`skills/using-git-worktrees/SKILL.md`) creates an isolated git worktree for feature work — but only after detecting whether the session is already isolated (linked worktree, submodule, or harness-managed workspace). It covers the full lifecycle: detection, creation, project setup, baseline test verification, one-worktree-per-subagent dispatch, and coordinator-run cleanup once work has landed. Upstream source: `https://github.com/obra/superpowers/tree/main/skills/using-git-worktrees` (frontmatter, line 3).

## When to load

Trigger phrases from the frontmatter `description` (line 4): `"worktree"`, `"isolate"`, `"parallel implementation"`, `"subagent dispatch"`. In practice, load it when:

- Starting feature work that should not touch the main checkout.
- A coordinator (forge, `Skill(skill='subagent-driven-development')`) is about to dispatch parallel subagents — each gets its own worktree.
- `Skill(skill='pr-review')` / `Skill(skill='pr-resolve')` need a worktree on the PR head (both invoke Step 0 explicitly).
- Work has landed (PR opened or branch merged) and worktrees/branches need cleanup.

## How it works

The skill is a single `SKILL.md` (145 lines, no scripts or templates). Main flow:

1. **Step 0 — Detect existing isolation** (`SKILL.md:14-31`). Compare the resolved git dir against the common dir:
   ```bash
   GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
   GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
   BRANCH=$(git branch --show-current)
   ```
   If `GIT_DIR != GIT_COMMON` and not a submodule (guarded by `git rev-parse --show-superproject-working-tree`, line 26), you're already isolated — report path/branch and skip to Step 2. Otherwise ask for consent before creating; if declined, work in place.
2. **Step 1 — Create the worktree** (`SKILL.md:33-66`). Directory priority: explicit user preference → existing `.worktrees/` or `worktrees/` at project root → default `.worktrees/`. Verify the directory is git-ignored first (add to `.gitignore` and commit if not). Sync before branching (lines 50-54): `git fetch origin`, then `git pull --ff-only` on `main` and `$BASE_BRANCH`; a failed ff-pull means stop and report, never merge/rebase silently. Create with `git worktree add "$path" -b "$BRANCH_NAME"` and `cd` into it. On permission error, work in place.
3. **Step 2 — Project setup** (`SKILL.md:68-79`). Auto-detect by manifest file and run the matching install: `package.json` → `npm install`, `Cargo.toml` → `cargo build`, `requirements.txt` → `pip install -r requirements.txt`, `pyproject.toml` → `poetry install`, `go.mod` → `go mod download`.
4. **Step 3 — Verify clean baseline** (`SKILL.md:81-88`). Run the project test suite (`npm test` / `cargo test` / `pytest` / `go test ./...`). Green → report ready. Red → report failures and ask whether to proceed.
5. **Parallel subagents** (`SKILL.md:90-103`). One worktree per subagent: directory `.worktrees/<task-slug>/`, branch `<task-slug>`, branched from the integration branch (`dev`, `feat/*`, `fix/*`) — **never** from `main`/`master`:
   ```bash
   git worktree add ".worktrees/$TASK_SLUG" -b "$TASK_SLUG" "$INTEGRATION_BRANCH"
   ```
   Worktrees share the object store, so subagent commits are immediately visible to the coordinator.
6. **Cleanup when work lands** (`SKILL.md:105-116`). Trigger is "work landed" (PR opened or branch merged), never "phase finished". The coordinator — not the subagent — runs:
   ```bash
   git worktree remove "$path"
   git branch -d "$BRANCH_NAME"
   ```
   After a PR merges, delete the remote branch with `git push origin --delete "$BRANCH_NAME"` (skip for integration branches).
7. **Reference tables** (`SKILL.md:118-145`). A Quick Reference table mapping situations to actions (e.g. "Both `.worktrees/` and `worktrees/` exist → use `.worktrees/`") and a Failure Modes table countering common excuses (e.g. "The directory is surely ignored" → run `git check-ignore`).

## Files in this skill

- `skills/using-git-worktrees/SKILL.md` — the entire skill: frontmatter with triggers, the four-step flow, parallel-subagent rules, cleanup rules, Quick Reference and Failure Modes tables.

## See also

- `Skill(skill='forge')` (`skills/forge/SKILL.md`) — referenced at `SKILL.md:115` as the coordinator that runs cleanup; forge step 4 delegates worktree creation to `Skill(skill='subagent-driven-development')`, which uses this skill.
- `Skill(skill='subagent-driven-development')` (`skills/subagent-driven-development/SKILL.md:28`) — calls this skill to create one worktree per task; lists it as a MANDATORY skill in every implementer subagent prompt.
- `Skill(skill='dispatching-parallel-agents')` (`skills/dispatching-parallel-agents/SKILL.md:56`) — names this skill in the mandatory first block of implementer prompts.
- `Skill(skill='pr-review')` (`skills/pr-review/SKILL.md:20`) — invokes Step 0 to isolate on the PR head in `.worktrees/pr-<n>-review/`.
- `Skill(skill='pr-resolve')` (`skills/pr-resolve/SKILL.md:15,20`) — invokes Step 0 for `.worktrees/pr-<n>-resolve/` and uses this skill's cleanup (`git worktree remove` + `git branch -d`).
- `Skill(skill='loops')` (`skills/loops/SKILL.md:70`) — explicitly does not manage worktrees; defers to this skill.

## Notes

- The sync block (`SKILL.md:50-54`) hardcodes `main` alongside `$BASE_BRANCH`; repos whose default branch is not `main` must adapt the first `git pull --ff-only` line.
- `git branch --show-current` (line 19) returns empty on a detached HEAD; the skill does not address that case.
- The skill's own text references only `Skill(skill='forge')` by name; all other "See also" entries are callers identified by searching the skills tree, not links from within the skill.
