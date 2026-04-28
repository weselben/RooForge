# Agent Rules Standard (AGENTS.md):

# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Nature

Config-only repo — no build system, no package manager, no runtime code. Contains YAML mode export files for [Roo Code](https://github.com/RooCodeInc/Roo-Code) that define a multi-agent orchestration pipeline, slash commands for standardized tool call formats, and a Forge skill for pipeline orientation.

## Architecture

The pipeline uses a **cascading command architecture**:
- **Agent YAML files** (`agents/*.yaml`) — contain only flow logic (which commands to run when)
- **Slash commands** (`commands/*.md`) — contain all format specifics, tool call structures, and behavioral details
- **Forge skill** (`skills/forge/SKILL.md`) — pipeline orientation loaded by all modes on startup

Commands cascade into each other: `/plan` → `/delegate`, `/debug` → `/delegate`, etc. This eliminates duplication and makes updates easy — change a command once, all modes benefit.

## Validation & Testing

- No automated tests. Validate by importing `agents/*.yaml` into Roo Code → Settings → Custom Modes → Import
- Verify mode activates correctly and integrates with the full pipeline (all 6 modes)
- YAML syntax must be valid — no linter configured, check manually
- Common failure: `customInstructions` uses YAML block scalars (`>-` or `|-`) — incorrect indentation breaks parsing silently
- Test slash commands by copying `commands/*.md` to `~/.roo/commands/` and verifying `run_slash_command` loads them
- Test Forge skill by copying `skills/forge/` to `~/.roo/skills/forge/` and verifying modes load it on startup

## Conventional Commits (Required)

Format: `<type>(<scope>): <subject>` — imperative mood, ≤72 chars, no trailing period.
Types: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `style`, `perf`, `ci`, `revert`
Breaking: `feat!:` or `BREAKING CHANGE:` footer → major version bump.

## Release Pipeline

Push to `main` with changes under `agents/**` triggers auto semantic versioning + GitHub Release via `.github/workflows/release.yml`. All 6 YAML files are attached as release assets.

## Branch Naming

Prefixes required: `feat/`, `fix/`, `docs/`, `refactor/`, `chore/` (e.g. `feat/add-debug-mode`).

## PR Policy

PRs NOT automatically accepted. Must pass: (1) testing in Roo Code, (2) evaluation for pipeline consistency, (3) implementation review.

## YAML Schema

Each file in `agents/` follows: `customModes` array with `slug`, `name`, `iconName`, `roleDefinition`, `whenToUse`, `description`, `groups` (permissions), `customInstructions`, `source`. All modes share persona name "Forge" — do not change.

## Pipeline Enforcement

Strict order: ask → architect → orchestrator → subtask-orchestrator → code/debug → git. No mode switching — all delegation via `new_task`, all returns via `attempt_completion`. Architect restricted to `.md$` and `.memory/` file edits only.

## Key Docs

- `README.md` — Pipeline Mermaid diagrams, mode descriptions, install instructions
- `CONTRIBUTING.md` — Full simulated agent flow walkthrough (lines 124-303), commit conventions, PR process
- `skills/forge/SKILL.md` — Pipeline orientation, command registry, conventions
- `skills/caveman/SKILL.md` — Token-efficient communication (auto-loaded by forge skill)
- `mcp/searxng.md` — SearXNG MCP server setup (Ask mode web search)
- `mcp/git-mcp-server.md` — Git MCP server setup (Git mode operations)

## Directory Structure

All directory contents are documented in the root `README.md` repository structure tree. When adding new files to `agents/`, `commands/`, `mcp/`, or `skills/`, update the root `README.md` accordingly.
