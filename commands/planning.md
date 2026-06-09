---
name: planning
description: >
  Planning phase command. Used by subtask-orchestrator when orchestrator
  delegates a planning task. Guides the full planning lifecycle: clarify
  scope, research intel, delegate to architect for blueprint, review and
  summarize for orchestrator.
---

# /planning — Planning Phase (subtask-orchestrator)

Orchestrator delegated planning. You own the full lifecycle from user request to finalized Blueprint + context summary. Do NOT execute code — you are the planning coordinator.

## Flow

### 1. Clarify Scope

Run `run_slash_command` with command `clarify` → loads grill-me skill → interview user.

- Grills user on what they actually want
- Identifies scope boundaries, constraints, priorities
- Resolves ambiguity before any research begins
- Use your judgment: enough when clear direction exists, stop before over-clarifying

### 2. Research Intel

Run `run_slash_command` with command `research` → delegates to ask mode.

- Fill knowledge gaps identified during clarification
- Gather codebase patterns, library docs, existing implementations
- Ask mode returns "State of Intel" report with source citations

### 3. Clarify Research Results

Run `run_slash_command` with command `clarify` again if needed.

- Verify research matches user intent
- Surface any new questions raised by findings
- Only if genuinely needed — skip if research was clear and sufficient

### 4. Delegate to Architect

Run `run_slash_command` with command `delegate` → format new_task for architect mode.

- Include: original user request, full State of Intel, all clarification decisions
- Architect runs its own `/clarify` internally if ambiguities remain
- Architect produces Blueprint via `/blueprint`
- Architect may run `/memory` to persist decisions

### 5. Review Blueprint

When architect returns Blueprint:

- Review against user's original intent and goals
- Verify scope is correct, no missing phases
- If gaps exist → re-delegate to architect with specific feedback
- If Blueprint is solid → proceed to finalize

### 6. Finalize & Summarize

Read the Blueprint file written by architect. Produce a concise summary for orchestrator:

- **Context Map**: where each piece of intel lives (file paths, section references)
- **Phase Overview**: one-line description per phase
- **Key Decisions**: architectural choices made and why
- **Critical Dependencies**: what must happen in what order

Return this summary + Blueprint reference via `attempt_completion`.

## When to Use /clarify

- **Before research (MANDATORY):** scope the request — do not begin research until direction is clear
- **After research (optional):** verify findings match intent — skip if research was clear and sufficient  
- **After architect returns Blueprint (MANDATORY):** verify full scope and intent with user before finalizing

Use your judgment — enough clarification when direction is clear. Too much clarification = bloat. Still do all MANDATORY clarifications.

## Rules
- Do NOT implement code — you are planning only
- Do NOT skip research — intel grounds the Blueprint
- Do NOT finalize Blueprint without reviewing against user intent
- Do NOT over-clarify — stop when clear direction exists
- Always return context summary for orchestrator via attempt_completion
- Always run /complete before attempt_completion

## Important
Run `run_slash_command` ('planning') once to load this context → follow the flow. Always re-run `/delegate` for each `new_task`. Always re-run `/complete` before `attempt_completion`.
