---
name: execute
description: >
  Phase-based execution command. Navigate Blueprint phases, delegate
  each WHOLE phase to subtask-orchestrator (which internally decomposes it
  into individual new_task delegations to code/debug). Used by orchestrator
  mode. Cascades to /delegate with subtask-orchestrator + /delegate with git.
---

# /execute — Phase-Based Execution

Finalized Blueprint with phases + internal task definitions ready. Do NOT execute phases yourself (unless subtask-orchestrator). Navigate phases → delegate each WHOLE phase to subtask-orchestrator.

## Step 1: Plan All Phases

Write ALL phases + their internal tasks fully BEFORE starting execution. For each task define:

- **ID**: Phase.Task number (e.g., 1.1, 1.2, 2.1)
- **Objective**: single, clear outcome from Blueprint
- **Scope Boundary**: what is explicitly OUT of scope
- **Dependencies**: which prior tasks must complete first
- **Expected Output**: verifiable result confirming completion
- **Blueprint Excerpt**: exact governing section from Blueprint
- **Context Slice**: exact portion of State of Intel + Constraints relevant to this task

## Step 2: Execute Phase by Phase

Delegate ONE WHOLE phase at a time to subtask-orchestrator. Do NOT batch-dispatch phases.

For each phase:

1. **Phase checkpoint** — Verify prior phase checkpoint passed before starting this phase
2. **Delegate phase** — Run `/delegate` with mode `subtask-orchestrator`. Send WHOLE phase (all internal tasks + full Context Envelope) per `/delegate` format. subtask-orchestrator owns task-by-task breakdown internally via `new_task` calls to `code` / `debug` / `git`.
3. **Evaluate phase** — Phase completes → check: all internal tasks met Expected Output? New info changed plan? Incorporate feedback before proceeding.
4. **Commit** — Run `/delegate` with mode `git`. Include: phase context, files changed, commit scope.
5. **Memory** — subtask-orchestrator handles memory updates internally after each specialist result. No additional action needed here.
6. **Next phase** — Proceed to next phase.

Blocked or failed → re-run `/plan` with failure details + full state. Await updated Blueprint before continuing.

## Step 3: Finalize

All phases + internal tasks complete → return results for finalization. orchestrator's own flow handles `/finalize` — do NOT call `/complete` here.

Include in return: all commit hashes, task statuses per phase, any remaining items.

## Rules
- subtask-orchestrator must NOT call /execute
- Do NOT dispatch next phase without completing evaluation
- Do NOT call subtask-orchestrator without complete Context Envelope (whole phase, not single task)
- Do NOT skip git commit — every phase gets committed before next starts
- Do NOT skip phase checkpoints — verify working state between phases
- No limit on phases or tasks — execute all Blueprint defines

## Important
Run `run_slash_command` ('execute') once to load this context → apply flow directly. Always re-run `/delegate` for each `new_task` delegation within the phase loop.
