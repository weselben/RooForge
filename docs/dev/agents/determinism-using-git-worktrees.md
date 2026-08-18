# Determinism sampling — using-git-worktrees

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/using-git-worktrees.log` (gitignored).

## Sample

- **Task:** trace Steps 0–3 for creating `.worktrees/feat-init` off `main` on branch `feat/init`; output the exact command sequence and the always-same vs judgment split. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:30:53Z, exit 0, 132 log lines (incl. model reasoning).
- **Outcome:** model produced the four-step trace verbatim, correctly noted that **this repo has no test runner / package manifest** ("Repo has none of these files → all short-circuit → nothing runs"), and refused to invent a green pass.

## Observed meta-decisions

- Read `skills/using-git-worktrees/SKILL.md` first.
- Detected consent was implicit because the user named the path/branch explicitly — a context-reading judgement.
- Verified ignored via `git check-ignore .worktrees` rather than assuming.
- Recognised "no manifest matches → flag, don't fake green" as a judgement call the skill's "Done when" requires.
- Did **not** mutate anything (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Step 0 detect-isolation block | none | full — fixed four commands | **shell script** — verbatim from the skill. | input: repo; output: `{GIT_DIR, GIT_COMMON, BRANCH, superproject?}`. |
| 2 | Submodule guard (`--show-superproject-working-tree`) | none | full — fixed | **shell script** — one-liner. | n/a. |
| 3 | Consent gate | low — explicit declaration vs ask | rule is fixed | **shell/wrapper** — explicit declaration in the prompt (named path/branch) counts as consent; otherwise ask. | input: user prompt; output: `{consent: bool}`. |
| 4 | Sync before branching (`fetch origin` + ff-pull) | none | full — fixed | **shell script** — verbatim. | input: base; output: synced. |
| 5 | Directory priority (explicit > `.worktrees/` > `worktrees/`) | low — apply the ladder | ladder is fixed | **shell script** — apply ladder in order. | input: repo + user preference; output: dir. |
| 6 | Verify git-ignored via `git check-ignore` | none | full — fixed | **shell script** — `git check-ignore .worktrees`; if not ignored, edit `.gitignore` + commit. | input: dir; output: {ignored: bool}. |
| 7 | `git worktree add <path> -b <branch> <base>` | none | full — fixed command | **shell script** — verbatim. | input: path + branch + base; output: worktree created. |
| 8 | Permission-error fallback (work in place) | low — when triggered | rule is fixed | **shell script** — error-branch triggers fallback. | input: error; output: in-place mode. |
| 9 | Step 2 setup auto-detection (5 manifest checks) | none | full — fixed | **shell script** — verbatim `[ -f ... ] && ...` block. | input: repo; output: installed. |
| 10 | Step 3 baseline test runner (5 candidates) | low — pick the runner | runner list is fixed | **shell script** — try candidates; flag if none matches rather than fake green. | input: project; output: `{runner, passed: bool, log}`. |
| 11 | Report "no test suite detected" vs fake green | medium — judgement call | rule is fixed (don't fake) | **shell script** — empty candidate list → emit warning. | input: matched candidates; output: warning. |
| 12 | Parallel subagent dispatch (`.worktrees/<task-slug>` + branch from integration) | none | full — fixed | **AgentSwarm `{{item}}`** — standard pattern. | input: task list + integration branch; output: dispatched. |
| 13 | Cleanup ("work landed") | medium — when to clean | rule is fixed ("PR/merge exists") | **shell script** — `gh pr view` + `git branch --merged` gates the cleanup. | input: branch; output: cleanup. |
| 14 | Branch naming (`feat/init` vs `feat-init`) | low — convention | mostly | **shell script** — follow user's explicit name. | input: name; output: same. |

## Notes

- This skill is **almost entirely mechanical**: the scriptable commands dominate, and the small judgement spots (consent, dir choice, baseline runner) are clearly bounded.
- The "no test runner matches → flag, don't fake green" rule is the most important check the skill encodes — it's an honesty invariant. A wrapper that fails loud on missing runners is strictly better than one that returns success.
- The strongest determinism win is a **`forge_mcp.worktree_create(repo, base, branch)` MCP tool** that bundles Steps 0–3 with the consent, sync, and check-ignore steps; the model only handles edge-case fallbacks.
- The "submodule guard" (step 2) is a subtle correctness invariant the skill ships — a wrapper that misses it would mis-classify submodule work as a worktree. Worth preserving in the tool's contract.
- "In-flight is not bloat" (cleanup) is a stateful judgement that a `gh`/`git` lookup can enforce: branch with no PR and no merge → leave alone.