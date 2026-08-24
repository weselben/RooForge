# Determinism sampling — ste100

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/ste100.log` (gitignored).

## Sample

- **Task:** rewrite one sentence in STE100; output the rewrite and split mechanical vs judgment rules. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:30:06Z, exit 0, 39 log lines (incl. model reasoning).
- **Outcome:** model produced "This PR adds a cache layer. The cache layer decreases the response time. This PR also fixes bugs that users reported." — and explicitly flagged two judgment calls (whether to state the bug count, and the editorial split-PR question).

## Observed meta-decisions

- Read `skills/ste100/SKILL.md` first.
- Recognized the input sentence as **the skill's own ❌ example** — the model's rewrite matches the skill's own ✅ shape without prompting.
- Counted sentence word length to verify the 25-word cap.
- Ruled on "a few bugs" → "fixes three bugs" conditional on knowing the count, then returned the generic form because the source gives no number — a fact-handling judgment.
- Surfaced the split-PR question (cache + bugs are unrelated) as editorial judgment, not a STE100 rule.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Sentence word caps (≤20 inst, ≤25 desc) | none | full — fixed numbers | **linter** — count words per sentence type. | input: text; output: per-sentence pass/fail. |
| 2 | Sentence count per paragraph (≤6) | none | full — fixed | **linter** — count sentences per paragraph. | input: text; output: pass/fail. |
| 3 | Imperative / active voice | low — detectable patterns | mostly — fixed | **linter** — passive-voice heuristics (was/were/been, "is being"). | input: text; output: violations. |
| 4 | One topic per sentence | medium — topic boundary | none | **keep-as-model** — decomposition is judgment. | input: draft; output: split. |
| 5 | Approved short words (use/show/find) | none | full — fixed lookup table | **linter** — flag "utilize", "demonstrate", "facilitate" etc. | input: text; output: violations. |
| 6 | No idioms / no contractions | none | full — fixed list | **linter** — flag "across the board", "brand new", "can't", "won't". | input: text; output: violations. |
| 7 | One word for one meaning | medium — semantic consistency | rule is fixed | **linter** — flag term-drift across the document (e.g. "check" once, "test" later for the same concept). | input: text; output: drift list. |
| 8 | Tense rules (present true / past done / future only-later) | low — patterns exist | mostly | **linter** — check that "was/were" appears only for past events; "will" only for future. | input: text; output: violations. |
| 9 | "must / can / should" discipline | none | full — fixed | **linter** — flag drift between modal and intent. | input: text; output: violations. |
| 10 | What to keep / cut (compression) | high — semantic core | none | **keep-as-model** — authorship. | input: source; output: compressed draft. |
| 11 | "Do not censor facts" — preserve count, names, dates | none | full — fixed rule | **linter** — flag generic substitutes for known facts (e.g. "a few" where a number exists). | input: text + source; output: facts lost. |
| 12 | Scope pairing decision (e.g. unrelated changes in one PR) | high — editorial | none | **keep-as-model** — editorial. | input: PR contents; output: split-or-not. |
| 13 | Format preservation (commit prefix, PR headings, AI trailer) | none | full — fixed | **linter** — header/trailer markers preserved. | input: text; output: violations. |
| 14 | User-override (formal/marketing tone) | none | full — user wins | **shell** — caller toggles. | input: user flag; output: ignore STE100. |

## Notes

- STE100 is **the most linter-friendly skill in the set**: at least 9 of 14 steps are detect-and-fix rules. The judgment core is genuinely narrow (steps 4, 10, 12): what to split, what to keep, and editorial bounds.
- The strongest determinism win is a **`forge_mcp.ste100_lint(text)` MCP tool** that applies every mechanical rule and returns violations with suggested rewrites; the model then only authors the compression and the editorial split.
- The "do not censor facts" rule is uniquely checkable: a `forge_mcp.fact_loss(source, draft)` tool could diff the two and flag dropped specifics. This would catch the "a few" → count case the sample surfaced.
- The skill's own chapter of approved/unapproved words (in `RULES.md`) is the lintable rule set; the model's role is prose authoring, not rule lookup.