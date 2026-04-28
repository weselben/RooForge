---
name: forge
description: >
  Forge pipeline orientation skill. Loaded by all Forge modes on startup to
  understand orchestration pipeline, available commands, role boundaries,
  tool-use conventions. Single source of truth for how Forge modes interact.
---

# Forge — Pipeline Orientation

You are part of Forge orchestration pipeline. This skill defines how pipeline works, which commands available, how modes interact.

## On Load: Activate Caveman

Immediately after loading this skill, load caveman using `skill` tool with name `caveman`. This activates token-efficient communication across all pipeline interactions. Caveman defaults to **full** intensity — drop articles, fragments OK, short synonyms, no filler.

## Pipeline Flow

```
ask → architect → orchestrator → subtask-orchestrator → code/debug → git
```

Strict order non-negotiable. No mode skips phases or executes out of sequence.

## Working Memory

All modes share `.memory/` as working memory — gitignored, local only.
- **Read**: all modes — use `codebase_search` with query in `.memory/`, or read files directly
- **Write**: `architect` (`.md$`), `ask` (`.memory/` only), `code` (full edit), `debug` (built-in), `git` (`.memory/` only)
- **Delegate only**: `orchestrator` + `subtask-orchestrator` — never write directly, always delegate
- **Persist**: use `/memory` command to create indexed memory files
- **Naming**: `.memory/{topic}-{YYYY-MM-DD}-{HHMM}.md`

## Mode Roles

| Slug | Role | Delegates To |
|------|------|-------------|
| `orchestrator` | Strategic planning, task bounding, pipeline enforcement | `ask`, `architect`, `subtask-orchestrator`, `git` |
| `subtask-orchestrator` | Atomic task decomposition, specialist coordination | `code`, `debug`, `git`, `ask`, `architect` |
| `architect` | Technical reasoning, Blueprint creation, planning | `ask` (via /research), `code` (via /memory) |
| `ask` | Intel acquisition, web research, codebase analysis | None — leaf mode |
| `code` | Implementation, file creation, code modification | `debug` (via /debug on error) |
| `debug` | Error diagnosis and resolution | None — leaf mode |
| `git` | Conventional commits, branch management, repo integrity | None — leaf mode |

## Available Commands

All commands run via `run_slash_command` with command name as `command` parameter.

### Base Commands (used by all modes)

| Command | Purpose | When to Run |
|---------|---------|-------------|
| `/complete` | Format `attempt_completion` result (includes blocked variant) | Before every `attempt_completion` |
| `/delegate` | Format `new_task` message | Before every `new_task` |

### Flow Commands (mode-specific behavior)

| Command | Purpose | Used By |
|---------|---------|---------|
| `/clarify` | User clarification via `ask_followup_question` | `architect` |
| `/blueprint` | Phased planning methodology — break task into phases with individual tasks | `architect` |
| `/finalize` | Human-readable final output | `orchestrator` |

### Tool Commands (tool parameters + usage)

| Command | Purpose | Used By |
|---------|---------|---------|
| `/web` | Web search + URL reader via SearXNG MCP | `ask` |
| `/git` | Git operations (MCP-first, CLI fallback) | `git` |

### Delegation Commands (cascade to /delegate)

| Command | Purpose | Used By | Target Mode |
|---------|---------|---------|-------------|
| `/research` | Scope + delegate intel gathering | `architect`, `orchestrator` | `ask` |
| `/plan` | Send Master Context to architect | `orchestrator` | `architect` |
| `/execute` | Execute tasks phase by phase | `orchestrator` | `subtask-orchestrator` |
| `/debug` | Delegate error resolution | `code` | `debug` |
| `/memory` | Persist Blueprint to memory files | `*` | `code` |
| `/forge-init` | Initialize project workspace | `orchestrator` (first run) | `code` |

### Cascading Behavior

Commands reference each other to avoid duplication:
- `/research` → runs `/delegate` with mode `ask`
- `/plan` → runs `/delegate` with mode `architect` (who runs `/clarify` → `/blueprint` → `/memory` → `/complete`)
- `/execute` → runs `/delegate` with mode `subtask-orchestrator`, then `/delegate` with mode `git`
- `/debug` → runs `/delegate` with mode `debug`
- `/memory` → runs `/delegate` with mode `code`
- `/forge-init` → runs `/delegate` with mode `code`
- `/finalize` → formats `attempt_completion` for human consumption (no cascade)
- `/web` → direct MCP tool calls (no cascade)
- `/git` → MCP-first, CLI fallback (no cascade)

## Conventions

### Tool-Use-First Language
- Use tool names directly: "use `new_task` in `ask` mode" not "delegate to Ask"
- "When task completes" not "await the result"
- "Return via `attempt_completion`" not "report back to caller"

### Slug References
Always use mode slugs when referencing other modes:
- `ask` not "Ask mode" or "Ask"
- `architect` not "Architect mode"
- `orchestrator` not "Orchestrator"
- `subtask-orchestrator` not "Subtask-Orchestrator"
- `code` not "Code mode"
- `debug` not "Debug mode"
- `git` not "Git mode"

### Load Once
Most commands are references — run once, then use underlying tool or flow directly for subsequent calls. Each command's `## Important` section specifies what to do after loading.

**Always re-run:** `/delegate` (every `new_task`), `/complete` (every `attempt_completion`) — format discipline requires fresh loading each time.

### No Mode Switching
All modes forbidden from using `switch_mode`. All delegation uses `new_task`. All returns use `attempt_completion`.

### Context is Explicit
Never assume downstream modes have context. Every `new_task` must be self-contained with all relevant intel, Blueprint excerpts, context chains embedded explicitly.

## Quick Reference

```
Starting a project:   run /forge-init → creates .memory/, .gitignore, AGENTS.md, git init
Starting any task:    load 'forge' skill → load 'caveman' skill → understand pipeline + commands
Need user clarity:    run /clarify → structured ask_followup_question
Need web intel:       run /web → search + read URLs via SearXNG MCP
Need intel:           run /research → (cascades to /delegate with ask)
Need a Blueprint:     run /plan → (cascades to /delegate with architect)
Planning a Blueprint: run /blueprint → phased tasks with MVP-first ordering
Need to execute:      run /execute → (cascades to /delegate with subtask-orchestrator)
Hit an error (code):  run /debug → (cascades to /delegate with debug)
Git operations:       run /git → MCP-first, CLI fallback
Need to commit:       run /delegate with git mode
Persist knowledge:    run /memory → (cascades to /delegate with code)
Blocked:              run /complete with Blocked Variant → attempt_completion
Done with work:       run /complete → format attempt_completion
Final user output:    run /finalize → human-readable result
```
