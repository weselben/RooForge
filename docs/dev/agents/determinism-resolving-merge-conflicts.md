# Determinism sampling — resolving-merge-conflicts

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/resolving-merge-conflicts.log` (gitignored).

## Sample

- **Task:** trace steps 1–5 for a one-line README conflict (ours=`alpha`, theirs=`beta`, merge goal "keep alpha, then beta on next line"). Output the resolution text and the mechanical/judgment split. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:30:06Z, exit 0, 36 log lines (incl. model reasoning).
- **Outcome:** model produced the two-line resolution, classified the steps 1/4/5 as mechanical and steps 2/3 as judgement, and correctly noted the skill's "Always resolve; never `--abort`" rule (implicit — the model never suggested aborting).

## Observed meta-decisions

- Read `skills/resolving-merge-conflicts/SKILL.md` first.
- Step 1 (state inspection) was mechanical: `git status` and `git log` for ours/theirs.
- Step 2 (intent extraction) was judgment: read both commits' messages, infer intent, decide the merge is compatible.
- Step 3 (per-hunk resolution) was judgment: applied the merge goal's stated preference (`alpha` then `beta`).
- Step 4 (run checks) was mechanical: typecheck, tests, format — even when the change is trivial, the skill mandates running them.
- Step 5 (finish) was mechanical: `git add`, `git commit` / `git rebase --continue`.
- Did **not** mutate the repo (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | `git status` + `git log` for state | none | full — fixed commands | **shell script** — `git status --porcelain` + `git log --oneline -N`. | input: repo; output: state. |
| 2 | Read primary sources (commit messages, PRs, issues) for intent | high — semantic interpretation | none | **keep-as-model** — intent extraction. | input: commits + refs; output: intent per side. |
| 3 | Resolve each hunk per the merge goal | high — preserve both intents or pick | the "no invented behaviour" rule is fixed | **keep-as-model** — the hunks are the work. | input: conflicting hunks + goal; output: resolution. |
| 4 | Run automated checks (typecheck, tests, format) | none | full — fixed per-project | **shell script** — project-config dispatch (same as `finishing-a-development-branch`). | input: project; output: `{passed: bool, log}`. |
| 5 | Stage + commit (or `git rebase --continue`) | none | full — fixed commands | **shell script** — verbatim. | input: resolved files; output: state. |
| 6 | "Never `--abort`" guard | none | full — fixed rule | **shell script** — pre-commit check that no `git merge --abort` / `git rebase --abort` was used. | input: repo; output: violation. |
| 7 | Detect SDD handoff (multiple subagent branches touching integration) | medium — classification | rule is fixed | **premade prompt template** — wrapper asks "does this conflict touch multiple SDD branches?"; result picks handoff. | input: conflict context; output: {handoff_to_sdd: bool}. |
| 8 | Dispatch one fix subagent per remaining conflicting file (each in its own worktree) | none | full — fixed pattern | **AgentSwarm `{{item}}`** — already the standard pattern. | input: file list; output: dispatched subagents. |
| 9 | Run `verification-before-completion` on integrated result | none | full — fixed chain | **shell script** — invoke the skill. | n/a. |

## Notes

- The skill's **mechanical/judgment split is exactly the right one**: the hunks are the work; the surrounding plumbing is scriptable. The sample confirms this is how the model already operates.
- The strongest determinism win is a **`forge_mcp.merge_state(repo)` MCP tool** that returns `{status, ours, theirs, hunks, suggestions}` — the model then only authors the intent and the resolution.
- The "Never `--abort`" rule is a guard, not a step — but a deterministic check on the post-merge state ("no `MERGE_HEAD` left over, no `REBASE_HEAD` left over") catches the failure mode.
- The SDD handoff is a **threshold judgement** (multiple branches) that the wrapper can make programmable: count distinct branch refs in the conflict context → yes/no.