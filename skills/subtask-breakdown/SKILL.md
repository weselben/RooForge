---
name: subtask-breakdown
description: >
  Atomic subtask decomposition for execution. Used by subtask-orchestrator
  during [EXEC] phase. Breaks Blueprint tasks into XS and S units delegateable
  to code mode. No planning — assumes Blueprint already exists. Uses
  run_slash_command with command 'plan' to get the blueprint straight from
  the planning skill.
---

# Subtask Breakdown

## Overview

Decompose Blueprint tasks into atomic subtasks that can be delegated to `code` mode. Subtasks must be **XS or S** sized — M is explicitly disallowed. This is the execution-phase counterpart to planning — we assume a Blueprint already exists.

## When to Use

- Subtask-orchestrator receives [EXEC] task (or no prefix) with a Blueprint
- Need to split a Blueprint phase into delegateable units
- Each unit must be implementable by code mode in one focused session

**When NOT to use:** No Blueprint exists. Run `run_slash_command` with command `plan` to get the Blueprint first. Do not plan yourself.

## The Decomposition Process

### Step 1: Load the Blueprint

Use `run_slash_command` with command `plan` to get the Blueprint straight from the planning skill. This gives you the phased task breakdown with dependencies and acceptance criteria already defined. Do not re-plan — use the Blueprint as-is.

### Step 2: Evaluate the Phase

Read the relevant phase from the Blueprint. Identify:
- Tasks in this phase
- Their dependencies (what must happen first)
- Which tasks are independent (can run in parallel if multiple agents available)

### Step 3: Split into XS or S Subtasks

Every subtask must fit **XS or S** size. **M is explicitly disallowed** — never delegate an M-sized subtask to code mode.

| Size | Files | Scope | Delegateable to code? |
|------|-------|-------|----------------------|
| **XS** | 1 | Single function or config change | ✅ Yes — ideal |
| **S** | 1-2 | One component or endpoint | ✅ Yes — acceptable |
| **M** | 3-5 | One feature slice | ❌ No — EXPLICITLY DISALLOWED. Break down further |
| **L** | 5-8 | Multi-component feature | ❌ No — break down further |
| **XL** | 8+ | Too large | ❌ No — break down further |

**When to split further vs. keep as S:**
- **Split further** if the S task can be divided into two independent units that each deliver value (e.g., "create button component" and "add button hover state" are independent)
- **Keep as S** if the Blueprint phase excerpt already describes a coherent, inseparable unit that naturally spans 2 files (e.g., "add new API endpoint + its corresponding DTO") — do NOT split just to be smaller if it breaks logical coherence

**Rules for XS and S:**
- If a subtask can be split into two independent units **without breaking logical coherence**, split it
- One subtask = one logical job, ideally one file change
- No "and" in the subtask title (sign of two tasks)
- Acceptance criteria must be ≤3 bullet points
- M is never acceptable — always break down to XS or S

### Step 4: Apply Vertical Slicing

Build one complete vertical slice at a time, not horizontal layers:

**Bad (horizontal):**
```
Subtask 1: Build all database schema
Subtask 2: Build all API endpoints
Subtask 3: Build all UI components
```

**Good (vertical):**
```
Subtask 1: User can create an account (schema + API + UI for registration)
Subtask 2: User can log in (auth schema + API + UI for login)
```

Each vertical slice delivers working, testable functionality.

### Step 5: Format for Delegation

For each subtask, use `run_slash_command` with command `delegate` to format the `new_task`. Include ALL sections:

```markdown
## Objective
[one atomic job — start with verb]

## Blueprint
[exact excerpt from Blueprint for this subtask]

## Intel
[exact intel slice or "No prior intel — first-party task"]

## Context Chain
[did X] → [then Y] → [currently Z]

## Prior Context
[relevant prior decisions/changes or "No prior context — initial task"]

## Constraint
You are a deterministic specialist. Complete the specific task provided and return
the result via attempt_completion. DO NOT swap modes.
```

### Step 6: UI/UX Prefix Injection

When a subtask involves UI/UX work, prepend `[UXUI]` to the Objective:

```markdown
## Objective
[UXUI] Fix contrast ratios on primary buttons to meet WCAG 2.1 AA (4.5:1)
```

This triggers code mode to run `/ui-ux` and load design + accessibility skills.

UI/UX keywords: design, styling, theme, visual, layout, component, accessibility, WCAG, responsive, animation, motion, hover, transition, color, typography, spacing, token, breakpoint, ARIA, contrast, screen reader.

## Subtask Template

```markdown
## Subtask [N]: [Short descriptive title]

**Description:** One sentence explaining what this subtask accomplishes.

**Acceptance criteria:**
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]

**Verification:**
- [ ] Build succeeds / tests pass / manual check

**Dependencies:** [Subtask numbers this depends on, or "None"]

**Files likely touched:**
- `src/path/to/file.ts`

**Estimated scope:** XS (1 file, 1 function) or S (1-2 files, one component)
```

## Decomposition Rules

1. **No planning:** Use the Blueprint as-is. Do not re-plan or re-architect.
2. **XS and S preferred, M explicitly disallowed:** If a subtask is M or larger, break it down further. M is never acceptable.
3. **Split only when logically coherent:** Do not split a well-structured S task into two XS tasks if it breaks logical unity (e.g., an API endpoint + its DTO belong together as S).
4. **Self-contained:** Every subtask must include all context needed — no "see above" references.
5. **Sequential when dependent:** If B depends on A, delegate A first, wait for result, then delegate B.
6. **Parallel when independent:** If A and B are independent, delegate both (if multi-agent support available).
7. **Memory after each:** After each subtask result, run `run_slash_command` with command `memory` to persist insights.
8. **Verify before next:** Check specialist output before triggering the next subtask.

## Red Flags

- Subtasks that touch >2 files (S max is 2 files)
- Subtasks with >3 acceptance criteria
- Subtasks with "and" in the title
- Subtasks without a Blueprint excerpt
- Subtasks that require planning (re-architecting, schema changes, API design)
- Any subtask estimated at M, L, or XL size

## Verification

Before delegating, confirm:

- [ ] Every subtask is XS or S sized (max 2 files)
- [ ] No subtask is M or larger — M is explicitly disallowed
- [ ] Every subtask has a Blueprint excerpt
- [ ] Dependencies are identified and ordered correctly
- [ ] UI/UX subtasks have `[UXUI]` prefix in Objective
- [ ] No subtask requires planning or re-architecting
- [ ] Split decisions preserve logical coherence
