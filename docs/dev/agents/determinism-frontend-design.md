# Determinism sampling — frontend-design

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/frontend-design.log` (gitignored).

## Sample

- **Task:** brief "landing page for an indie-podcaster analytics SaaS" — output compact design plan (4–6 named hex colors, 2 typeface roles, one-sentence layout, one signature element); list judgment vs mechanical. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:29:04Z, exit 0, 117 log lines (incl. model reasoning).
- **Outcome:** model produced the "Booth" plan — a studio-rack palette (graphite/paper/vu-amber/record-red/broadcast-green/fader-grey), Recoleta + Inter type pair, asymmetric desk layout, and a faux-REC-button signature — explicitly steering away from the three AI defaults.

## Observed meta-decisions

- Read `skills/frontend-design/SKILL.md` first.
- Internally **generated and rejected candidates** before committing: GT Sectra, Söhne, Fraunces, JetBrains Mono were each considered and dropped with reasons ("overused", "too enterprise", "on-the-nose serif").
- Grounded every choice in the subject's world (VU meter amber, record red, fader grey) — the skill's "subject's world is where distinctive choices come from" rule executed deliberately.
- Self-checked against the three known AI defaults (cream+terracotta, black+acid, broadsheet) and confirmed the plan avoided all three.
- Judgment dominated; the only mechanical part was the **output token shape** (4–6 colors, 2 type roles, one-sentence layout, one signature).
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Pin subject/audience/page-job if the brief omits them | high — naming the concrete subject | none | **keep-as-model** — interpretive. | input: brief; output: `{subject, audience, job}`. |
| 2 | Produce the token-plan shape (4–6 hex, 2+ type roles, one-sentence layout, one signature) | none | full — fixed token shape | **premade prompt template** — the plan skeleton is fixed; model fills the values. | input: plan fields; output: structured plan. |
| 3 | Choose palette values grounded in the subject | high — creative judgment | none | **keep-as-model** — the entire point of the skill. | input: subject; output: palette. |
| 4 | Choose typeface pairing | high — taste | none | **keep-as-model**. | input: brief; output: type pair. |
| 5 | Choose signature element | high — the one risk to take | none | **keep-as-model**. | input: brief + plan; output: signature. |
| 6 | Self-check against the three known AI defaults | low — the three looks are enumerated | full — fixed list | **linter / checklist** — compare palette+layout against the three default signatures; flag matches. | input: plan; output: `{matches_default: bool, which}`. |
| 7 | Revise-if-generic loop ("work through a similar prompt, check you don't arrive somewhere similar") | medium — self-similarity judgment | procedure is fixed | **keep-as-model** — the procedure is fixed, the similarity judgment is not. | input: plan; output: revised plan + change log. |
| 8 | Quality floor (responsive, focus visible, reduced motion) | none | full — fixed floor | **linter** — automated a11y/responsive checks post-build. | input: built page; output: violations. |
| 9 | Copy writing rules (active voice, sentence case, no filler, end-user vocabulary) | low — rules are enumerated | mostly | **keep-as-model** with **linter** backup — banned-word/hedging checks. | input: copy; output: violations. |
| 10 | CSS specificity discipline | medium — structural | none | **linter** — specificity-graph tooling exists. | input: CSS; output: conflict report. |

## Notes

- Frontend-design is the **most judgment-dense** skill sampled: its value is precisely the creative choices a deterministic mechanism cannot make. The seam analysis confirms it — steps 3, 4, 5, 7 are the product.
- The determinism wins are all **verification-side**: the token-plan shape (2), the AI-default check (6), the quality floor (8), and copy linting (9) can all be checked mechanically *after* the model creates. None of them replace the creative core.
- The three-defaults list in the skill is a rare example of a skill shipping its own adversarial test set — step 6's linter is directly implementable from it.
- Per ADR 0004's risk note: one sample of a creative skill is thin evidence by nature; but since the recommendation is keep-as-model for the core, the risk is low.