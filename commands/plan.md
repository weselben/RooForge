---
name: plan
description: >
  Architectural grounding command. Send Master Context Package to architect
  mode for Blueprint creation. Used by orchestrator mode. Cascades to
  /delegate with architect mode. Architect runs /clarify, /blueprint,
  /memory, /complete internally.
---

# /plan — Architectural Grounding via architect Mode

Intel gathered, need technical Blueprint before implementation. Do NOT plan yourself (unless architect mode). Assemble + delegate Master Context Package to architect mode.

## Step 1: Assemble Master Context Package

Gather ALL of the following into single package. Do NOT summarize or trim.

### [A] Original User Goal
Full, unmodified user request. Paste verbatim.

### [B] Full State of Intel
COMPLETE, unabridged report from ask mode.
- Do NOT summarize — paste full report exactly as received
- Dropping intel = catastrophic failure

### [C] Known Constraints / Risks
Blockers, uncertainties, or limitations identified during intel gathering.
- If none identified → state: "No constraints or risks identified"

### [D] Orchestrator Observations
High-level notes connecting user goal to gathered intel.
- Patterns or gaps you see
- Which aspects need architectural decisions
- Any priority ordering you recommend

## Step 2: Delegate to architect Mode

Run `run_slash_command` with command `delegate` → format new_task.

Use mode: `architect`

Objective section must contain:
- Complete Master Context Package (all four elements above)
- Instruction: "Produce Blueprint using Forge planning methodology. Run /clarify if any ambiguity exists → /blueprint to structure Blueprint into phases + tasks → /memory to persist decisions → /complete to return."

## Step 3: Receive Blueprint

Task completes → returned Blueprint contains:
- Phases (MVP first) with individual tasks sized for engineer execution
- Dependency graph, vertical slices, checkpoint criteria
- Memory files persisted in `.memory/` + AGENTS.md updated

Use this Blueprint for phase-based sequential execution via /execute.

## Rules
- architect mode must NOT call /plan
- Do NOT trim or summarize State of Intel — completeness non-negotiable
- Do NOT skip to implementation without Blueprint — pipeline violation
- Do NOT modify Blueprint yourself — changes needed → re-run /plan with updated context

## Important
Run `run_slash_command` ('plan') once to load this context → apply flow directly. Always re-run `/delegate` for each `new_task`.
