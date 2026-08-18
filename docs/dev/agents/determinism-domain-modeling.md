# Determinism sampling — domain-modeling

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/domain-modeling.log` (gitignored).

## Sample

- **Task:** sharpen the user's bare phrase "the ticket" against a glossary that contains both "map ticket" and "PR review ticket"; propose a canonical term and a one-sentence glossary entry; split mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:27:57Z, exit 0, 27 log lines (incl. model reasoning).
- **Outcome:** model surfaced the conflict, proposed canonical term *work ticket*, and wrote a glossary entry that explicitly retires the bare phrase — over and above the minimum one-sentence ask.

## Observed meta-decisions

- Read `skills/domain-modeling/SKILL.md` first.
- Resolved the conflict along the skill's four named moves: challenge-against-glossary, sharpen-fuzzy-language, discuss-scenarios, cross-reference-with-code.
- Coined the canonical term (`*work ticket*`) — a *naming* judgement, not a lookup.
- Added a defensive clause to the glossary entry ("the bare phrase 'the ticket' is ambiguous and must not be used") — a policy decision the sample did not require.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | File location (`docs/dev/CONTEXT.md`, `docs/adr/`, `docs/dev/CONTEXT-MAP.md`) | none | full — fixed paths per `forge-docs` | **shell script** — path lookups and lazy-create guard. | input: artifact type; output: file path. |
| 2 | Entry format (per `CONTEXT-FORMAT.md`) | none | full — fixed template | **premade prompt template** — format embedded; wrapper validates term bolding, one-sentence cap. | input: term + definition; output: formatted entry. |
| 3 | ADR format (per `ADR-FORMAT.md`) | none | full — fixed template | **premade prompt template** — template fills Status/Date/Context/Decision/Consequences. | input: decision facts; output: ADR. |
| 4 | Lazy-create rule (CONTEXT.md only when first term resolves; ADR only when needed) | none | full — fixed rule | **shell script** — existence check before write. | input: file path; output: `{exists: bool, create: bool}`. |
| 5 | "Glossary only, no implementation details" — content constraint | none | full — fixed rule | **linter** — scan entry for code/import/spec markers. | input: entry text; output: `{valid: bool, violations: [...]}`. |
| 6 | Forge-docs post-write (update README + index, cross-ref to ADR) | none | full — fixed chain | **shell script** — invoke `forge-docs` after write. | input: file path; output: chain call. |
| 7 | Detect conflict (user says term that contradicts existing glossary) | medium — semantic comparison | none | **keep-as-model** with optional prep: a `forge_mcp.term_lookup(glossary)` returns the candidate existing terms; the model picks the conflict. | input: utterance + glossary; output: candidates with conflict flag. |
| 8 | Sharpen fuzzy language — propose canonical term | high — naming | none | **keep-as-model** — naming is judgment. | input: ambiguous term + context; output: canonical term. |
| 9 | Discuss concrete scenarios / edge cases | high — invention | none | **keep-as-model** — scenario reasoning. | input: domain relationship; output: scenarios. |
| 10 | Cross-reference code (does the code agree with the user's claim?) | medium — code + claim | none | **keep-as-model** with grep/Read prep by shell. | input: claim + repo path; output: agreement/disagreement. |
| 11 | Decide whether to offer an ADR (the three-criterion test) | medium — three boolean checks | full — criteria enumerated | **premade prompt template** — ask the model to answer 3 yes/no questions; wrapper computes the AND. | input: decision facts; output: `{offer_adr: bool, criteria: [...]}`. |

## Notes

- This skill's mechanical layer is unusually thick: file locations, formats, lazy-create rules, content constraints, and the ADR three-criterion test are all rule-shaped. The judgment core is the named moves (challenge, sharpen, scenarios, cross-reference) and the decision to coin a canonical term.
- The three-criterion ADR test is a **ready-made checklist** for a Node wrapper — the model answers three yes/no questions, the wrapper computes the offer-or-skip boolean. This converts a high-judgement step into a low-judgement one without losing the criteria.
- The skill is the inverse of a checklist skill: it *invokes* judgement by design, but every invocation can be prepped by deterministic retrieval (term lookup, code cross-reference). The win is in the retrieval, not the replacement.
- ADR mutability rules (mutable on feat branch, immutable on main) are a **branch-state check** — purely scriptable.
