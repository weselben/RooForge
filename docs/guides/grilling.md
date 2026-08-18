# grilling

Grilling is an interrogation skill that relentlessly questions the user about a plan, decision, or idea to reach a shared understanding. It maps the discussion as a design tree where every decision branches into dependent decisions, working the tree in waves of up to 4 questions per round until the frontier is empty.

## When to load

- User says "grill me" or uses any "grill" trigger phrase
- User wants to stress-test their thinking on a plan or design
- A wayfinder map ticket carries the `wayfinder:grilling` label (invoked by forge during the Resolve step)

## How it works

1. **Build the design tree** — map every decision as a node; dependent decisions branch off as children
2. **Identify the frontier** — collect all decisions whose prerequisites are already settled (questions that can be asked now without guessing)
3. **Ask the whole frontier in one wave** — format each question as:
   ```
   ❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

   ➡️ <your recommended answer>
   ```
   Maximum 4 questions per wave (`skills/grilling/SKILL.md:21`)
4. **Wait for user answers** — each answer reshapes the tree; settled decisions push the frontier outward
5. **Recompute the frontier** — questions depending on still-open questions from this round belong to a later round
6. **Dispatch sub-agents for facts** — when a frontier question needs an environmental fact (filesystem, tools), spawn a sub-agent to find it; don't ask the user for lookups (`skills/grilling/SKILL.md:15-16`)
7. **Repeat** — chain additional waves as needed; no limit on wave count (`skills/grilling/SKILL.md:22-23`)
8. **Done when frontier is empty** — every branch visited, nothing silently assumed; wait for user confirmation of shared understanding before acting (`skills/grilling/SKILL.md:17-18`)

In forge's orchestration (`skills/forge/SKILL.md:51-56`), after a grilling ticket closes, forge invokes `Skill(skill='domain-modeling')` to sweep for new terms (update `docs/dev/CONTEXT.md`) and decisions worth recording (add ADR to `docs/adr/`).

## Files in this skill

- `skills/grilling/SKILL.md` — Main skill definition with the interview protocol, wave discipline, and design-tree mechanics

## See also

- **forge** — Orchestrator that loads grilling as a `wayfinder:grilling` ticket type during the Resolve step; runs grilling tickets one per session (`skills/forge/SKILL.md:51`)
- **domain-modeling** — Invoked by forge after every grilling ticket closes to capture new domain terms and ADRs (`skills/forge/SKILL.md:54-56`)
- **deep-research** — Used in parallel during map charting (forge step 1) for fog-area research; shares the recursion/wave principle (`skills/forge/SKILL.md:35-37`, `skills/grilling/SKILL.md:22-23`)
- **dispatching-parallel-agents** — Forge uses it for parallel map work (fog areas) and deep-research sub-questions; grilling uses it for fact-finding sub-agents (`skills/forge/SKILL.md:35-37`, `skills/grilling/SKILL.md:15-16`)
- **wayfinder** — Map system that carries grilling tickets; loaded by forge at session start (`skills/forge/SKILL.md:17`)
- **caveman** — Always loaded at ultra intensity by forge; grilling output follows caveman format (`skills/forge/SKILL.md:14`)

## Notes

- The grilling skill directory contains only `SKILL.md` — no scripts, templates, or companion files
- The skill references a source URL (`https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md`) in its frontmatter but no local files depend on it
- No `grill-me` skill exists in this repo; the forge skill references grilling directly by name