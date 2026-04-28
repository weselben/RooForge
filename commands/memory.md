---
name: memory
description: >
  Memory persistence command. Run after completing Blueprint to create
  indexed memory files in .memory/ + update AGENTS.md. Cascades to
  /delegate with code mode for file write permissions. All modes read
  memory via codebase_search or direct file access.
---

# /memory — Blueprint Persistence + Knowledge Base Update

Blueprint complete. Before returning, persist key decisions + context so future pipeline runs can reference them. Do NOT call /memory if code mode — write to .memory/ directly.

## .memory/ Working Memory

`.memory/` directory = pipeline working memory — gitignored, local only. All modes read from it when encountering unknowns. Modes with edit permissions (`architect`, `code`, `debug`) write directly; `ask` delegates writes to `code` via `/delegate`.

### Reading Memory
Use `codebase_search` with relevant query to find memory files:
```
codebase_search: query "api design decisions", path ".memory"
```
Or read files directly from `.memory/` when filename known.

### File Naming Schema
```
.memory/{topic}-{YYYY-MM-DD}-{HHMM}.md
```
Example: `.memory/api-design-2026-04-28-0145.md`

### File Structure
Each memory file contains:
- **Topic**: what this memory covers
- **Date**: when created
- **Decisions**: what was decided + why
- **Rationale**: why alternatives rejected
- **Related Tasks**: which tasks this affects

## Step 1: Identify Memory-Worthy Content

From completed work, extract:

- Architecture choices + rationale
- Technology selections + why alternatives rejected
- Project structure insights discovered during planning or execution
- Constraints that shaped Blueprint
- Task summaries per phase (objective, scope, deps, verification)
- Key findings, errors encountered, patterns discovered during implementation

Keep as concise references, not full documentation.

## Step 2: Create Memory Files

Run `run_slash_command` with command `delegate` → format new_task.

Use mode: `code`

Objective section must instruct code mode to:

1. Create memory files in `.memory/` using naming schema above
2. Update `AGENTS.md` — append "Memory Index" section referencing new files (do this periodically, roughly every 10th memory write, or when project structure changes significantly)
3. Verify files created + AGENTS.md valid markdown

## Step 3: Confirm

Task completes → verify:
- Memory files exist in `.memory/` with correct naming + content
- AGENTS.md contains updated Memory Index
- No syntax errors in created files

Include confirmation in `/complete` output.

## Rules
- Do NOT call /memory if code mode — write to .memory/ directly (you have edit permissions)
- Do NOT create memory files yourself — only `.md$` edit permissions
- Do NOT skip this step — memory persistence mandatory for pipeline continuity
- Do NOT overwrite existing memory files — append or create new ones
- Keep memory files concise — reference indices, not documentation

## Important
Run `run_slash_command` ('memory') once to load this context → apply flow directly. Always re-run `/delegate` for each `new_task`.
