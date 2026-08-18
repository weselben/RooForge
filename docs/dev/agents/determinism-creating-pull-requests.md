# Determinism sampling — creating-pull-requests

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/creating-pull-requests.log` (gitignored).

## Sample

- **Task:** sample on a 12-line docs-only diff adding `docs/dev/agents/determinism-forge.md`; produce size gate, full PR body, and mechanical/judgment split. DRY RUN; no `gh` writes.
- **Run:** `kimi -p` on 2026-08-18T01:27:57Z, exit 0, 49 log lines (incl. model reasoning).
- **Outcome:** model classified Small (TL;DR-only), generated title + 2-line TL;DR + AI disclosure, and explicitly steered around the ≥3-noun stack ("forge determinism report" → "report on forge determinism").

## Observed meta-decisions

- Read `skills/creating-pull-requests/SKILL.md` first, then applied the size-gate table as a literal lookup (12 < 50 → Small).
- Title noun-stack rule (≤2 consecutive nouns) was a **mechanical rewrite trigger** — the model tried three drafts and self-flagged the third as compliant.
- Detected the docs-only edge case: no real "symptom" exists, so the TL;DR first sentence frames the *gap* (no record of determinism findings in `docs/dev/agents/`) — a judgment call surfaced in the analysis.
- Applied the mandatory AI disclosure footer verbatim — fixed string, no judgement.
- Did **not** invoke `gh pr create` (respected the DRY RUN contract).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Detect base ref, read diff, `--stat`, commits | none | full — fixed `gh`/`git` invocations | **shell script** — already enumerated in the skill; trivially deterministic. | input: repo + branch; output: `{base, diff, stat, commits}`. |
| 2 | Size gate (line count → Small/Medium/Large + section budget) | none | full — fixed 3-row table | **shell script** — `wc -l` on diff, map to enum, lock section budget. | input: `--stat` line count; output: `{size, sections_allowed}`. |
| 3 | Draft mode (`--draft`) | none | full — fixed flag | **shell script** — flag included in `gh pr create` invocation. | input: PR command; output: `--draft` added. |
| 4 | AI disclosure footer | none | full — fixed string template | **premade prompt template** — appended by the wrapper; skill forbids branding, so the string is fixed. | input: skill URL; output: footer block. |
| 5 | `--body-file` instead of HEREDOC/inline | none | full — fixed rule | **shell script** — write to temp file, pass `--body-file`. | input: body text; output: temp file path. |
| 6 | Banned openers ("This PR", "This change", …) | none | full — fixed list | **linter** — reject sentences starting with banned phrases. | input: body text; output: `{valid: bool, violations: [...]}`. |
| 7 | ≤2-noun-stack title rule | low — rule has examples | mostly — JavaScript-style noun-phrase chunking | **premade prompt template** with the rule baked into the prompt; a post-processor could also rephrase offending stacks. | input: candidate title; output: rewritten title. |
| 8 | Title — verb + scope wording | high — what to call the change | none | **keep-as-model** — semantic summary. | input: diff; output: title string. |
| 9 | TL;DR — two sentences (symptom + what) | high — needs domain understanding | none | **keep-as-model** — the *symptom* is judgment; the *two-sentence structure* is enforced by linter. | input: diff; output: TL;DR string. |
| 10 | Files table (medium+) — "start here" + per-file "Why" | medium — where to start | start-here marker is a single annotation | **AgentSwarm `{{item}}`** to parallelize per-file "Why" drafts, then model merges with start-here. | input: file list; output: `{file, why, start_here: bool}`. |
| 11 | Section inclusion per size gate | low — gate is fixed | full | **shell script** — section list by size enum. | input: size; output: allowed sections. |
| 12 | Post-generation review checklist (diff echo, weak openers, 6-month test) | none | full — fixed checklist | **linter** — automated checks for every checklist item. | input: body; output: per-item pass/fail. |
| 13 | Visual aids (mermaid, before/after, `<details>`) | medium — when faster than prose | none | **keep-as-model** — selection is judgment. | input: diff + body; output: visual aid or none. |

## Notes

- This skill is richer in mechanical structure than it appears: the step list (1–4) is nearly deterministic, the size gate is a table lookup, the AI disclosure is a fixed string, and the apply step is a fixed `gh` invocation.
- The **judgment core** is genuinely narrow: title wording, TL;DR symptom, files-table "Why" per file, visual-aid selection. Everything else is table-driven or scriptable.
- The biggest unrealised win is a **size-gate + section-budget enforcer** that runs the gate, decides the section list, and refuses to render sections outside the budget. The model would only draft the *content* of allowed sections.
- The AI disclosure rules are interesting: the footer is a fixed string, but the skill also forbids *naming* the tool/model — a constraint best enforced by a post-processor that strips agent names.
- The skill cross-references `ste100` for prose; that seam is owned by `ste100`'s own sampling artifact and not duplicated here.
