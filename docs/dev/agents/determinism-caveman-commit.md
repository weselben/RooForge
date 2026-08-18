# Determinism sampling — caveman-commit

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/caveman-commit.log` (gitignored).

## Sample

- **Task:** write the commit message for "adds docs/dev/agents/determinism-forge.md, a sampling-findings artifact for ticket #32; docs only"; then split decisions into mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:27:42Z, exit 0, 87 log lines (incl. model reasoning).
- **Outcome:** model produced `docs: add determinism-forge sampling findings` (44 chars) + `Refs #32` body — and, unprompted, reasoned about this repo's AGENTS.md scope convention to decide whether to omit the scope.

## Observed meta-decisions

- Read `skills/caveman-commit/SKILL.md` first, then walked its rule list as a checklist: type, scope, imperative mood, length cap, trailing period, body policy, issue reference.
- Type pick (`docs`) was a direct lookup from "docs only" in the change description — zero deliberation.
- Scope pick required **cross-referencing AGENTS.md** ("scope … is the name of the skill the commit touches") — the model treated repo convention as an external lookup and concluded "omit scope" was the rule-compliant call.
- Counted subject characters explicitly to verify the ≤50 cap — a mechanical check the model performs by hand.
- Judgment confined to subject *wording* ("sampling findings" over "findings artifact") and body minimality.
- Did **not** modify files (respected the DRY RUN contract).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Read the diff / change description | none | full — `git diff --staged` is fixed | **shell script** — `git diff --staged --stat` + full diff capture; no model needed to obtain the input. | input: repo; output: diff text on stdout. |
| 2 | Type pick from the enum | low — 11 fixed types | mostly — many changes map 1:1 (docs-only → `docs`, test-only → `test`) | **shell script for the trivial cases** (path-prefix heuristic: only `docs/` touched → `docs`, only `tests/` → `test`); keep-as-model for mixed diffs. | input: changed-path list; output: type string ∈ enum, or `AMBIGUOUS`. |
| 3 | Scope pick per repo convention | low — rule is in AGENTS.md | full — lookup table (skill touched → skill name; else omit) | **shell script** — diff path prefix `skills/<name>/` maps directly to scope `<name>`; this repo's convention is mechanically derivable. | input: changed-path list; output: scope string or empty. |
| 4 | Format enforcement (imperative, ≤50/72 chars, no trailing period, bullets `-`, wrap 72) | none | full | **deterministic linter** — a `commit-msg`-style hook or Node script can validate/repair every format rule without a model. | input: message text; output: `{valid: bool, violations: [...]}`. |
| 5 | Subject wording (the imperative summary itself) | high — compressing intent into ≤50 chars | none | **keep-as-model** — this is the semantic core; ADR 0005 classifies summary authoring as judgment. | input: diff + type/scope; output: subject line. |
| 6 | Body necessity + content (non-obvious why, breaking, migrations) | medium — "why not obvious" is a judgment | auto-clarity triggers are enumerated (breaking, security, migration, revert) | **keep-as-model** for the why; the *triggers* that force a body are machine-checkable flags (`!` in subject, BREAKING CHANGE footer). | input: diff + flags; output: body text or empty. |
| 7 | Issue reference trailer | none | full — `Refs #N` / `Closes #N` at end | **shell script** — ticket number comes from branch name / map context; templated trailer. | input: issue number; output: trailer line. |

## Notes

- Caveman-commit is the most mechanically decomposable skill sampled so far: of its seven steps, only subject wording (5) and body authoring (6) are genuinely judgment. Steps 1–4 and 7 are scriptable end-to-end.
- The strongest seam: a **`commit-msg` linter/hook** (step 4) gives determinism immediately without touching the model's wording freedom. It is also the cheapest to build — pure regex/length checks.
- The sample shows the model *already* defers to repo convention files (AGENTS.md) for scope — meaning a script that encodes the same convention would not fight model behaviour; it would just remove the need for the lookup.
- Borderline: type/scope picks (2, 3) are mechanical *for this repo's conventions*; a generic version needs the convention table as config.
