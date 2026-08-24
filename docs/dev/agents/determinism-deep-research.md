# Determinism sampling — deep-research

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/deep-research.log` (gitignored).

## Sample

- **Task:** simulate (no real search) a 3-round research on "GitHub native sub-issues API endpoints"; produce per-round (query, Think, Summary) compressed; split mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:27:57Z, exit 0, 35 log lines (incl. model reasoning).
- **Outcome:** model produced 3 rounds with shifting dimensions (REST → GraphQL → CLI/docs/changelog), explicit Think/Summary pairs, and noted the 10-round skill mandate violates the user's 3-round ask — handled the conflict correctly.

## Observed meta-decisions

- Read `skills/deep-research/SKILL.md` first.
- Resolved a **precedence conflict** explicitly: forge's "always load first" vs the user's "3 rounds only" — the model judged the user's specific instruction as more constraining and proceeded under it (also flagged the deviation in the closing note).
- Query design rotated across *dimensions* (REST surface → GraphQL schema → CLI exposure) — the skill's "new dimension, not synonym-shuffled" rule applied cleanly.
- Think/Summary cadence was mechanical — short, under 5 lines each as the rule requires.
- Detected diminishing returns at round 3 ("depth, limits, webhook events…diminishing for a 3-round scope").
- Did **not** write files, did **not** search (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Output path (`docs/dev/agents/<topic>.md`) | none | full — fixed template | **shell script** — `<topic>` from user prompt + timestamp-free path. | input: topic; output: file path. |
| 2 | Per-round recursion cadence (Think → Summary → next round) | none | full — fixed sequence | **premade prompt template + Node wrapper** — the prompt template defines the round shape; the wrapper enforces the Think/Summary length caps. | input: round state; output: structured round log. |
| 3 | Source preference (primary over blogs) | low — explicit rule | mostly — tier ordering exists | **premade prompt template** with the rule baked in; a post-pass scoreboard can rank sources. | input: candidate URL; output: priority tier. |
| 4 | Parallel research dispatch (independent sub-questions → `dispatching-parallel-agents`) | low — already enumerated | full — Item-list shape | **AgentSwarm `{{item}}`** — already the standard pattern; no new mechanism. | input: sub-question list; output: parallel reports. |
| 5 | Report structure (tables, mermaid, citations `[^N^]`, references) | none | full — fixed template | **premade prompt template + Node wrapper** — template fills the skeleton; wrapper validates citation count (≤2/sentence) and paragraph length (≥100 words). | input: report body; output: valid/lint report. |
| 6 | Forge-docs post-write (update README + index) | none | full — fixed chain | **shell script** — invoke `forge-docs` after artifact write. | input: file path; output: chain call. |
| 7 | Query design per round — *new dimension, not synonyms* | high — requires reading what's known and what's missing | condition to stop (diminishing returns) is enumerable | **keep-as-model** — query authoring is the semantic core; ADR 0005 classifies it as judgment. | input: prior round + knowns; output: next query. |
| 8 | Source selection (which doc, which version) | medium — picking the right reference | primary-source preference is a rule | **keep-as-model** with the rule as a soft prior; over-restricting to a source list would kill coverage. | input: candidate sources; output: chosen list. |
| 9 | Detecting diminishing returns | medium — when to stop | none | **keep-as-model** — requires understanding what new info a round added. | input: round log; output: continue/stop. |
| 10 | Mode selection (Academic vs Lifestyle) | medium — context-appropriate | none | **keep-as-model** — model for prose/register. | input: topic; output: mode. |
| 11 | Conditional TL;DR (only if answerable in a few sentences) | medium — summarization judgment | none | **keep-as-model** — ADR 0005 classifies summarization as judgment. | input: full report; output: TL;DR or omitted. |

## Notes

- The seam splits cleanly into **mechanical skeleton** (path, cadence, structure, validation) and **semantic core** (query design, source selection, stop signal, prose).
- The mechanical skeleton is already what Node wrappers + prompt templates do well — this is the strongest candidate for a `deep-research` Node tool that receives a topic, dispatches the rounds, and emits a conformant report. The model is then a *round engine*, not a free-form writer.
- The 10-round minimum is rule-shaped but the sample showed the model is willing to override it on user instruction — a tension worth resolving in the policy (ADR 0005 or successor).
- The `forge-docs` post-step is already chained; the determinism win is *scripting* that chain after the artifact's existence is confirmed, not replacing the model.
