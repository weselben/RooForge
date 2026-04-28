---
name: research
description: >
  Research delegation command. Scope intel request from ask mode.
  Defines how to scope research request, cascades to /delegate for
  consistent new_task formatting. Used by architect + orchestrator.
---

# /research — Intel Delegation via ask Mode

Need external information or deeper codebase intel NOT in current context. Do NOT perform web research yourself (unless ask mode). Scope + delegate research task to ask mode.

## Step 1: Define Research Scope

Before delegating, explicitly define ALL of following:

### What is needed
Specific information, documentation, or analysis required.
- Be precise: "Express.js v4 routing API for parameter handling" not "Express docs"
- List each distinct piece of information as separate item

### Why it is needed
Connect each research item to part of your task it enables.
- "Need X to decide between approach A + B for API layer"
- "Need Y to understand existing DB schema before designing migration"

### Source priority
Where to look first:
- `codebase` — search local repo for patterns, configs, existing implementations
- `web` — search external docs, APIs, library docs
- `.memory/` — check working memory for previously cached intel
- Order matters: list sources in priority sequence

### Expected answer format
How result should be structured:
- "API endpoint signatures with parameter types"
- "Existing model schema with field names + relations"
- "Step-by-step migration guide with commands"

## Step 2: Delegate

Run `run_slash_command` with command `delegate` → format new_task.

Use mode: `ask`

Include full Research Scope (all four elements above) as Objective section.

## Step 3: Use Result

Task completes → returned "State of Intel" report contains:
- Structured findings with source citations (URLs, file paths)
- Code snippets or config excerpts where relevant
- Constraints or limitations discovered during research

Use this intel to ground reasoning. Do NOT assume information exists without verification.

## Rules
- Do NOT perform web research yourself (unless ask mode) → delegate to ask mode
- ask mode must NOT call /research
- Do NOT assume `.memory/` is populated — verify or let ask mode check
- Do NOT bundle unrelated research questions — one scope per /research call
- Insufficient results → refine scope + run /research again with tighter parameters

## Important
Run `run_slash_command` ('research') once to load this context → apply flow directly. Always re-run `/delegate` for each `new_task`.
