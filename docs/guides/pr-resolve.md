# pr-resolve

Resolve PR review findings by dispatching one resolver subagent per finding group into its own worktree off the PR head branch, committing fixes under the user's git identity, pushing to the PR head, and replying in each review thread with the resolving commit SHA. Consumes `Skill(skill='pr-review')`'s `Skill(skill='caveman-review')` output; produces thread replies + a summary comment. Triggers: "resolve review comments", "fix PR feedback", "address review findings".

## When to load

- After `Skill(skill='pr-review')` posts a review with 🔴/🟡 findings and the user says "resolve review comments" / "fix PR feedback" / "address review findings"
- In forge's orchestration: step 8 (Resolve findings) — runs after `Skill(skill='pr-review')` finds 🔴/🟡, loops until none remain

## How it works

1. **WORKTREE** — Ensure isolated on PR head via `Skill(skill='using-git-worktrees')` Step 0. Create `.worktrees/pr-<n>-resolve/` tracking the PR head branch if not already there.
2. **COLLECT** — Gather actionable findings from inline review comments (`gh api repos/{owner}/{repo}/pulls/<n>/comments --paginate --jq '.[] | select(.in_reply_to_id == null and .position != null) | {id, path, line, body, user, diff_hunk}'`, unresolved only). Fall back to `docs/reviews/pr-<n>.md` if present. Group by file or concern. Triage per finding: 🔴/🟡 → resolve; 🔵 nit → resolve if trivial else skip with reason; ❓ q → answer in thread.
3. **DISPATCH** — Swarm mode: one resolver subagent per group, each in its own worktree off PR head. Driven by `scripts/resolve-loop.sh <findings-file> <worktree> [max_iter=5]` (renders `scripts/templates/resolve-loop.md` via `../loops/scripts/cavemanize.sh`, drives `../loops/scripts/run_loop.sh`). Each resolver loads `Skill(skill='use-git-identity')`, `Skill(skill='conventional-commits')`, `Skill(skill='caveman-commit')`, `Skill(skill='verification-before-completion')`; sets repo-local identity before first commit. Cap 10 parallel.
4. **INTEGRATE** — Merge resolver branches into PR-head worktree (`--no-ff`), run test suite on merged result (`Skill(skill='verification-before-completion')`). Clean + green → continue. Red → one fix round through failing group, then report BLOCKED if still red.
5. **PUSH + REPLY** — Push PR head branch. For each resolved inline comment, post thread reply: `gh api repos/{owner}/{repo}/pulls/comments/<comment-id>/replies -f body="Resolved in <sha> — <one-line what changed>"`. For skipped/answered findings, post corresponding thread reply. **One thread reply per inline comment.** Finish with ONE summary top-level review body listing resolved/skipped/answered counts. Done when every inline thread has exactly one reply and the summary exists. PR URL is first line of user-visible reply as Markdown link; summary comment URL second.
6. **CLEANUP** — `Skill(skill='using-git-worktrees')` cleanup: `git worktree remove` + `git branch -d` (the `-d` refusal on unmerged branches is the safety check).

Done when: every thread has one reply, summary comment URL exists, worktrees removed.

## Files in this skill

- `skills/pr-resolve/SKILL.md` — Main skill definition: purpose, steps, scripts table, hard rules, boundaries
- `skills/pr-resolve/templates/resolve-loop.md` — Coordinator-side prompt template (uses `{{findings-file}}`/`{{n}}` placeholders); not directly invoked by the script
- `skills/pr-resolve/scripts/resolve-loop.sh` — Swarm-mode driver: renders `scripts/templates/resolve-loop.md` via `cavemanize.sh`, runs `run_loop.sh` with `max_iter=5` default
- `skills/pr-resolve/scripts/templates/resolve-loop.md` — The `kimi -p ""` payload for each resolver subagent (loads `Skill(skill='pr-resolve')`, `Skill(skill='use-git-identity')`, `Skill(skill='conventional-commits')`, `Skill(skill='caveman-commit')`, `Skill(skill='verification-before-completion')`; defines `DONE:`/`BLOCKED:` contract)

## See also

- `Skill(skill='pr-review')` — Produces the `Skill(skill='caveman-review')` findings this skill consumes; runs in a worktree, drives `kimi -p` via `Skill(skill='loops')`
- `Skill(skill='loops')` — Single home for all `kimi -p` iteration; provides `cavemanize.sh` and `run_loop.sh` used by `resolve-loop.sh`
- `Skill(skill='use-git-identity')` — Sets repo-local `user.name`/`user.email` before each resolver's first commit
- `Skill(skill='conventional-commits')` + `Skill(skill='caveman-commit')` — Commit message format for resolver commits
- `Skill(skill='verification-before-completion')` — Runs project tests on merged result before declaring green
- `Skill(skill='using-git-worktrees')` — Creates/cleans up isolated worktrees per resolver (Step 0 + CLEANUP)
- `Skill(skill='forge')` — Orchestrator that invokes `Skill(skill='pr-resolve')` as step 8 in the PR review/resolve loop
- `Skill(skill='ste100')` — Public GitHub text (thread replies, summary comment) goes through `Skill(skill='ste100')`

## Notes

- The two template copies are intentional: `scripts/templates/resolve-loop.md` is the scripted payload rendered by `resolve-loop.sh` (uppercase `{{FINDINGS}}`/`{{WORKTREE}}` placeholders, substituted by sed). `templates/resolve-loop.md` is the standalone copy (`{{findings-file}}`/`{{n}}` placeholders) so the skill can run with only the loops engine and manual rendering — the skill functions alone and together with the loops pipeline.
- The script invokes `../../loops/scripts/run_loop.sh` directly (not as a sourced function) with the rendered prompt, max_iter, and worktree args.
- `max_iter` defaults to 5 in the script; can be overridden as third argument.
- Parallel cap of 10 resolver subagents is stated in SKILL.md but not enforced in the script — orchestration layer (forge / dispatching-parallel-agents) enforces it.