# forge-init

One-shot bootstrap skill that prepares a repository for forge by creating or smart-appending `AGENTS.md` with the mandatory forge load rule, mandates rule, and jargon glossary, then runs a grilling session to capture repo-specific contract details. Runs once per repo; idempotent re-runs only update.

## When to load

- "bootstrap this repo for forge"
- "initialize forge in this repo"
- First session in a new repository before forge runs
- When `AGENTS.md` is missing or lacks the mandatory forge header

## How it works

1. **Create or smart-append AGENTS.md** (SKILL.md:19–36)
   - Read `./agents.template.md` as base template
   - If `AGENTS.md` absent at repo root: write template verbatim; load `use-git-identity` to verify ownership
   - If `AGENTS.md` exists: smart-append — preserve existing content, prepend mandatory header (forge load rule + mandates rule) if missing, merge jargon entries (skip duplicates)
   - Always append the no-commit footer once: `---` + "Do not commit or stage this file. Local changes only."
   - Never commit or stage `AGENTS.md`

2. **Grilling session for repo-specifics** (SKILL.md:38–54)
   - Load `grilling` skill; interview the user about the repo
   - After every 4 questions answered, adapt `AGENTS.md`:
     - Amend only non-obvious facts not inferable from reading the repo
     - Interpret into STE100 (one flowing sentence per term)
     - Never add deployment-specific or coding-stack-specific content (frameworks, ORMs, runtimes, languages)
     - Ask user: "Is this as intended?"
   - Frame every addition as goal-driven: "the goal is X, so the agent must Y" — no paths, no procedures
   - Completion when grilling frontier empty and user confirms contract

## Files in this skill

- `skills/forge-init/SKILL.md` — Main skill definition with steps, rules, and template reference
- `skills/forge-init/agents.template.md` — Template content for AGENTS.md (letter header, mandatory forge load rule, mandates rule, jargon glossary with forge terms: map, fog, frontier, ticket, domain-modeling, prototype, DPA, SDD, loops, resolving-merge-conflicts, forge-flow, goal)

## See also

- `grilling` — Used in step 2 to interview the user and capture repo-specific contract
- `use-git-identity` — Loaded to verify repo ownership before writing AGENTS.md
- `forge-flow` — Runs after forge-init; creates feat branch from main and sets harness goal
- `forge` — The orchestrator that forge-init prepares the repo for; loads automatically on session start
- `wayfinder` — Referenced in boundaries (scripts/setup-repo-gh-cli.sh initializes labels)

## Notes

- The `forge/SKILL.md` does not explicitly reference `forge-init`; forge-init runs before forge as a one-time setup.
- `agents.template.md` contains 15 lines covering the mandatory header and glossary; the "rest of this letter" placeholder is where grilling output is appended.
- The no-commit footer is a hard rule — AGENTS.md is a local contract, not a repo artifact.