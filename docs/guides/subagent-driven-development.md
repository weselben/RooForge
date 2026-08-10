# subagent-driven-development

Coordinates parallel implementation by dispatching one implementer subagent per task in its own git worktree, running per-task reviews with fix loops, and integrating completed branches locally into a PR integration branch. Load when an approved plan has independent tasks ready to execute.

## When to load

- Plan approved and integration branch (`dev`, `feat/*`, `fix/*`) confirmed
- Tasks are independent or ordered in waves (dependent tasks wait for prior wave)
- You need parallel implementation with isolated worktrees and mandatory review gates

## How it works

1. **Setup** — Read the plan, create a todo per task, confirm integration branch (never `main`/`master`), create one worktree per task via `using-git-worktrees`:
   ```bash
   git worktree add ".worktrees/$TASK_SLUG" -b "$TASK_SLUG" "$INTEGRATION_BRANCH"
   ```
   Run project setup + baseline tests in each. Pre-flight scan for conflicting tasks; batch into one user question.

2. **Dispatch swarm** — One `AgentSwarm` call (`dispatching-parallel-agents`, `subagent_type: coder`) with `prompt_template` from `implementer-prompt.md`. Each item carries: full task spec (verbatim), worktree path, branch name, commit instructions, binding global constraints, return contract. Up to 10 parallel; independent tasks in one wave.

3. **Handle implementer report** — Implementer returns one of:
   - `DONE` → dispatch task reviewer
   - `DONE_WITH_CONCERNS` → address correctness/scope doubts before review; note observations
   - `NEEDS_CONTEXT` → provide missing context, resume or re-dispatch
   - `BLOCKED` → assess: context problem → provide; needs reasoning → bigger agent; too large → split; plan wrong → escalate

4. **Per-task review** — After each `DONE`, record BASE (integration-branch head the task branched from, never `HEAD~1`). Generate diff:
   ```bash
   git log --oneline <BASE>..<HEAD>  > /tmp/review-<task-slug>.diff
   git diff --stat <BASE>..<HEAD>   >> /tmp/review-<task-slug>.diff
   git diff -U10   <BASE>..<HEAD>   >> /tmp/review-<task-slug>.diff
   ```
   Dispatch read-only `explore` reviewer with `task-reviewer-prompt.md`: task spec, implementer report, diff path, global constraints verbatim. Two verdicts required: spec compliance AND code quality.

5. **Fix loop** — Triggers: spec ❌, Critical/Important finding, or confirmed ⚠️ gap. Max 5 rounds per task:
   - Rounds 1–3: resume original implementer (`Agent(resume=...)`) with open findings verbatim
   - Rounds 4–5: dispatch fresh implementer with "Prior attempts N times; you own it. Read existing commits for what was tried."
   - Every round: implementer fixes, re-runs covering tests (name files), commits, reports contract + covering-test command/output
   - Every round ends with scoped re-review using `re-review-prompt.md` over fix range only (`FIX_BASE` = previous review's head)

6. **Final whole-branch review** — After all tasks complete, dispatch ONE final reviewer on most capable model over full branch range. Point at deferred-minor and parked findings. If findings return, dispatch ONE fix subagent with complete list, then one scoped re-review. No second fix wave — residual load-bearing findings surface to user.

7. **Integrate & finish** — Merge each task branch locally: `git checkout <integration-branch> && git merge --no-ff <task-slug>` (never `main`/`master`). Run full test suite on merged result. Red → stop, investigate. Green → load `finishing-a-development-branch` for cleanup and PR creation. Before declaring complete, load `verification-before-completion` — check each subagent's claimed state against `git status` and full suite run.

## Files in this skill

- `skills/subagent-driven-development/SKILL.md` — Main skill definition: coordinator role, hard rules, 7-step flow, failure modes table
- `skills/subagent-driven-development/implementer-prompt.md` — Template for `AgentSwarm` dispatch: worktree discipline, self-review, report format, fix-round dispatch rules
- `skills/subagent-driven-development/task-reviewer-prompt.md` — Template for per-task reviewer (`explore` agent): spec compliance + code quality rubric, diff scope, output format with Critical/Important/Minor categories
- `skills/subagent-driven-development/re-review-prompt.md` — Template for scoped re-review after fix rounds: per-finding verdicts (ADDRESSED/NOT ADDRESSED), new breakage in fix diff, out-of-scope observations

## See also

- `using-git-worktrees` — Creates isolated worktrees per task (`.worktrees/<task-slug>/`)
- `dispatching-parallel-agents` — Runs the `AgentSwarm` call that launches all implementers in one wave
- `conventional-commits` — Mandatory for every implementer commit (loaded before first commit)
- `caveman-commit` — Mandatory for every implementer commit (loaded before first commit)
- `verification-before-completion` — Mandatory for implementers (self-review) and coordinator (final integration check)
- `caveman-review` — Loaded by task reviewers for review formatting
- `finishing-a-development-branch` — Runs after green integration for cleanup and PR creation
- `planning-and-task-breakdown` — Produces the approved plan with Global Constraints that SDD consumes
- `resolving-merge-conflicts` — Loaded by forge if conflicts occur during parallel worktree integration (step 4 of forge flow)
- `forge` — Orchestrator that hands off to SDD at step 4 ("Work") after plan approval

## Notes

- The `task-reviewer-prompt.md` references `[BASE_SHA]` as "the integration-branch head the task branched from (never `HEAD~1`)" — this is critical because `HEAD~1` truncates multi-commit task branches.
- The `implementer-prompt.md` requires the `conventional-commits` and `caveman-commit` skills to be loaded "before writing any commit message" — enforce this in the dispatch.
- Fix-round dispatches (rounds 4–5) use a fresh implementer with the framing "A prior implementer attempted this task N times; you own it now. Read the existing commits on this branch for what was tried." — the worktree and branch are reused.
- The skill does not specify a maximum number of parallel tasks beyond "up to 10 parallel" in the dispatch step; `dispatching-parallel-agents` may have its own limits.