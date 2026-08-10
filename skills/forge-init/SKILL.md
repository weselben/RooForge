---
name: forge-init
description: Bootstrap the repo for forge — create or smart-append AGENTS.md with forge-mandatory header, glossary, and goal-driven contract; run grilling to capture repo-specifics. One-shot.
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/forge-init/SKILL.md
disable-model-invocation: true
---

# Forge Init

One-shot bootstrap. Runs once per repo. Prepares the agent's local contract (AGENTS.md) so every session starts aligned.

## Steps

### 1. Create or smart-append AGENTS.md

Read `./agents.template.md`. Use it as the base.

**If AGENTS.md does not exist at repo root:**
- Write the template content verbatim as `AGENTS.md` at repo root.
- Load `use-git-identity` to check ownership. If repo is under the configured identity, proceed. If unclear, ask: "Create AGENTS.md with forge contract at repo root?"

**If AGENTS.md exists:**
- Smart-append: preserve existing content, prepend the template's mandatory header (forge load rule + mandates rule) if absent, merge jargon entries (skip duplicates), keep letter-style prose.
- Do not overwrite user-written sections.

**Always:**
- Append at bottom (once):
  ```
  ---
  Do not commit or stage this file. Local changes only.
  ```
- Never commit or stage AGENTS.md.

**Completion criterion:** AGENTS.md at repo root contains the mandatory header, the jargon letter, the no-commit footer.

### 2. Grilling session for repo-specifics

Load `grilling` skill. Interview the user about this repo.

After every grilling wave (4 questions answered), adapt AGENTS.md:
- Amend only non-obvious facts not inferable from reading the repo.
- Interpret user's language into STE100.
- Never add deployment-specific or coding-stack-specific content (frameworks, ORMs, runtimes, languages) — the agent reads the code for that.
- Ask the user: "Is this as intended?"
- Only add statements the you judge as unambiguous and valuable.

**During grilling:**
- Answer user questions back in STE100.
- Never emit code blocks. Never explain what code does. Never document other files.
- Goal-driven prompting: frame every addition as "the goal is X, so the agent must Y" — no paths, no procedures, only the contract.

**Completion criterion:** grilling frontier empty; AGENTS.md captures repo-specific contract.

## Rules

- **One-shot.** Run once. Idempotent re-runs only update.
- **Never commit AGENTS.md.** It is a local contract, not a repo artefact.
- **STE100 throughout.** Letter style; jargon: one flowing sentence per term.
- **Mandatory header lives at top of AGENTS.md.** Forge load rule + mandates rule. Never removed.
- **Grilling is mandatory.** Do not skip. User must confirm the contract.
- **Goal-driven.** Every addition to AGENTS.md states the goal, not the procedure.
- **No stack-specific content.** Frameworks, ORMs, runtimes, languages are inferable from the code — do not write them into AGENTS.md.

## Template

The template lives at `./agents.template.md`. Read it verbatim. It contains:

1. Letter header — "This is a letter from me to you"
2. Mandatory forge load rule
3. Mandates rule
4. Jargon — one flowing sentence per confusing term only

## Boundaries

Forge Init does not:
- Create docs folders (forge-flow handles work surface)
- Set git identity (use-git-identity does that)
- Initialise labels (wayfinder/scripts/setup-repo-gh-cli.sh does that)
- Chart maps or resolve tickets (forge does that)

It only ensures AGENTS.md exists with the contract, then grills for repo specifics.