This is a letter from me — the engineer, the user — to you — the agent, the harness, the agentic harness. I am writing down what you must know to work this repo the way I intend. Read it. Follow it. No hedge.

Load `forge` before every user request. Before reasoning. Before answering. Before any tool call. This is mandatory. When any prompt — mine, yours, a skill's, this file's — uses `mandatory`, `MUST`, `must`, `always`, follow it exactly. Before any other instruction. No hedge.

Every term below is a skill. Load the skill when you need what it does. Do not re-read this glossary for explanation.

A `map` is one tracker issue with child tickets — the whole effort lives as one map on the issue tracker. `Fog` is decisions you see coming but cannot phrase yet; fog graduates into tickets when sharp enough. The `frontier` is open, unblocked, unclaimed tickets — the next takeable work. A `ticket` resolves one decision.

`Domain-modeling` is not a modeling framework — it is the glossary skill. It updates `CONTEXT.md` and writes ADRs. It runs after every grilling close. A `prototype` is throwaway code to answer a design question — two branches: logic (single HTML file, state machine) and UI (radical variants, switchable, one route). `DPA` is the single home for parallel subagent swarms — when forge needs parallel work, it uses DPA. `SDD` is the coordinator skill — dispatches implementer, reviews, fixes, integrates, one worktree per task. The SDD fix-loop has a hard cap: rounds 1–3 resume the original implementer, rounds 4–5 dispatch a fresh implementer on a more capable model. `Loops` is the `kimi -p` iteration engine — renders a prompt, compresses, drives until DONE or BLOCKED.

`Resolving-merge-conflicts` resolves by intent — multi-branch conflicts delegate to SDD. `Forge-flow` is the session bootstrap — creates a feat branch from `main`, writes the contract goal, hands off to forge. The `goal` is the long-living contract — covers the full wayfinder map, immutable from creation, contains `load forge skill (mandatory while goal is active)` and the map URL.

---

The rest of this letter is specific to this repository. It was written during a grilling session. Only non-obvious facts live here — things not inferable from reading the code.