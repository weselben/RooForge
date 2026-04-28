---
name: debug
description: >
  Error encounter protocol for code mode. Run when unexpected error
  occurs during implementation. Gathers Error Intel, cascades to
  /delegate with debug mode for deterministic error resolution.
---

# /debug — Error Encounter Protocol

Unexpected error during implementation (build failure, test failure, runtime error, lint error, or any blocker). Do NOT debug yourself (unless debug mode). Follow this protocol.

## Step 1: Gather Error Intel

Collect ALL of following before delegating:

### Error Output
Exact error message, stack trace, or failure output. Include verbatim — do not paraphrase.

### Implementation Context
What you were implementing when error occurred. Be specific:
- Which file, function, or component you were working on
- What change just made that triggered error
- Expected behavior vs. what happened

### Files Involved
All file paths + specific code changes made:
- Every file modified in current task
- Relevant line numbers where error manifests
- Files created vs. modified

### Task Objective
Original implementation goal from instructions. What were you trying to accomplish?

### Prior Success
What succeeded before error. What steps completed successfully in this task?

## Step 2: Delegate to debug Mode

Run `run_slash_command` with command `delegate` → format new_task.

Use mode: `debug`

Objective section must contain:
- Complete Error Intel gathered above
- Instruction: "Resolve error. Return fix via attempt_completion with file paths, line numbers, code changes made."

## Step 3: Apply + Verify

Task completes:
1. Apply returned fix to affected files
2. Re-run failing command, test, or build
3. Error resolved → continue implementation or run `/complete`
4. Unresolved → MAY run `/debug` ONE more time with updated context

## Step 4: Escalation Limit

Error persists after 2 debug attempts:
- STOP implementation
- Run `/complete` with status `blocked`
- Include: original task objective, all Error Intel, both debug attempt outputs
- State clearly: "BLOCKED — Unresolved Error"

## Rules
- debug mode must NOT call /debug
- Do NOT attempt trial-and-error fixes yourself (unless debug mode) → delegate immediately
- Do NOT retry more than twice → escalation mandatory after 2 failures
- Do NOT modify files outside error scope while debugging in progress
- ALWAYS verify fix resolves original error before continuing

## Important
Run `run_slash_command` ('debug') once to load this context → apply protocol directly. Always re-run `/delegate` for each `new_task`.
