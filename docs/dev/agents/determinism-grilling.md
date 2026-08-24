# Determinism sampling — grilling

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/grilling.log` (gitignored).

## Sample

- **Task:** simulate wave 1 on the decision "wayfinder tickets wire blocking via native GitHub issue dependencies or a body convention?" — up to 4 frontier questions in `❓`/`➡️` format with recommended answers; split mechanical vs judgment. DRY RUN, both sides simulated.
- **Run:** `kimi -p` on 2026-08-18T01:29:38Z, exit 0, 58 log lines (incl. model reasoning).
- **Outcome:** model produced a 4-question wave (canonical mechanism, body fallback, skill scope, enforcement), each with a recommended answer, plus an explicit deferral list for wave 2 and a note that a `gh`-CLI fact check would go to a sub-agent rather than the user.

## Observed meta-decisions

- Read `skills/grilling/SKILL.md` first.
- Internally drafted a first question set, then **revised it** when it noticed Q2 depended on Q1 — an explicit application of the frontier rule ("a question whose answer depends on another open question belongs to a later round").
- Applied the "facts are your job, never the user's" rule by routing the `gh` CLI support check to a sub-agent instead of a frontier question.
- Hit the 4-question cap exactly and stated the wave-2 deferrals with their dependencies.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Question format (`❓ Q<n>` / `➡️` template) | none | full — fixed template | **premade prompt template + Node wrapper** — template fills Q-title/body/recommendation slots; wrapper validates format. | input: question parts; output: formatted block. |
| 2 | Wave cap (max 4 per wave) | none | full — fixed constant | **shell/wrapper** — truncate at 4, queue the rest. | input: question list; output: wave + remainder. |
| 3 | Frontier recomputation (settled decisions push frontier outward) | medium — dependency graph over decisions | the *rule* is fixed | **premade prompt template** — model maintains an explicit decision tree; wrapper checks "no question in wave depends on another open question in the same wave". | input: tree state; output: frontier list. |
| 4 | "Facts via sub-agent, never the user" routing | low — detection of fact-needs | rule is fixed | **AgentSwarm `{{item}}`** — fact-finding questions dispatch as sub-agent items (already the standard pattern). | input: fact question; output: fact + source. |
| 5 | Decompose the decision into a design tree | high — the tree is the product | none | **keep-as-model** — decomposition is judgment. | input: decision statement; output: tree. |
| 6 | Pick which questions are actually frontier | high — dependency reading | none | **keep-as-model** — requires understanding the tree. | input: tree; output: frontier. |
| 7 | Recommended answers | high — requires domain + repo context | none | **keep-as-model**. | input: question; output: recommendation. |
| 8 | Decide session is done (frontier empty, shared understanding confirmed) | medium — "nothing left silently assumed" | the frontier-empty check is mechanical | **wrapper** enforces frontier-empty; the *shared-understanding confirmation* is user-facing and stays. | input: tree; output: `{done: bool}`. |
| 9 | Sequential wave cadence (wait for answers before next round) | none | full — fixed control flow | **shell/wrapper** — the loop driver; only content is model-made. | n/a. |

## Notes

- Grilling's **protocol is fully mechanical** (format, cap, cadence, fact-routing, done-check); its **content is fully judgment** (tree, frontier picks, recommendations). This is the cleanest protocol/content split in the skill set.
- The frontier rule is checkable: a wrapper can maintain the decision tree as data (nodes + dependencies) and reject any wave that violates same-round independence. The sample shows the model already performs this check internally — externalizing it removes a failure mode.
- The sample's revision moment (drafting Q2, noticing the dependency, deferring it) is exactly what a tree-as-data wrapper would enforce structurally.
- Recommended mechanism overall: **premade prompt template + Node wrapper** for the protocol; keep-as-model for tree decomposition, frontier selection, and recommendations.