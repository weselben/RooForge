# Determinism sampling — finishing-a-development-branch

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/finishing-a-development-branch.log` (gitignored).

## Sample

- **Task:** coordinator variant, `feat/init` with 2 squash commits from worktrees T1 + T2; trace steps 1–6 with the exact command sequence and a mechanical/judgment split. DRY RUN; no git mutations, no `gh` writes.
- **Run:** `kimi -p` on 2026-08-18T01:27:57Z, exit 0, 40 log lines (incl. model reasoning).
- **Outcome:** model produced the full command sequence verbatim from the skill (env-detect block, `merge --squash` ×N, push, PR), explicitly flagged step 3 as a user *question* (no command), and correctly skipped step 6 (cleanup only on discarded work).

## Observed meta-decisions

- Read `skills/finishing-a-development-branch/SKILL.md` first.
- Followed the **leading word** ("done when") on every step — each command was paired with its stated done-condition.
- Detected the "no push yet" invariant and surfaced it as a hard stop on red tests.
- Recognized step 3 (confirm base) as a *question*, not a command — a structural inference from the skill's prose.
- Cross-referenced companion skills (`resolving-merge-conflicts`, `caveman-commit`+`conventional-commits`, `creating-pull-requests`) for delegation rather than duplicating their rules.
- Did **not** execute git operations (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Verify tests | low — choose suite command per project | partly — `npm test`/`pytest`/`cargo test` are project-specific | **shell script** with project-config dispatch (e.g. `forge_mcp.test_runner(project)`). | input: project root; output: `{passed: bool, log}`. |
| 2 | Detect environment (GIT_DIR vs GIT_COMMON, worktree, detached) | none | full — fixed shell snippet | **shell script** — verbatim. | input: repo; output: `{state: "normal"\|"worktree"\|"detached"}`. |
| 3 | Confirm base branch | low — best guess + user confirmation | rule is fixed | **shell script** for the guess (parse branch base from metadata) + user prompt when ambiguous. | input: branch; output: base or `AMBIGUOUS`. |
| 4 | Squash-merge each subagent branch | none | full — fixed command template | **shell script** — `git merge --squash` + `git commit -m "<msg>"` per branch. | input: branch list; output: merged result. |
| 5 | Push + PR | none | full — `git push -u` + `gh pr create --draft --body-file` | **shell script** — invokes `creating-pull-requests` wrapper. | input: base + branch; output: PR URL. |
| 6 | Cleanup (worktrees, only on discard) | medium — interpret "discarded" | state-conditional rules are fixed | **shell script** — gated by explicit consent. | input: consent + env state; output: remove or skip. |
| 7 | Interpret red tests (fix vs stop) | high — recoverability reasoning | the stop rule is enumerated | **keep-as-model** for the decision; the *rule* (stop on red, nothing pushed) is checkable. | input: test log; output: {fix, stop, report}. |
| 8 | Resolve merge conflicts | high | none — conflict shapes are unbounded | **load `resolving-merge-conflicts`** — already the skill's delegation. | n/a. |
| 9 | Commit message wording (squash commit) | high | format is mechanical | **caveman-commit + conventional-commits** — already owned by those skills. | per those skills. |
| 10 | PR body content | high | format is mechanical | **`creating-pull-requests`** — already owned. | per that skill. |

## Notes

- This skill is a **dispatcher**: almost every step delegates to a sibling skill or a fixed shell snippet. The model role is to *navigate the chain*, not to author the content.
- The hardest deterministic seam is step 7 (interpret red tests). The skill's policy ("stop, nothing pushed, investigate") is fixed, but the *fix-or-report* decision is judgement. A `verification-before-completion` style check can constrain it.
- Step 4 (squash-merge loop) is the single most consequential point of failure — the order of merges and the handling of conflicts shape the final integration branch. The skill already delegates to `resolving-merge-conflicts` for the latter; the former is a coordination problem for which `subagent-driven-development` is the natural owner.
- The "never merge to main" hard rule is a branch-policy check; trivially scriptable as a pre-push guard.
