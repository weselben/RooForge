# Determinism sampling — forge-cleanup

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/forge-cleanup.log` (gitignored).

## Sample

- **Task:** trace steps 1–4 as a dry run for three given artefacts (`/tmp/pr-review-7.md`, `.worktrees/old-task`, `scratch.txt`); list candidates, per-candidate prompts, action table mapping. No deletions, no git mutations. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:28:25Z, exit 0, 57 log lines (incl. model reasoning).
- **Outcome:** model produced the three candidate detections, three prompts in the exact required format, the action table, and the final pull — and explicitly handled the "least destructive" ordering rule (scratch → worktree → untracked).

## Observed meta-decisions

- Read `skills/forge-cleanup/SKILL.md` first.
- Briefly struggled with the forge "always load first" trigger and correctly decided not to invoke it (the task is a dry-run trace, not a live cleanup, and AGENTS.md says user instructions take precedence).
- Order of candidate presentation followed the skill's "least destructive" rule without prompting — a rule-driven ordering.
- Branch-name extraction for the worktree prompt was flagged as judgment (the worktree loop's `git branch --show-current` is mechanical, but composing the prompt's "branch X, unmerged, not on origin" requires parsing).
- Did **not** execute any deletion or git mutation (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Detect candidates (scratch files, stale worktrees, uncommitted, untracked, local branches) | low — parse output | full — detection commands are fixed | **shell script** — verbatim from the skill; deterministic output. | input: repo; output: `{scratch: [...], worktrees: [...], uncommitted: [...], untracked: [...], branches: [...]}`. |
| 2 | Per-candidate prompt (`Found: <type> <path>. Remove it? [y/N] >`) | none | full — fixed template | **shell script / Node wrapper** — read a response, only act on `y`/`Y`. | input: candidate; output: confirmed: bool. |
| 3 | "One candidate at a time" / "Default is NO" / "Current branch protected" | none | full — fixed rules | **shell script** — guard around every prompt. | input: candidate + current branch; output: skip-on-no. |
| 4 | Ordering (least destructive first) | low — rule is explicit | mostly — damage ranking is the rule | **shell script** — fixed ordering: scratch → worktree → uncommitted → untracked → branch. | input: candidate list; output: ordered list. |
| 5 | Action table mapping (type → command) | none | full — fixed table | **shell script** — dispatch by type. | input: candidate type; output: command. |
| 6 | Decide whether to offer second `reset --hard` prompt | medium — "many" is undefined | threshold is fuzzy | **keep-as-model** — the threshold is judgement; the *offer* itself is template-shaped. | input: uncommitted count; output: {offer_repo_reset: bool}. |
| 7 | Branch-name extraction for worktree prompt | low — `git branch --show-current` | mostly | **shell script** — pure shell, no model. | input: worktree path; output: branch string. |
| 8 | `--force` flag on worktree removal | low — only when blocked | condition is explicit | **shell script** — condition check. | input: worktree state; output: {use_force: bool}. |
| 9 | Branch delete after worktree removal (only if local) | none | full — fixed rule | **shell script** — `--branch option` to `git worktree remove` handles it. | input: branch; output: command. |
| 10 | Final pull + report | none | full — fixed command + report format | **shell script** — counts in report from #1's output. | input: action log; output: report. |

## Notes

- Forge-cleanup is the **most mechanical** skill sampled so far: detection, prompt format, action table, ordering, and final pull are all rule-shaped. The only consistent judgment spots are step 6 (when to escalate to repo-level reset) and the small act of composing per-candidate prompts with branch/version context.
- The strongest determinism win is the **detection step**: a script that runs the five commands and emits a structured `found.json` is fully scriptable. The model would only handle the prompt text and the optional reset escalation.
- The skill's `disableModelInvocation: true` in frontmatter is a strong hint that the harness (or upstream caller) is meant to invoke it under interactive control — the model role is largely conditioned on user-permitted choices.
- A `forge_mcp.cleanup_scan(repo)` MCP tool would make this entire skill a deterministic shell loop with optional model for the threshold decision.
