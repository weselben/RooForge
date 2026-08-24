# Determinism sampling — kiss-principle

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/kiss-principle.log` (gitignored).

## Sample

- **Task:** evaluate "an orchestrator class with 4 nested state machines to sequence 3 plain function calls" against the KISS checklist; give verdict and simpler alternative; split mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:29:38Z, exit 0, 37 log lines (incl. model reasoning).
- **Outcome:** model returned "Non-KISS — clear over-engineering", produced a 3-line Python alternative, and explicitly flagged the proportionality call ("if the 3 calls were actually fault-tolerant distributed transactions with rollback, state machines might be warranted") as the judgment boundary.

## Observed meta-decisions

- Read `skills/kiss-principle/SKILL.md` first.
- Ran the checklist against the design symbolically — "complexity (orchestrator + 4 FSMs) vs problem (3 sequential calls)" is a proportionality check.
- Matched the design to the **named anti-pattern** ("complex agent orchestration") verbatim — table lookup.
- Surfaced the counterargument and then dismissed it ("sequencing is what plain function calls already do for free") — a falsifiable move.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Count moving parts (classes, FSMs, dependencies) | none | full — counts are numeric | **shell script** — static analysis: count classes, FSM primitives, dependency-graph nodes. | input: AST/diff; output: counts. |
| 2 | Match against the anti-pattern table | low — table lookup | full — fixed 7-row table | **shell script** — keyword match (e.g. "orchestrator", "FSM", "god object") against anti-pattern fingerprints. | input: design summary; output: matching rows. |
| 3 | Run the 6-item decision checklist | low — each is a yes/no | full — fixed list | **premade prompt template** — wrapper asks the questions, the model answers. | input: design facts; output: per-item pass/fail. |
| 4 | Proportionality call (does the complexity earn its keep?) | high — counterfactual reasoning | none | **keep-as-model** — requires weighing hypothetical alternatives. | input: design + context; output: {proportional: bool, reason}. |
| 5 | Propose a simpler alternative | high — design judgment | none | **keep-as-model** — authorship. | input: design; output: alternative. |
| 6 | Identify which KISS rule(s) are violated | low — rule lookup | full — fixed 6 rules | **shell script** — sometimes checkable from static analysis (e.g. "3+ duplications for abstraction": check duplication count). | input: design; output: rule list. |
| 7 | "Junior-understandable in 2 minutes" test | medium — audience variable | the rule is fixed | **keep-as-model** — audience call. | input: design; output: pass/fail. |
| 8 | Dependency liability check | none | full — fixed rule | **shell script** — `npm ls` / `cargo tree` / `pip show`; count direct+transitive. | input: manifest; output: dep list. |
| 9 | "3+ concrete instances" rule for abstraction | none | full — fixed threshold | **shell script** — duplication count. | input: code; output: count. |

## Notes

- The skill's **table lookups** (anti-pattern matching, rule violation) are already mechanical; the **proportionality call** is where the model earns its keep. The sample illustrates this perfectly via the rollback counterexample.
- The strongest determinism win is a **`forge_mcp.complexity_scan(diff)` MCP tool** that emits counts (classes, FSMs, deps, duplications) and matches the anti-pattern table — the model then only authors the proportionality call and the alternative.
- The "3+ concrete instances" rule for premature abstraction is a literal duplication-count threshold — directly scriptable.
- The "junior-understandable" test is the only audience-dependent judgement left after the tool-driven scans, and even that could be partially automated (e.g. cyclomatic complexity per function as a proxy).