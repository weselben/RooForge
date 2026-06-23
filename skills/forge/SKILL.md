---
name: forge
description: >
  Forge pipeline orientation skill. Loaded by all Forge modes on startup to
  understand orchestration pipeline, available commands, role boundaries,
  tool-use conventions. Single source of truth for how Forge modes interact.
---

# Forge — Pipeline Orientation

You are part of Forge orchestration pipeline. This skill defines how pipeline works, which commands available, how modes interact.

## Glossary

| Abbreviation | Meaning |
|---|---|
| `SO` | Subtask Orchestrator (`subtask-orchestrator`) — planning coordination (prefix [PLAN]) / execution decomposition (prefix [EXEC]) |
| `Blueprint` | Phased task plan produced by `/blueprint` — contains phases, tasks, dependencies, acceptance criteria, and research references |
| `TL;DR` | Too Long; Didn't Read — brief summary at start of a document |
| `MANDATORY` | Non-negotiable instruction — must be executed without exception, never skipped, deferred, or omitted. Applies across all modes, commands, and loaded skills |

## Rules

All rules and custom instructions are **MANDATORY** and must be followed without exception.

- When delegated a task with `[PLAN]` prefix, **always** run `run_slash_command` with command `planning` immediately, its return and this statement should be seen as **MANDATORY** and always to be followed when [PLAN] is in place!

## MANDATORY: On Load Activate Caveman + Evaluate Available Skills

1. **Caveman**: Immediately load using `skill` tool with name `caveman`. Activates token-efficient communication across all pipeline interactions. Defaults to **full** intensity — drop articles, fragments OK, short synonyms, no filler.

2. **Skill evaluation**: After forge + caveman active, scan `<available_skills>` block in your system context. Each entry shows `name` + `description` — match against current task. Pipeline defaults (forge, caveman) already loaded. If any **user-installed** skill beyond defaults is relevant, load via `skill` tool and apply its guidance. Skip if no match. (mostly not applying if you are an orchestrator)

## Pipeline Flow

```
orchestrator → subtask-orchestrator ([PLAN] or [EXEC] prefix) → orchestrator → git → orchestrator
```

**subtask-orchestrator routing**: Task arrives with prefix. `[PLAN]` → planning lifecycle (clarify → research → architect → Blueprint). `[EXEC]` or no prefix → execution (decompose Blueprint → delegate to code/debug). Routing is determined by task prefix — see subtask-orchestrator's customInstructions for full flow.

Two distinct phases: (1) Planning — orchestrator delegates to SO with [PLAN] prefix who coordinates clarify, research, and architect to produce Blueprint. (2) Execution — orchestrator navigates Blueprint phases, delegates each to SO with [EXEC] prefix for atomic decomposition, commits after each phase via git. Strict order non-negotiable. No mode skips phases or executes out of sequence.

## Working Memory

All modes share `.memory/` as working memory — gitignored, local only.
- **Read**: all modes — use `codebase_search` with query in `.memory/`, or read files directly
- **Write**: all modes — use `run_slash_command` with command `memory` to write to `.memory/`
- **Structure**: `.memory/phase-{N}-{name}.md` (one per phase), `.memory/blocker-{desc}.md` (one per blocker), `.memory/research-{topic}-{date}.md` (one per research run), `.memory/memory.md` (general fallback)

## Mode Roles

| Slug | Role | Delegates To |
|------|------|-------------|
| `orchestrator` | Strategic planning, phase navigation, git commit after each phase | `subtask-orchestrator`, `git` |
| `subtask-orchestrator` | Planning coordination (clarify → research → architect) + atomic task decomposition | `code`, `debug`, `ask`, `architect` |
| `architect` | Technical reasoning, Blueprint creation, planning | `ask` (via /research) |
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

| Command | Purpose | Used By | Mandatory Skills |
|---------|---------|---------|-----------------|
| `/clarify` | User clarification via `ask_followup_question` | `architect` | **grill-me** |
| `/blueprint` | Phased planning methodology — break task into phases with individual tasks | `architect` | planning-and-task-breakdown |
| `/finalize` | Human-readable final output | `orchestrator` | — |

### Tool Commands (tool parameters + usage)

| Command | Purpose | Used By | Mandatory Skills |
|---------|---------|---------|-----------------|
| `/web` | Web search + URL reader via SearXNG MCP | `ask` | — |
| `/pdf` | PDF download via curl-download MCP + read via pdf-reader-mcp | `ask` | — |
| `/git` | Git operations (MCP-first, CLI fallback) | `git` | **conventional-commits** |

### Delegation Commands (cascade to /delegate)

| Command | Purpose | Used By | Target Mode |
|---------|---------|---------|-------------|
| `/research` | Scope + delegate intel gathering | `architect`, `orchestrator` | `ask` |
| `/plan` | Send Master Context to architect | `orchestrator` | `architect` |
| `/execute` | Execute tasks phase by phase | `orchestrator` | `subtask-orchestrator` |
| `/debug` | Delegate error resolution | `code` | `debug` |
| `/memory` | Append context to phase memory files | `*` | self (direct edit) |
| `/forge-init` | Initialize project workspace | `orchestrator` (first run) | `code` |

### Cascading Behavior

Commands reference each other to avoid duplication:
- `/research` → runs `/delegate` with mode `ask`
- `/plan` → runs `/delegate` with mode `subtask-orchestrator` (who runs `/planning` internally)
- `/planning` → SO lifecycle: `/clarify` → `/research` → `/clarify` → delegate to architect → `/blueprint` → review → summarize
- `/execute` → runs `/delegate` with mode `subtask-orchestrator` (no git — orchestrator delegates git separately after each phase)
- `/debug` → runs `/delegate` with mode `debug`
- `/memory` → direct edit by current mode (no delegation)
- `/forge-init` → runs `/delegate` with mode `code`
- `/finalize` → formats `attempt_completion` for human consumption (no cascade)
- `/web` → direct MCP tool calls (no cascade)
- `/pdf` → direct MCP tool calls via curl-download + pdf-reader-mcp (no cascade)
- `/git` → MCP-first, CLI fallback with branch setup (no cascade)

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
