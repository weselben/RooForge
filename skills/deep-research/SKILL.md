---
name: deep-research
description: "Exhaustive evidence-based research — minimum 10 search iterations, recursive reflection, structured reports with markdown-native tables. As long as the research is solid; no fixed length cap. Triggers: \"research this\", \"deep dive\", \"exhaustive analysis\", \"report on X\"."
source: "https://github.com/MoweME (origin: kimi.com web UI)"
---

# Deep Research

High-intensity research protocol: exhaustive discovery, recursive reflection, high-density reporting. Rigorous fact-grounding, quantitative visualization, strict structure and length.

## Output

`docs/dev/agents/<topic>.md` — topic-specific filename, no date. Example: `docs/dev/agents/auth-providers-comparison.md`.

## Leading word: recursion

Every search round ends with a **Think** (what's still unknown, what to ask next) and a **Summary** (what's known now). Both tight — under five lines each. The recursion drives the next round's direction.

## Steps

### 1. Explore — minimum 10 search rounds

Each round earns its keep — new dimensions, not synonym-shuffled queries. Prefer primary sources (government, peer-reviewed, official docs). **Every claim traceable.**

After each round, write a short **Think** and **Summary** (see recursion above).

**Parallel research:** when the question splits into independent sub-questions (e.g. compare 5 auth providers, survey 3 frameworks), invoke `Skill(skill='dispatching-parallel-agents')` with one item per sub-question. Each subagent runs its own 10-round loop, writes to its own `docs/dev/agents/<sub-topic>.md`, and returns a summary. Aggregate results in step 3.

**Done when:** 10 rounds complete per stream; every round's Think shows diminishing new information.

### 2. Analyze — synthesize into markdown-native representations

- **Comparison tables** for entities, models, metrics
- **Mermaid diagrams** for flows and relationships
- **Bold** for key metrics and conclusions
- Data analysis via web research and codebase search

### 3. Persist — write to `docs/dev/agents/<topic>.md`

The report IS the artifact. Structure:

- **Every subsection** (`## 3.1`) **must contain more than one paragraph**
- **Every paragraph** ≥ 100 words (max 1,000)
- **Tables as primary structure** — aggregate recurring entities into single coherent comparison tables
- **No separate "Source" column** — numeric citations (`[^1^]`) inside data cells
- **Citations:** `[^index^]` for factual/formal pieces, max 2 per sentence
- **Bold sparingly:** important keywords, critical numbers, major conclusions — don't repeat the same bold entity in a short span
- **References:** ~10 high-quality formatted references at the end
- **Conditional TL;DR** at the top only if the question can be answered in a few sentences

**After writing**, load `Skill(skill='forge-docs')` — it updates `docs/dev/README.md` and any affected index files.

**Done when:** report written to output path, every claim traceable, tables/mermaid/citations in place, references formatted, and `Skill(skill='forge-docs')` applied.

## Report modes

| Mode | Style |
|------|-------|
| Academic/Survey | Fact-based, full definitions, formulas, statistical indicators, baseline comparisons. No speculative interpretation. |
| Lifestyle/Practical | Observations, human insights, Pros/Cons, actionable trade-offs. |

Style adapts to context. Default: strict academic. Omit generic Introduction/Background unless required.

