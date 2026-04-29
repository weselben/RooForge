---
name: finalize
description: >
  Orchestrator finalization command. Run when all phases complete to
  produce human-readable final result. NOT technical AI output — this
  is what user sees as deliverable.
---

# /finalize — Human-Readable Final Result

All phases complete. Produce final output for human user. NOT a technical report — clear, readable summary of what was accomplished.

## Pre-Flight: Memory Reconciliation

Before formatting `attempt_completion`, perform these steps **in order**:

### 1. Read All Memory Context
Read every file in `.memory/` — phase files, blocker files, research files, and `memory.md`. Use `list_files` on `.memory/` to discover all files, then `read_file` each one.

### 2. Verify Completeness
Cross-reference all memory content against subtask output:
- Every task recorded in phase files → confirmed done in output
- Every blocker file → confirmed resolved or documented as known limitation
- Every research finding → incorporated or explicitly scoped out
- If gaps found → state them honestly in Known Limitations, do NOT silently skip

### 3. Consolidate AGENTS.md
Merge existing `AGENTS.md` with all `.memory/` content into one comprehensive, pipeline-agnostic `AGENTS.md`:
- Preserve all existing sections from `AGENTS.md`
- Incorporate relevant decisions, findings, and context from memory files
- Remove pipeline-specific jargon — make it usable by any agent, not just Forge pipeline
- Write the consolidated file to `AGENTS.md` at project root

### 4. Clean Up Memory
Remove all files from `.memory/` directory. The consolidated `AGENTS.md` now holds all persistent context. Use `execute_command` with `rm -rf .memory/*` to clean up.

Once all four steps are done, proceed to `attempt_completion` using the Format below.

## Format

`attempt_completion` result must be structured for human consumption:

### What Was Done
Clear, jargon-free summary of completed work:
- What user asked for (in their words)
- What was delivered (in plain language)
- Key files or components created/modified (with paths for reference)

### How to Use It
Practical next steps for user:
- How to verify work (e.g., "run `bun test` to see all tests pass")
- Any manual steps needed (e.g., "add API key to .env")
- How to interact with new features (e.g., "visit /api/v1/preferences")

### What Changed
Concise changelog for user:
- New files created (list with one-line descriptions)
- Existing files modified (list with what changed)
- Dependencies added (if any)
- Configuration changes required (if any)

### Known Limitations
Honest assessment of what was NOT done or has caveats:
- Features intentionally scoped out
- Known edge cases not handled
- Performance considerations
- If none → state "No known limitations"

## Tone Guidelines

- Write for human who submitted request, not another AI
- Plain language — avoid pipeline jargon (no "Phases", "Context Envelopes", "State of Intel")
- Direct + specific — no hedging or filler
- Include file paths so user can find things
- Something went wrong or scoped out → say so clearly

## Rules
- Do NOT include Context Chain, Blockers, or Proof sections — those for /complete (internal pipeline use)
- Do NOT use technical pipeline terminology
- Do NOT omit known limitations — honesty over polish
- This is ONLY output human sees — make it count

## Important
Run `run_slash_command` ('finalize') once to load this context → apply format directly.
