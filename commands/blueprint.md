---
name: blueprint
description: >
  Architect planning methodology. Break task into phased tasks using
  planning-and-task-breakdown skill. Produces Blueprint organized into
  phases (MVP first) with individual tasks sized for engineer execution.
  Used by architect mode.
---

# /blueprint — Phased Planning Methodology

Intel sufficient + user clarity confirmed. Produce structured Blueprint of phased tasks.

## Step 1: Load Planning Skill

Use `skill` tool with name `planning-and-task-breakdown` → load full planning methodology. Apply its principles throughout.

## Step 2: Map Dependencies

Before writing tasks, map dependency graph:

- What depends on what
- What must be built first (foundations)
- What can run in parallel
- What is risky or unknown

Implementation order follows dependency graph bottom-up: foundations first.

## Step 3: Slice Vertically

Build one complete feature path at a time — NOT horizontal layers.

**Bad (horizontal):** All DB → All API → All UI
**Good (vertical):** Registration (schema + API + UI) → Login (auth + API + UI) → Dashboard (query + API + UI)

Each vertical slice = working, testable functionality.

## Step 4: Organize into Phases

Group tasks into logical phases. No limit on phase count. Order by:

1. **MVP first** — Phase 1 delivers minimum viable product
2. **Core next** — Phases 2-N build towards full goal
3. **Polish last** — Final phase handles edge cases, optimization, docs

Each phase ends with checkpoint: system in working, testable state.

## Task Structure

Each task follows this format:

### Task [Phase].[N]: [Short descriptive title]

**Description:** One paragraph — what this accomplishes + why. Architectural intent, not implementation detail. Define WHAT + WHY, not HOW.

**Acceptance criteria:**
- [Specific, testable condition]
- [Specific, testable condition]

**Verification:**
- [How to confirm completion — test command, file check, build status]

**Dependencies:** [Task references or "None"]

**Files likely touched:**
- `path/to/file`

**Scope:** [XS: 1 file | S: 1-2 files | M: 3-5 files | L: split further]

## Task Sizing

| Size | Files | Guidance |
|------|-------|----------|
| **XS** | 1 | Single function or config change |
| **S** | 1-2 | One component or endpoint |
| **M** | 3-5 | One feature slice |
| **L** | 5-8 | Break into smaller tasks |
| **XL** | 8+ | MUST break into smaller tasks |

If task is L or larger → split. Agents perform best on S + M tasks.

**When to split further:**
- Touches more than 5 files
- Cannot describe acceptance criteria in ≤3 bullets
- Touches ≥2 independent subsystems
- "and" appears in task title

## Planning Principles

1. **Order by dependency** — foundations before features
2. **Vertical slices** — complete feature paths, not horizontal layers
3. **Verifiable endpoints** — every task ends with something testable
4. **Scope discipline** — task needs >5 files → split
5. **No implementation detail** — WHAT + WHY, not HOW
6. **MVP-first** — Phase 1 must deliver working value
7. **Checkpoint between phases** — system stays working after each phase

## Output Format

```
BLUEPRINT — [Task Name]
==========================================

Phase 1: [MVP / Foundation Name]
  Checkpoint: [what working state this phase delivers]

  Task 1.1: [Title]
    Description: [what + why]
    Acceptance criteria:
      - [condition]
      - [condition]
    Verification: [how to confirm]
    Dependencies: [none or task refs]
    Files likely touched: [paths]
    Scope: [XS/S/M]

  Task 1.2: [Title]
    ...

Phase 2: [Core Feature Name]
  Checkpoint: [what working state this phase delivers]

  Task 2.1: [Title]
    ...

[Continue for as many phases as needed]
```

## Step 5: Persist Blueprint

Write the complete Blueprint to a single file in `.memory/`:

```
.memory/blueprint-{YYYY-MM-DD}.md
```

Use `write_to_file` to create `.memory/blueprint-{YYYY-MM-DD}.md` containing the full Blueprint output from the format above. This is mandatory — downstream modes (orchestrator, subtask-orchestrator) reference this file.

If a blueprint file already exists for today, overwrite it with the updated version.

Do NOT call `/memory` — the Blueprint file IS the memory artifact. No separate memory step needed.

## Rules
- No limit on phases or tasks — use as many as needed
- Every task must have all elements (Description, Acceptance criteria, Verification, Dependencies, Files, Scope)
- Do NOT include implementation details — subtask-orchestrator's job
- Do NOT provide time estimates — ever
- Task is scope L or XL → split before finalizing
- Phase 1 MUST deliver MVP — working, testable, valuable
- Every phase ends with checkpoint confirming working state
- Blueprint MUST be persisted to `.memory/blueprint-{YYYY-MM-DD}.md` — no exceptions
- Do NOT call /memory from /blueprint — the blueprint file is self-contained

## Important
Run `run_slash_command` ('blueprint') once to load this context → apply methodology directly. Blueprint self-persists to `.memory/` — no additional memory step required.
