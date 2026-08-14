---
name: resolving-merge-conflicts
description: "Use when you need to resolve an in-progress git merge/rebase conflict. Loads `subagent-driven-development` when conflicts touch integration branches and need per-task unblock work."
source: "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/resolving-merge-conflicts/SKILL.md"
---

# Resolving Merge Conflicts

1. **See the current state** of the merge/rebase. Check git history, and the conflicting files.

2. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.

3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Always resolve; never `--abort`.

4. Discover the project's **automated checks** and run them — typically typecheck, then tests, then format. Fix anything the merge broke.

5. **Finish the merge/rebase.** Stage everything and commit. If rebasing, continue the rebase process until all commits are rebased.

## When to load `subagent-driven-development`

When a merge conflict touches **multiple subagent branches** being integrated into the integration branch — not just one. Example: SDD dispatched 5 implementers, your squash-merge of branch #2 hit conflicts with #1 already on the integration branch, and #3 hasn't been merged yet. Resolving #2's conflicts manually risks clashing with #3's work.

In that case:

1. Resume this skill's steps 1–3 for each immediate hunk so the merge moves forward.
2. **Switch to `subagent-driven-development`** for the remaining conflict hunks — dispatch one fix subagent per remaining conflicting file, each in its own worktree off the integration branch, with the conflict markers and the conflicting commits' intents as broader context.
3. Run the project's test suite on the integrated result via `verification-before-completion` before committing.

This keeps parallel-implementation velocity even when conflicts land in the integration step.