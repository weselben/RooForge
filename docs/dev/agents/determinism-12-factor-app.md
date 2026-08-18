# Determinism sampling — 12-factor-app

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/12-factor-app.log` (gitignored).

## Sample

- **Task:** audit a described Node API (in-memory sessions, hardcoded `DATABASE_URL`, single-stage Dockerfile, file logging); list violations + fixes, then separate mechanical from judgment parts. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:27:42Z, exit 0, 50 log lines (incl. model reasoning).
- **Outcome:** model mapped all four stated defects to the correct factors (VI, III, V, XI), pulled fixes straight from the skill's Common Mistakes table, and added two implied factors (II, IX) on its own initiative.

## Observed meta-decisions

- Read `skills/12-factor-app/SKILL.md` first, then audited point-by-point against the factor table.
- Mapped each defect 1:1 to a factor row — no branching, no ambiguity in the mapping.
- Went beyond the stated description: flagged Factor II (lockfile, pinned base image) and Factor IX (SIGTERM, cold start) as "implied" — an inference step the skill does not pre-script.
- Self-classified mechanical vs judgment exactly as the skill's own structure suggests (table lookup vs prioritization).
- Did **not** modify files (respected the DRY RUN contract).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Load the factor table and Common Mistakes table | none | full — the tables are the skill | **keep-as-model** — the skill *is* a reference table; the harness already injects it on trigger. | input: trigger keywords; output: SKILL.md in context. |
| 2 | Map a stated defect to a factor | low — mapping is 1:1 against table rows | full — each defect class has a fixed factor + standard fix | **premade prompt template + Node wrapper** for the audit harness: feed app facts in, get the factor-mapping skeleton out; or keep-as-model given the mapping is already near-mechanical in prose. | input: list of observed facts; output: `[{fact, factor, standard-fix}]`; machine-checkable: every fact appears in exactly one row. |
| 3 | Infer implied factors beyond the stated description | medium — which unmentioned factors apply | none observed | **keep-as-model** — requires reading between the lines of the app description. | input: app description; output: additional factor candidates with one-line justification. |
| 4 | Prioritize and sequence fixes | high — cost/dependency reasoning ("Config and Logs first, Sessions last") | priority hint exists in the skill ("Config, Processes, Build/Release/Run most critical") | **keep-as-model** — ADR 0005 classifies prioritization as judgment; the skill's built-in priority order already constrains it. | input: violation set; output: ordered fix list + rationale per step. |
| 5 | Concrete fix phrasing ("replace X with Y using Z") | low — fixes come from the Common Mistakes table | mostly — standard fixes are tabulated | **keep-as-model**, constrained by the table; a lint-style MCP tool (`forge_mcp.twelve_factor_scan(repo)`) could automate the config/secrets/Dockerfile checks against a real repo. | input: repo path; output: `{violations: [{factor, file, line, fix}]}`. |

## Notes

- This skill is a **checklist consultant**: most of its value is the table itself, which is already deterministic content. The model adds inference (implied factors) and sequencing (prioritization) on top.
- The realistic determinism win is not inside the skill's prose but a repo-scanning tool (secrets-in-code, single-stage Dockerfile, file logging) that produces the fact list the skill then maps. That belongs on `forge-mcp` per ADR 0005 (infra checks → MCP).
- Borderline call: step 2 (fact→factor mapping) could go either way; a second sample with a different app description would settle it (ADR 0004 risk note).
