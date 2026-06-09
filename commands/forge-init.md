---
name: forge-init
description: >
  Project initialization command. Run once when starting new project to
  create Forge workspace structure. Delegates to code mode for file
  creation. Creates .memory/, .gitignore, AGENTS.md, initializes git.
---

# /forge-init — Project Initialization

Starting new project. Initialize Forge workspace structure before any pipeline work. Do NOT call /forge-init if code mode — create files directly.

## Step 1: Check if Already Initialized

Look for `.memory/` directory + `AGENTS.md` in project root. Both exist → skip initialization, project already set up.

## Step 2: Delegate Initialization

Run `run_slash_command` with command `delegate` → format new_task.

Use mode: `code`

Objective section must instruct code mode to create ALL of following:

### `.memory/` Directory
Create working memory directory. Pipeline memory files live here. All modes read via `codebase_search` or direct file access. All modes write directly via `/memory` — no delegation needed.

### `.gitignore`
Create or append to `.gitignore`:
```
# Forge working memory (local only)
.memory/
```

### `AGENTS.md`
Create with initial structure:
```markdown
# AGENTS.md

## Documentation Sync Rule

> **⚠️ MANDATORY:** When updating this file (`AGENTS.md` at repo root), you **must** also review and update [`README.md`](README.md) at the same location. The two files must stay in sync:
>
> - **[`AGENTS.md`](AGENTS.md)** — LLM-optimized reference. Dense, structured, no prose fluff. Primary source for AI agents. But instructive like this statement if applicable.
> - **[`README.md`](README.md)** — Human-readable equivalent. Same information, friendlier presentation for developers, contributors or endusers.
>
> If a section is added/removed/changed in one file, the corresponding section **must** be updated in the other. Never let one file drift out of sync with the other.

## Project Nature
[Brief description based on user input — to be filled by architect]

## Forge Pipeline
This project uses Forge orchestration pipeline. All modes load 'forge' skill on startup for pipeline orientation, available commands, role boundaries.

## Memory Index
Memory files stored in `.memory/` (gitignored, local only).
- Use `codebase_search` with query "memory" to find relevant memory files.
- Check `.memory/` for cached intel + prior decisions before starting any task.
```

### Git Repository
Initialize git repo if one does not already exist:
```
git init
```

## Step 3: Confirm

Task completes → verify:
- `.memory/` directory exists
- `.gitignore` contains `.memory/`
- `AGENTS.md` exists with initial structure
- Git repository initialized

Run `/complete` before `attempt_completion`.

## Rules
- Do NOT call /forge-init if code mode — create files directly (you have edit permissions)
- Do NOT run if `.memory/` + `AGENTS.md` already exist
- Do NOT commit initialization — user decides when to make first commit
- `.memory/` = local working memory — never committed to version control
