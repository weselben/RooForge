# Determinism sampling — forge-seo

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/forge-seo.log` (gitignored).

## Sample

- **Task:** for "add JSON-LD structured data and a sitemap.xml to a Next.js site", pick which reference file(s) to read, in what order, and state whether routing is mechanical or judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:29:04Z, exit 0, 51 log lines (incl. model reasoning).
- **Outcome:** model read only `references/technical-seo.md` and called the routing "mechanical" — both task tokens (`JSON-LD`, `sitemap`) are explicit row entries in the routing table.

## Observed meta-decisions

- Read `skills/forge-seo/SKILL.md` first.
- Routing was a **direct lookup**: `JSON-LD` and `sitemap.xml` both appear verbatim in the "How to choose" table.
- Detected the Next.js framing as implementation context (not design/layout), so UX/UI reference is not applicable.
- Correctly noted that the routing decision only needs judgment when a visual/design concern joins (e.g. "make the sitemap page pretty") — the "Both" row then applies.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Route to reference file(s) per task keywords | low — table lookup | full — fixed two-row table | **shell script / keyword matcher** — token match against the routing table; returns one reference, both, or none. | input: task text; output: `{files: [...], order: [...]}`. |
| 2 | Load the chosen reference(s) | none | full — file read | **shell script** — read the reference file. | n/a. |
| 3 | "Do NOT read both unless task spans both" rule | none | full — fixed | **linter** — if only one row matches, reject loading both. | input: file list; output: valid. |
| 4 | Companion-skill selection (e.g. `forge-eu-accessibility` mandatory for UI/UX) | low — task-dependent | rule is fixed | **shell script** — task classifier picks skills from a fixed list. | input: task text; output: companion skill list. |
| 5 | Verify live sources via WebSearch / FetchURL | none | full — fixed tool list | **shell script** — dispatch WebSearch/FetchURL per the task's source hints. | input: query/URL; output: source text. |
| 6 | Apply reference guidance to the actual task (JSON-LD schema, sitemap entries, meta tags) | high — code/UX judgment | none — every application is unique | **keep-as-model** — reference application is judgment. | input: task + reference; output: code/artefacts. |
| 7 | Decide when a *second* reference is needed (design + technical) | medium — boundary detection | none | **keep-as-model** — requires reading intent, not just tokens. | input: task; output: {load_both: bool}. |

## Notes

- Forge-seo is a **router** skill: its own content is almost entirely the routing table plus the two reference files. The model's job is to pick the right reference and then apply it.
- The routing step (1–3) is fully mechanical — the table is explicit and the sample showed the model executing it as a lookup. This is the strongest single determinism win across the whole skill set: a keyword matcher that replaces the router step.
- The companion-skill selection (step 4) and the "span both domains" call (step 7) are the only judgment spots, and both are small.
- The references themselves (`references/uxui-seo.md`, `references/technical-seo.md`) are content, not procedure — the model applies them; no determinism win there.
- "Verify live sources" (step 5) is a correctness invariant, like `forge-eu-accessibility`; a wrapper that enforces it before compliance claims would be valuable.