---
name: plan
description: >
  Planning delegation command. Routes user request to subtask-orchestrator
  for the full planning lifecycle (clarify, research, architect, blueprint).
  Used by orchestrator mode. Cascades to /delegate with subtask-orchestrator.
  Subtask-orchestrator runs /planning internally.
---

# /plan — Planning via subtask-orchestrator

Need technical Blueprint before implementation. Do NOT plan yourself (unless subtask-orchestrator). Delegate planning task to subtask-orchestrator who owns the full planning lifecycle.

## Step 1: Delegate to subtask-orchestrator

Run `run_slash_command` with command `delegate` → format new_task.

Use mode: `subtask-orchestrator`

Objective section must contain:
- Prefix: `[PLAN]` (mandatory — subtask-orchestrator uses this to route to planning flow)
- Full, unmodified user request — paste verbatim
- Instruction: "Run /planning to produce Blueprint. This is a planning phase — you will clarify scope, research intel, delegate to architect for Blueprint, review, and return summary."

## Step 2: Receive Blueprint

Task completes → returned output contains:
- Blueprint with phases (MVP first) + individual tasks sized for engineer execution
- Context Map: where each piece of intel lives (file paths, section references)
- Phase Overview: one-line description per phase
- Key Decisions: architectural choices made and why
- Critical Dependencies: what must happen in what order

Use this Blueprint + context summary for phase-based sequential execution via /execute.

## Rules
- subtask-orchestrator must NOT call /plan
- Do NOT skip to implementation without Blueprint — pipeline violation
- Do NOT modify Blueprint yourself — changes needed → re-run /plan with updated context
- Orchestrator is a pure delegator for planning — do NOT do research or architect work yourself

## Important
Run `run_slash_command` ('plan') once to load this context → apply flow directly. Always re-run `/delegate` for each `new_task`.
