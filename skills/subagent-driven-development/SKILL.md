---
name: subagent-driven-development
source: https://raw.githubusercontent.com/obra/superpowers/main/skills/subagent-driven-development/SKILL.md
description: Coordinator-driven parallel implementation — dispatch one implementer subagent per task in its own worktree, per-task review, fix loop, integrate. Load when the plan has independent tasks ready to execute.
---

# Subagent-Driven Development

You are the coordinator. Dispatch a fresh implementer per task — each in its own worktree — review every task (spec compliance + code quality), integrate branches locally. Your context stays clean for coordination.

**Leading word: dispatch + report.** Every implementer reports back with the four-item contract (branch, commits, tests, summary). You integrate; subagents never merge.

## Hard rules

- Task branches FROM the PR integration branch (`dev`, `feat/*`, `fix/*`), merge back INTO it only. **Never `main`/`master`** — main changes only via PR.
- One worktree per task: `.worktrees/<task-slug>/`, branch `<task-slug>`, off the integration branch.
- Worktrees share the object store: subagent commits are visible to you immediately. Integration is local merge — no push between subagents and coordinator.
- Subagents never merge, never present options. They commit in their worktree, verify, report. **You** decide integration.
- **MANDATORY FIRST** in every subagent prompt. Implementer: `using-git-worktrees` + `conventional-commits` + `caveman-commit` + `verification-before-completion`. Reviewer: add `caveman-review`.
- **No-ambiguity prompts** — see `dispatching-parallel-agents` "Prompt rules". Every subagent prompt includes **broader context** (plan, why, what came before, what comes after) AND **task context** (exact files, exact commands, exact output). STE100 prose: one meaning per word, short sentences, active voice. The subagent must never need to ask a clarifying question — that signal means the prompt was incomplete.

## Steps

### 1. Setup

1. Read the plan once. Note Global Constraints. Create a todo per task.
2. Determine the PR integration branch (`dev`/`feat/*`/`fix/*`, never `main`/`master`). If unclear, ask before any work.
3. Create one worktree per task via `using-git-worktrees`:
   ```bash
   git worktree add ".worktrees/$TASK_SLUG" -b "$TASK_SLUG" "$INTEGRATION_BRANCH"
   ```
   Run project setup + baseline tests in each.
4. **Pre-flight scan** for conflicts (contradictory tasks, plan text mandating something review treats as a defect). Batch into one question for the user before execution.

**Done when:** integration branch confirmed, worktrees created with green baselines.

### 2. Dispatch the swarm

Dispatch all implementers in ONE `AgentSwarm` call (see `dispatching-parallel-agents`):

- `prompt_template` with `{{item}}` placeholder
- `subagent_type: coder`
- Each item carries: full task spec, worktree path, branch name, commit instructions, binding global constraints, return contract
- Up to 10 parallel; independent tasks in one wave, dependent in later waves

Keep moving without check-ins. As each implementer returns, handle its report, dispatch its reviewer, run the fix loop until review is clean/parked/BLOCKED.

### 3. Handle the implementer report

Implementers report one of four statuses:

- **DONE** — dispatch the task reviewer.
- **DONE_WITH_CONCERNS** — read concerns. Correctness/scope doubts: address before review. Observations: note and proceed.
- **NEEDS_CONTEXT** — provide missing context, resume or re-dispatch.
- **BLOCKED** — assess: context problem → provide; needs more reasoning → bigger subagent; too large → split; plan wrong → escalate to human.

Never rush an implementer asking questions — answer clearly and completely.

### 4. Per-task review

After each DONE, record BASE (integration-branch head the task branched from — **never `HEAD~1`**, truncates multi-commit tasks). Generate the diff:

```bash
git log --oneline <BASE>..<HEAD>  > /tmp/review-<task-slug>.diff
git diff --stat <BASE>..<HEAD>   >> /tmp/review-<task-slug>.diff
git diff -U10   <BASE>..<HEAD>   >> /tmp/review-<task-slug>.diff
```

Dispatch a task reviewer (read-only `explore`) with: task spec, implementer report, diff path, binding global constraints verbatim. Both verdicts required: spec compliance AND task quality. Implementer self-review never replaces this.

⚠️ "cannot verify from diff" items don't block — resolve each yourself before completion.

### 5. Fix loop

Triggers: spec ❌, Critical/Important finding, or confirmed ⚠️ gap. Two exits:

- **Minor findings** — record as deferred for final review.
- **Plan-mandated findings** — present beside plan text, ask which governs.

Everything else loops, **5 rounds max per task**:

- **Rounds 1–3:** resume the original implementer (`Agent(resume=...)`) with open findings verbatim — context intact.
- **Rounds 4–5:** dispatch fresh implementer — "Prior attempts N times; you own it. Read existing commits for what was tried."
- Every round: implementer fixes, re-runs covering tests (name the files — a one-line fix doesn't need full suite), commits, reports same contract + covering-test command/output.
- Every round ends with a scoped re-review (`re-review-prompt.md`) over the fix range only (FIX_BASE = previous review's head).

**Breaker.** Round 5 still has findings? Stop dispatching, adjudicate each:

- Reviewer wrong / contestable → park with ruling (final review sees both).
- Real but nothing downstream builds on it → park with "real, deferred".
- Real and load-bearing → STOP. Report BLOCKED with finding, plan text collision, fix history.

Adjudicate only at the cap. Every ruling recorded; silent discard forbidden. Never fix findings yourself — coordinator fixes skip review and pollute context.

### 6. Final whole-branch review

After all tasks complete, dispatch ONE final reviewer on the most capable available model over the full branch range. Point it at deferred-minor and parked findings for triage.

If findings return, dispatch ONE fix subagent with the complete list. Then one scoped re-review of the fix wave; adjudicate residuals. **No second fix wave** — residual load-bearing findings surface to the user at handoff.

### 7. Integrate & finish

1. Merge each task branch into the integration branch locally via squash: `git checkout <integration-branch> && git merge --squash <task-slug> && git commit -m "<conventional-commit>"`. One commit per task on the integration branch, each a natural Conventional Commit (e.g. `feat(api): add user profile endpoint`). **Never `main`/`master`.**
2. Run full test suite on merged result. **Red:** stop, leave everything in place, investigate (nothing pushed, merge is local + recoverable).
3. **Green:** load `finishing-a-development-branch` for cleanup and PR creation.

Before declaring integration complete, load `verification-before-completion` — check each subagent's claimed state against `git status` and full suite run, not against the summary it returned.

## Failure modes (no-ops → positive form)

| Excuse | Reality |
|--------|---------|
| "Close enough on spec" | Spec gaps = not done. Fix, or hit the cap and adjudicate. |
| "I'll fix it myself, dispatching is overhead" | Coordinator fixes skip review. Resume the implementer. |
| "One more round will converge" | Past the cap, rounds don't converge. Adjudicate and route. |
| "This finding is obviously wrong" | Adjudicate only at the cap, record every ruling. |
| "The fix was small, skip re-review" | Unreviewed fixes = regressions. Every round ends with re-review. |
| "Subagents can share one worktree" | Parallel agents in one tree collide. One per task. |
| "Subagents should push their branches" | Worktrees share object store. Local merge. |
| "Merge everything to main when done" | Main changes only via PR. |