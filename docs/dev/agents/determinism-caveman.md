# Determinism sampling — caveman

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/caveman.log` (gitignored).

## Sample

- **Task:** rewrite one padded sentence at level `ultra`, then split the applied rewrite rules into mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:27:42Z, exit 0, 94 log lines (incl. model reasoning).
- **Outcome:** model produced `"Token expiry check use \`<\` not \`<=\` in authentication middleware."` — and, notably, caught the ultra-level prohibition on prose abbreviations (`auth` → `authentication`), a rule easy to miss.

## Observed meta-decisions

- Read `skills/caveman/SKILL.md` first, then enumerated the ultra-level rule set before rewriting.
- Applied the mechanical rules (article drop, filler/pleasantry/hedging drop, conjunction strip, verb trim) as a fixed checklist — the reasoning trace lists them one by one.
- Caught a self-trap: initially reached for "auth middleware", then self-corrected per the ultra rule "NO prose abbreviations (…auth)".
- Kept code symbols (`<` / `<=`) verbatim without deliberation — rule is absolute.
- Judgment was confined to *what to keep*, not *how to compress*: sentence split, whether to label "Bug:", which facts are actionable.
- Did **not** modify files (respected the DRY RUN contract).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Activate/persist the mode (trigger phrases, `/caveman <level>`, off-switch) | none | full — fixed trigger list + level table | **Skill auto-load is harness-side** — already deterministic; level switching is a command parse, candidate for harness slash-command, not model. | input: `/caveman <level>`; output: mode state `{level}`; machine-checkable: level string ∈ enum. |
| 2 | Mechanical drop rules (articles, filler, pleasantries, hedging) | none — fixed word lists | full | **deterministic post-processor is possible but misplaced** — the model *is* the text generator; a sed-style pass on model output would fight it. Keep-as-model: the rules are already checklist-shaped and the model applies them reliably. | input: draft text; output: compressed text; machine-checkable: banned-word list absent from output. |
| 3 | Absolute preservation rules (code symbols, error strings, acronyms, not/never/no) | none | full | **keep-as-model**, but machine-checkable: a linter could diff output against preserved-token set (code spans, quoted errors) and flag violations. | input: source text; check: every code span / quoted error appears verbatim in output. |
| 4 | Fact selection — which facts survive compression | high — "location is the actionable fact" | none | **keep-as-model** — requires understanding what the reader needs; ADR 0005 classifies content selection as judgment. | input: source text + reader context; output: kept-fact list. |
| 5 | Auto-Clarity drop (security warnings, irreversible ops, ambiguous order) | medium — when compression creates ambiguity | trigger conditions enumerated in skill | **keep-as-model** for the decision; the *format* of the dropped section is a premade template (warning + code block + resume line). | input: text + risk flags; output: normal-prose section per template, then caveman resumes. |
| 6 | Boundary: persisted artefacts stay normal prose | none | full — fixed list (code, commits, docs, PR text) | **keep-as-model**; trivially checkable after the fact by scanning committed artefacts for caveman markers. | check: no article-drop patterns in `git show` artefacts. |

## Notes

- Caveman is a **style transform**, and the sample shows the transform splits cleanly: a mechanical rule set (drop lists, preservation lists) the model executes like a linter, plus a small judgment core (fact selection, auto-clarity).
- The mechanical core is already so checklist-shaped that the marginal win of a deterministic replacement is low — the model applies it in one pass while generating. The realistic determinism win is a **verifier**, not a generator: a script that checks output for banned filler words and preserved code spans.
- The wenyan levels were not exercised by this sample; their rule set is structurally identical (drop lists + register rules), so the seam shape should transfer, but that is inference, not observation.
