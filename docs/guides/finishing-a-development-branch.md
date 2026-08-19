# finishing-a-development-branch

Finishes a development branch by committing, verifying, pushing, and opening a PR — the only permitted path to integrate into main. Two variants exist: a **Subagent Variant** (commit, verify, report) for subagents working in assigned worktrees, and a **Coordinator Variant** (push + open PR) for the coordinator after swarm work completes or for solo work.

## When to load

- "finish this branch"
- "wrap up"
- "open a PR"
- Implementation is complete and tests pass

## How it works

### Subagent Variant (inside assigned worktree)

1. **Commit all work** — Stage everything; load `Skill(skill='caveman-commit')` + `Skill(skill='conventional-commits')` (skills/caveman-commit/, skills/conventional-commits/)
2. **Verify a clean tree** — `git status` must show nothing to commit, working tree clean
3. **Run the test suite** — `npm test` / `cargo test` / `pytest` / `go test ./...`; if tests fail, fix or report verbatim
4. **Report four items:**
   - Branch name
   - Commit list (SHA + subject, one per line)
   - Test status (command run, pass/fail)
   - One-paragraph summary of what changed and why

**Done when:** the four-item report is delivered. Commits already live in the shared object store — the coordinator handles the rest.

### Coordinator Variant (after swarm or solo)

1. **Verify tests** — Run full suite on the tree to integrate. Load `Skill(skill='verification-before-completion')`. "Tests passed earlier" is not evidence.
   **Done when:** suite is green.

2. **Detect environment** — Run:
   ```bash
   GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
   GIT_COMMON=$(cd "$(git rev-parse --git-common-dir") 2>/dev/null && pwd -P)
   WORKTREE_PATH=$(git rev-parse --show-toplevel)
   ```
   | State | Meaning |
   |-------|---------|
   | `GIT_DIR == GIT_COMMON` | Normal repo, no worktree cleanup needed |
   | `GIT_DIR != GIT_COMMON`, named branch | Worktree — cleanup is provenance-based (Step 6) |
   | `GIT_DIR != GIT_COMMON`, detached HEAD | Externally managed — leave in place |

3. **Confirm base branch** — The base is what the forked work split from (integration branch for swarm). If unknown, ask: "This branch split from `<best guess>` — correct?"

4. **Merge each subagent branch** — For each branch a subagent reported (cross-load `Skill(skill='subagent-driven-development')`):
   ```bash
   MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
   cd "$MAIN_ROOT"
   git checkout <integration-branch>
   git merge --no-ff <task-branch>
   ```
   After all merges, run full suite on merged result. **Red:** stop, leave everything in place, investigate (nothing pushed, local + recoverable).
   If merge conflicts occur, load `Skill(skill='resolving-merge-conflicts')` — handles steps 1–3, delegates multi-branch conflicts to `Skill(skill='subagent-driven-development')`.

5. **Push and create PR** — `git push -u origin <integration-branch>` (detached: `git push origin HEAD:refs/heads/<new>`), load `Skill(skill='creating-pull-requests')`. Keep worktrees for PR feedback.
   **Done when:** PR URL returned, AI disclosure in place, worktrees preserved.

6. **Cleanup workspaces** — Runs only if work is discarded (explicit request).
   - `GIT_DIR == GIT_COMMON`: nothing to clean.
   - `.worktrees/` or `worktrees/`: `git worktree remove "$path" && git worktree prune`.
   - Otherwise: host environment owns it — leave in place.
   **Done when:** `.worktrees/` holds only in-flight work.

## Files in this skill

- `SKILL.md` — Main skill definition with both variants, environment detection, merge/push/cleanup procedures

## See also

- `Skill(skill='caveman-commit')` — Used in Subagent Variant step 1 for committing
- `Skill(skill='conventional-commits')` — Used in Subagent Variant step 1 for commit formatting
- `Skill(skill='verification-before-completion')` — Loaded in Coordinator Variant step 1 and forge step 6
- `Skill(skill='creating-pull-requests')` — Used in Coordinator Variant step 5 for PR creation
- `Skill(skill='subagent-driven-development')` — Cross-referenced for subagent branch reporting and multi-branch conflict delegation
- `Skill(skill='resolving-merge-conflicts')` — Loaded when merge conflicts occur during integration
- `Skill(skill='forge')` — Orchestrator that uses this skill in its PR/verify/review/resolve loop (steps 5–8)

## Notes

- The skill directory contains only `SKILL.md` — no scripts, templates, or companion files.
- Hard rule cited from SKILL.md: "NEVER merge to `main`/`master`. Main receives changes only via pull request."
- The Coordinator Variant's Step 2 has a typo in the SKILL.md source: `git rev-parse --git-common-dir")` — missing `(` before the closing quote.
- The forge skill references this skill implicitly in its flow (steps 5–8: PR → verify → pr-review → pr-resolve) but does not invoke it by name.