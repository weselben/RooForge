# Determinism sampling — forge-eu-accessibility

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/forge-eu-accessibility.log` (gitignored).

## Sample

- **Task:** for a 30-person German consumer e-commerce site, determine BFSG scope, binding technical baseline, and required documentation; split mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:28:25Z, exit 0, 34 log lines (incl. model reasoning).
- **Outcome:** model classified scope as BFSG § 1 Abs. 3 Nr. 5 (e-commerce services), correctly excluded the microenterprise exemption (30 > 10), and produced the documentation list with statutory anchors.

## Observed meta-decisions

- Read `skills/forge-eu-accessibility/SKILL.md` first.
- **Scope lookup was mechanical**: e-commerce → § 1 Abs. 3 Nr. 5, a direct table hit.
- **Microenterprise test** was mechanical: 30 ≥ 10 employees ⇒ exemption does not apply (rule is fixed).
- **Judgment** was reserved for the exemption categories: fundamental alteration, disproportionate burden, and edge-case exclusions (third-party content, archive content).
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Scope classification (§ 1 Abs. 2 vs Abs. 3, numbered list) | none | full — fixed product/service table | **shell script** — input product/service description, output applicable paragraph. | input: scope facts; output: `{applies: bool, paragraph}`. |
| 2 | Microenterprise test (headcount + turnover + balance sheet) | none | full — fixed thresholds (10 persons, €2M) | **shell script** — straightforward inequality. | input: company facts; output: `{is_micro: bool}`. |
| 3 | Apply binding technical baseline (WCAG 2.1 AA via EN 301 549 V3.2.1) | none | full — single rule | **shell script** — always returns the same baseline. | n/a. |
| 4 | Audit a UI against the WCAG checklist | high — code + UX + accessibility reasoning | every item maps to a SC | **MCP tool `forge-mcp.wcag_scan(url)`** — automated checks for a large subset of SCs (colour contrast, alt text, ARIA, keyboard); the model audits what scanners miss. | input: URL; output: `{violations: [{sc, evidence}]}`. |
| 5 | Documentation requirements (statement, retention, accessible PDFs) | low — rules enumerated | mostly — Anlage 3 content list is fixed | **premade prompt template** — template fills statement skeleton; wrapper validates accessibility of the published statement itself. | input: facts; output: statement draft. |
| 6 | Fundamental alteration assessment (§ 16) | high — "basic nature" is interpretive | triggers are rule-shaped | **keep-as-model** — substantive judgement. | input: change proposal; output: {alters_basic_nature: bool}. |
| 7 | Disproportionate burden assessment (§ 17) | high — cost/benefit reasoning | Anlage 4 criteria are enumerated | **keep-as-model** — criteria are fixed, weighing is judgement; ADR 0005 flags this. | input: facts; output: {disproportionate: bool, assessment}. |
| 8 | Edge-case exclusions (third-party content, archive content, time-based media) | medium — "funded, developed, controlled" is fuzzy | boundaries are enumerated | **keep-as-model** — classification. | input: content facts; output: {excluded: bool, reason}. |
| 9 | Verify current legal text via `WebSearch` / `FetchURL` | none | full — fixed source list | **shell script** — `forge-mcp.legal_fetch(urls)` returns canonical text. | input: source URL; output: source text. |
| 10 | Framework-agnostic guidance ("no React/Vue/etc.") | none | full — fixed rule | **linter** — reject framework-specific recommendations in output. | input: text; output: framework-agnostic: bool. |

## Notes

- This skill's mechanical layer is **table lookups and threshold tests** (scope, microenterprise, baseline). The judgment layer is concentrated in two areas: the WCAG audit itself (step 4) and the exemption assessments (steps 6, 7).
- The strongest determinism win is a **WCAG scanner** on `forge-mcp` — most WCAG SCs are automatable (contrast, alt presence, ARIA, keyboard). The model is then freed to reason about novel UX/structural problems and exemption trade-offs.
- "Always verify current legal texts" is a *correctness invariant* — the harness's WebSearch/FetchURL tools already cover it; the determinism win is a wrapper that enforces the verification step before any compliance claim.
- Penalties (€100k, prohibition orders) belong to the prose-warning surface, not a computation; no scriptable replacement.