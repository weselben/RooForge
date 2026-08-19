# deep-research

Exhaustive evidence-based research skill that runs a minimum of 10 search iterations per topic with recursive reflection (Think/Summary after each round), synthesizes findings into markdown-native tables and Mermaid diagrams, and produces a structured report at `docs/dev/agents/<topic>.md` with numeric citations and ~10 high-quality references.

## When to load

- User says "research this", "deep dive", "exhaustive analysis", or "report on X"
- A wayfinder ticket carries the `Skill(skill='deep-research')` label (invoked by forge step 2)
- Parallel research needed: comparing multiple independent entities (e.g., 5 auth providers, 3 frameworks) — invokes `Skill(skill='dispatching-parallel-agents')` with one subagent per sub-question

## How it works

1. **Explore (minimum 10 search rounds)** — Each round targets new dimensions, not synonym-shuffled queries. Primary sources preferred (government, peer-reviewed, official docs). After every round, write a **Think** (what's still unknown, next questions) and **Summary** (what's known now), each under 5 lines. Done when 10 rounds complete per stream and Think shows diminishing new information. For parallel sub-questions, load `Skill(skill='dispatching-parallel-agents')`; each subagent runs its own 10-round loop and writes to `docs/dev/agents/<sub-topic>.md`.

2. **Analyze** — Synthesize findings into markdown-native representations: comparison tables for entities/metrics, Mermaid diagrams for flows/relationships, **bold** for key metrics and conclusions. Data analysis via web research and codebase search.

3. **Persist** — Write report to `docs/dev/agents/<topic>.md` (topic-specific filename, no date). Structure rules (from SKILL.md:18-32):
   - Every subsection (`## 3.1`) must contain more than one paragraph
   - Every paragraph ≥ 100 words (max 1,000)
   - Tables as primary structure — aggregate recurring entities into single coherent comparison tables
   - No separate "Source" column — numeric citations (`[^1^]`) inside data cells
   - Citations: `[^index^]` for factual/formal pieces, max 2 per sentence
   - Bold sparingly: important keywords, critical numbers, major conclusions
   - ~10 high-quality formatted references at the end
   - Conditional TL;DR at top only if question answerable in a few sentences
   - After writing, load `Skill(skill='forge-docs')` to update `docs/dev/README.md` and affected index files

4. **Report modes** — Academic/Survey (fact-based, full definitions, formulas, statistical indicators) or Lifestyle/Practical (observations, Pros/Cons, actionable trade-offs). Default: strict academic.

## Files in this skill

- `skills/deep-research/SKILL.md` — Main skill definition: trigger phrases, 3-step flow (Explore/Analyze/Persist), report structure rules, citation format, and two report modes

## See also

- `Skill(skill='dispatching-parallel-agents')` — Invoked for parallel research streams (step 1); each subagent runs independent 10-round loop
- `Skill(skill='forge')` — Orchestrates deep-research via wayfinder tickets (step 2: Resolve); loads `Skill(skill='forge-docs')` after report persists
- `Skill(skill='forge-docs')` — Updates `docs/dev/README.md` and index files after report is written
- `Skill(skill='wayfinder')` — Manages tickets; `Skill(skill='deep-research')` label routes tickets to this skill

## Notes

- The skill directory contains only `SKILL.md` — no companion scripts or templates.
- The `Skill(skill='forge')` skill references `docs/dev/agents/` as the home for deep research reports (forge/SKILL.md:115), consistent with deep-research's output path.
- The recursion requirement (Think/Summary after each round) is enforced by the skill but not mechanically validated — relies on agent discipline.