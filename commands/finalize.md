---
name: finalize
description: >
  Orchestrator finalization command. Run when all phases complete to
  produce human-readable final result. NOT technical AI output — this
  is what user sees as deliverable.
---

# /finalize — Human-Readable Final Result

All phases complete. Produce final output for human user. NOT a technical report — clear, readable summary of what was accomplished.

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
