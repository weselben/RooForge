# AGENTS.md

## Documentation Sync Rule

> **⚠️ MANDATORY:** When updating this file (`AGENTS.md` at repo root), you **must** also review and update [`README.md`](README.md) at the same location. The two files must stay in sync:
>
> - **[`AGENTS.md`](AGENTS.md)** — LLM-optimized reference. Dense, structured, no prose fluff. Primary source for AI agents. But instructive like this statement if applicable.
> - **[`README.md`](README.md)** — Human-readable equivalent. Same information, friendlier presentation for developers, contributors or endusers.
>
> If a section is added/removed/changed in one file, the corresponding section **must** be updated in the other. Never let one file drift out of sync with the other.

## Project Nature

Config-only repo — no build system, no package manager, no runtime code. Contains YAML mode export files for [Zoo Code](https://github.com/Zoo-Code-Org/Zoo-Code) that define a multi-agent orchestration pipeline, slash commands for standardized tool call formats, and a Forge skill for pipeline orientation.

## Architecture

The pipeline uses a **cascading command architecture**:
- **Agent YAML files** (`agents/*.yaml`) — contain only flow logic (which commands to run when)
- **Slash commands** (`commands/*.md`) — contain all format specifics, tool call structures, and behavioral details
- **Skills** (`skills/*/SKILL.md`) — loaded on-demand by modes via `skill` tool (see Skills section below)
- **Native rules** (`rules/git/`) — installed to `~/.roo/rules-git/`, enforce commit quality guardrails; supplements `/git`

Commands cascade into each other: `/plan` → `/delegate`, `/debug` → `/delegate`, etc. This eliminates duplication and makes updates easy — change a command once, all modes benefit.

## Validation & Testing

- No automated tests. Validate by importing `agents/*.yaml` into Zoo Code → Settings → Custom Modes → Import
- Verify mode activates correctly and integrates with the full pipeline (all 6 modes)
- YAML syntax must be valid — no linter configured, check manually
- Common failure: `customInstructions` uses YAML block scalars (`>-` or `|-`) — incorrect indentation breaks parsing silently
- Test slash commands by copying `commands/*.md` to `~/.roo/commands/` and verifying `run_slash_command` loads them
- Test Forge skill by copying `skills/forge/` to `~/.roo/skills/forge/` and verifying modes load it on startup

## Conventional Commits (Required)

Format: `<type>(<scope>): <subject>` — imperative mood, ≤72 chars, no trailing period.
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
Breaking: `feat!:` or `BREAKING CHANGE:` footer → major version bump.

## Release Pipeline

Push to `main` with changes under `agents/**`, `commands/**`, or `skills/**` triggers auto semantic versioning + GitHub Release via `.github/workflows/release.yml`. All 6 YAML files are attached as individual release assets, plus `commands.zip` and `skills.zip` archives.

## Branch Naming

Prefixes required: `feat/`, `fix/`, `docs/`, `refactor/`, `chore/` (e.g. `feat/add-debug-mode`).
Branch descriptions must use technical language only — no pipeline jargon (no phase/blueprint references in branch names or commit messages).

## PR Policy

PRs NOT automatically accepted. Must pass: (1) testing in Zoo Code, (2) evaluation for pipeline consistency, (3) implementation review.

## YAML Schema

Each file in `agents/` follows: `customModes` array with `slug`, `name`, `iconName`, `roleDefinition`, `whenToUse`, `description`, `groups` (permissions), `customInstructions`, `source`. All modes share persona name "Forge" — do not change.

## Pipeline Enforcement

Workflow: optional init via `/forge-init`, then planning (orchestrator → subtask-orchestrator → architect → Blueprint) and execution waves (orchestrator → subtask-orchestrator → code/debug → orchestrator → git after each phase). No mode switching — all delegation via `new_task`, all returns via `attempt_completion`. Architect restricted to `.md$` and `.memory/` file edits only.

All delegated agents persist relevant context to `.memory/` before completion so downstream tasks can reuse cached input and avoid regenerating context.

### MANDATORY Execution Rule

Every agent YAML, every command context, and every loaded skill can mark steps as **MANDATORY**. Any step so marked must be executed without exception — never skipped, deferred, or omitted. This applies globally across all modes and pipeline phases.

### Mode Capabilities

- `ask` mode: web research (`/web`), PDF acquisition (`/pdf`), codebase analysis, intel reports

### Command Registry

| Command | Purpose | Target Mode |
|---------|---------|-------------|
| `/web` | Web search + URL reader via SearXNG MCP | `ask` |
| `/pdf` | PDF download via curl MCP + read via pdf-reader-mcp | `ask` |
| `/git` | Git operations (MCP-first, CLI fallback) | `git` |

## Skills

All skills live in `skills/` and are loaded via the `skill` tool. Two load on startup (forge → caveman). Others load on-demand when triggered by specific commands.

| Skill | Load Timing | Purpose | Source |
|-------|-------------|---------|--------|
| [`skills/forge/SKILL.md`](skills/forge/SKILL.md) | **Startup** (all modes) | Pipeline orientation — flow, command registry, mode roles, conventions | Project-owned |
| [`skills/caveman/SKILL.md`](skills/caveman/SKILL.md) | **Startup** (auto-loaded by forge) | Token-efficient communication (full intensity default) | Project-owned |
| [`skills/grill-me/SKILL.md`](skills/grill-me/SKILL.md) | **Mandatory on `/clarify`** | Relentless user interview — stress-test every design decision until shared understanding | [mattpocock/skills](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md) |
| [`skills/planning-and-task-breakdown/SKILL.md`](skills/planning-and-task-breakdown/SKILL.md) | **On `/blueprint`** | Structured planning methodology for phased task breakdown | Project-owned |
| [`skills/subtask-breakdown/SKILL.md`](skills/subtask-breakdown/SKILL.md) | **On [EXEC]** | Atomic subtask decomposition — XS-sized tasks for code mode delegation | Project-owned |
| [`skills/deep-research/SKILL.md`](skills/deep-research/SKILL.md) | **Startup** (auto-loaded by ask mode, after forge) | Exhaustive deep research — 10+ iteration search loop, recursive reflection, markdown-native reports | [moweme](skills/deep-research/SKILL.md) |
| [`skills/conventional-commits/SKILL.md`](skills/conventional-commits/SKILL.md) | **Mandatory on `/git`** | Conventional Commits v1.0.0 format reference — types, SemVer mapping, breaking changes | Project-owned |

### Skill Loading Rules

- Forge + caveman: always loaded first (non-negotiable)
- grill-me: **mandatory** on every `/clarify` invocation — do not skip
- planning-and-task-breakdown: loaded by architect during `/blueprint`
- subtask-breakdown: loaded by subtask-orchestrator during `[EXEC]` phase
- conventional-commits: **mandatory** on every `/git` invocation — load before creating commit messages
- Other user-installed skills: evaluated per forge skill's "Skill evaluation" step

## Native Rules

All rules live in `rules/` and are installed to `~/.roo/rules-git/` via Zoo Code native rules mechanism.

| Rule | Install Path | Purpose |
|------|-------------|---------|
| [`rules/git/mandatory-commit-guardrail.md`](rules/git/mandatory-commit-guardrail.md) | `~/.roo/rules-git/` | Git commit subject enforcement — anti-pattern detection, pipeline jargon ban, DO/DON'T guardrails. Supplements `/git`. |

### Rule Loading Rules

- Native rules are loaded automatically by Zoo Code when the rule's file pattern matches
- The git commit guardrail rule **must** load `/git` via `run_slash_command` first (see rule content for enforcement details)

## MCP Servers

| Server | Required By | Purpose | Tools |
|--------|-------------|---------|-------|
| **SearXNG** | `ask` | Web search & URL reading | `searxng_web_search`, `web_url_read` |
| **curl-download** | `ask` | PDF download from URLs | `curl_download` (1) |
| **pdf-reader-mcp** | `ask` | Extract and parse text from PDFs | `read_pdf`, `search_pdf`, `inspect_pdf`, `ocr_pages`, `analyze_regions`, `extract_regions`, `render_page` |
| **Git MCP** | `git` | Git operations | 20+ tools |

## Key Docs

- `README.md` — Pipeline Mermaid diagrams, mode descriptions, install instructions
- `CONTRIBUTING.md` — Full simulated agent flow walkthrough (lines 124-303), commit conventions, PR process
- `skills/forge/SKILL.md` — Pipeline orientation, command registry, conventions
- `skills/caveman/SKILL.md` — Token-efficient communication (auto-loaded by forge skill)
- `skills/grill-me/SKILL.md` — Relentless interview protocol (mandatory on `/clarify`)
- `mcp.md` — MCP server configuration (SearXNG + curl-download + pdf-reader-mcp + Git MCP)
- `commands/pdf.md` — PDF download command via curl-download MCP
- `rules/git/mandatory-commit-guardrail.md` — Git commit guardrails (installed to `~/.roo/rules-git/`)

## Directory Structure

All directory contents are documented in the root `README.md` repository structure tree. When adding new files to `agents/`, `commands/`, `skills/`, or `rules/`, update the root `README.md` accordingly.

## About contributions (any git actions)

Any changes to commands/*, agents/*, skills/* are never docs commits, as this in this project is the actuall "code" so here fix feat or similiar commits should be made but **NEVER** docs!
