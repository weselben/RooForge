# resolving-merge-conflicts

Resolves in-progress git merge/rebase conflicts hunk-by-hunk, preserving both change intents where possible. When conflicts span multiple subagent branches being integrated into the integration branch, delegates remaining hunks to `subagent-driven-development` for parallel per-file fix worktrees, then verifies the integrated result.

## When to load

- Active merge or rebase with conflict markers present (`git status` shows unmerged paths)
- Squash-merging a subagent worktree branch hits conflicts with branches already on the integration branch
- `forge` or `subagent-driven-development` integration step reports merge conflicts
- PR push fails due to merge conflicts during `pr-resolve` loop

## How it works

1. **See current state** — Run `git status`, `git log --oneline -10`, and inspect conflicting files to understand the merge/rebase context.

2. **Find primary sources** — For each conflict, read the conflicting commits' messages, PRs, and original tickets to understand the intent behind each change (`skills/resolving-merge-conflicts/SKILL.md:6-7`).

3. **Resolve each hunk** — Edit conflicted files to preserve both intents where compatible; where incompatible, choose the one matching the merge's stated goal and note the trade-off. Never `--abort` (`skills/resolving-merge-conflicts/SKILL.md:8-9`).

4. **Run automated checks** — Execute the project's typecheck, tests, and format commands in sequence; fix anything the merge broke (`skills/resolving-merge-conflicts/SKILL.md:10-11`).

5. **Finish the merge/rebase** — Stage all resolved files and commit. If rebasing, continue until all commits are rebased (`skills/resolving-merge-conflicts/SKILL.md:12-13`).

6. **Multi-branch conflict escalation** — When conflicts touch multiple pending subagent branches (not just one), resume steps 1–3 for immediate hunks, then invoke `subagent-driven-development` to dispatch one fix subagent per remaining conflicting file in its own worktree off the integration branch, with conflict markers and conflicting commit intents as context (`skills/resolving-merge-conflicts/SKILL.md:15-22`).

7. **Verify integrated result** — Run the project's test suite via `verification-before-completion` on the integrated result before committing (`skills/resolving-merge-conflicts/SKILL.md:23-24`).

## Files in this skill

- `skills/resolving-merge-conflicts/SKILL.md` — Main skill definition: 5-step core resolution flow plus escalation to `subagent-driven-development` for multi-branch conflicts.

## See also

- `subagent-driven-development` — Orchestrates per-task worktrees and parallel fix subagents when conflicts span multiple integration branches; invoked by this skill's escalation path.
- `forge` — Session orchestrator that loads this skill during integration (step 4 work phase) and PR resolution (step 8); references conflict handling in its flow description (`skills/forge/SKILL.md:58-62`, `skills/forge/SKILL.md:124-127`).
- `verification-before-completion` — Runs full test suite on merged result after conflict resolution; required by this skill's step 7 and forge's verify phase.
- `dispatching-parallel-agents` — Underlying parallel subagent mechanism used by `subagent-driven-development` for multi-branch conflict unblocking.
- `using-git-worktrees` — Worktree management for isolated fix branches during parallel conflict resolution.

## Notes

- The skill directory contains only `SKILL.md` — no companion scripts, templates, or additional files.
- The escalation to `subagent-driven-development` is described at a protocol level; no concrete invocation pattern (command, arguments, or subagent prompt template) is specified in the source.
- Forge's reference to this skill in step 8 (`pr-resolve` loop) notes it "runs steps 1–3" but the skill itself has 5 core steps plus escalation — possible ambiguity on which steps are meant.