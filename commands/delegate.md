---
name: delegate
description: >
  Standardized new_task format. Run before creating new_task to ensure
  delegated task contains all required context. All Forge modes that
  delegate use this for consistent, self-contained task envelopes.
---

# /delegate — New Task Format

Delegate work to another mode via `new_task`. Format message with **ALL** sections below. Every delegated task must be self-contained + deterministic — receiving mode has NO prior context.

## Required Sections

### 1. Objective
Specific atomic objective. One job only.
- Must be single, verifiable deliverable
- Can split into two independent units → NOT atomic → split first
- Start with verb: "Create...", "Fix...", "Research...", "Implement..."

### 2. Blueprint
Relevant excerpt from Architect's Blueprint governing this task.
- Paste exact section — do NOT summarize or "see above"
- No Blueprint exists (e.g., direct research) → state: "No Blueprint — direct task"

### 3. Intel
Relevant "State of Intel" from ask mode.
- Paste exact intel slice needed — do NOT "refer to prior context"
- Include source citations (URLs, file paths) from original intel
- No intel gathered → state: "No prior intel — first-party task"

### 4. Context Chain
Execution trace up to this point:
```
Context Chain: [did X] → [then did Y] → [currently doing Z] → [blocker if any]
```
- Enables receiving mode to understand what preceded this task
- First task in sequence → state: "Context Chain: [starting]"

### 5. Prior Context
Special context from prior subtasks affecting this one.
- Decisions made in earlier steps constraining this task
- Files already created or modified by prior tasks
- No prior context → state: "No prior context — initial task"

### 6. Constraint
Always include this exact instruction at end:
```
You are a deterministic specialist. Complete the specific task provided and return
the result via attempt_completion. DO NOT swap modes.
```

## Format Template

```
## Objective
[one atomic job]

## Blueprint
[exact excerpt or "No Blueprint — direct task"]

## Intel
[exact intel slice or "No prior intel — first-party task"]

## Context Chain
[did X] → [then Y] → [currently Z] → [blocker if any]

## Prior Context
[relevant prior decisions/changes or "No prior context — initial task"]

## Constraint
You are a deterministic specialist. Complete the specific task provided and return
the result via attempt_completion. DO NOT swap modes.
```

## Rules
- Do NOT assume receiving mode has prior context — embed everything explicitly
- Do NOT reference "conversation above" or "previous messages"
- Do NOT bundle multiple objectives into one task — one job per new_task
- Do NOT skip sections — every section must be present
