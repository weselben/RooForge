---
name: execute
description: >
  Phase-based task execution command. Navigate Blueprint phases, delegate
  individual tasks sequentially to subtask-orchestrator. Used by orchestrator
  mode. Cascades to /delegate with subtask-orchestrator + /delegate with git.
---

# /execute — Phase-Based Task Execution

Finalized Blueprint with phases + individual tasks ready. Do NOT execute tasks yourself (unless subtask-orchestrator). Navigate phases → delegate each task one at a time.

## Step 1: Plan All Phases

Write ALL phases + tasks fully BEFORE starting execution. For each task define:

- **ID**: Phase.Task number (e.g., 1.1, 1.2, 2.1)
- **Objective**: single, clear outcome from Blueprint
- **Scope Boundary**: what is explicitly OUT of scope
- **Dependencies**: which prior tasks must complete first
- **Expected Output**: verifiable result confirming completion
- **Blueprint Excerpt**: exact governing section from Blueprint
- **Context Slice**: exact portion of State of Intel + Constraints relevant to this task

## Step 2: Execute Phase by Phase, Task by Task

Execute ONE task at a time. Do NOT batch-dispatch.

For each phase:

1. **Phase checkpoint** — Verify prior phase checkpoint passed before starting this phase
2. **For each task in this phase:**
   a. **Delegate** — Run `/delegate` with mode `subtask-orchestrator`. Send SINGLE task with full Context Envelope per `/delegate` format.
   b. **Evaluate** — Task completes → check: matched Expected Output? New info changed plan? Incorporate feedback before proceeding.
   c. **Commit** — Run `/delegate` with mode `git`. Include: task context, files changed, commit scope.
   d. **Memory** — subtask-orchestrator handles memory updates internally after each specialist result. No additional action needed here.
   e. **Next task** — Proceed to next task in this phase.
3. **Phase complete** — Verify phase checkpoint criteria from Blueprint. Confirm system in working state before next phase.

Blocked or failed → re-run `/plan` with failure details + full state. Await updated Blueprint before continuing.

## Step 3: Finalize

All phases + tasks complete → return results for finalization. orchestrator's own flow handles `/finalize` — do NOT call `/complete` here.

Include in return: all commit hashes, task statuses per phase, any remaining items.

## Rules
- subtask-orchestrator must NOT call /execute
- Do NOT dispatch next task without completing evaluation
- Do NOT call subtask-orchestrator without complete Context Envelope
- Do NOT skip git commit — every task gets committed before next starts
- Do NOT skip phase checkpoints — verify working state between phases
- No limit on phases or tasks — execute all Blueprint defines

## Important
Run `run_slash_command` ('execute') always to load this context. Always re-run `/delegate` & `/execute` for each `new_task`.
