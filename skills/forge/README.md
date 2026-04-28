<div align="center">

# 🧠 Forge Skill

**Pipeline orientation skill for the RooForge orchestration system**

</div>

---

## Overview

The Forge skill is loaded by all Forge modes on startup. It provides:

- Pipeline flow overview (ask → architect → orchestrator → subtask-orchestrator → code/debug → git)
- Available slash commands and their cascading relationships
- Mode role boundaries and delegation targets
- Tool-use-first language conventions
- Slug reference standards
- **Caveman auto-load** — immediately loads the `caveman` skill for token-efficient communication

## Installation

This skill is referenced by the Forge agent YAML files. To set it up:

1. Copy the `skills/forge/` directory to your `.roo/skills/` directory:
   ```bash
   cp -r skills/forge/ ~/.roo/skills/forge/
   ```

2. Ensure the slash commands are also installed (see root README.md for installation).

## How It Works

Each Forge mode's `roleDefinition` instructs the AI to initially load the `forge` skill. This gives the mode:

1. **Pipeline awareness** — understands the full flow and its position in it
2. **Command registry** — knows which commands are available and when to use them
3. **Conventions** — follows consistent tool-use-first language and slug references
4. **Caveman activation** — auto-loads the `caveman` skill for token-efficient communication (full intensity by default)

The skill itself does not execute anything — it orients the mode so that `customInstructions` can focus on flow-specific behavior only.

---

<div align="center">

*[⬆ Back to README](../../README.md)*

</div>
