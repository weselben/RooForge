# Determinism sampling — conventional-commits

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/conventional-commits.log` (gitignored).

## Sample

- **Task:** format a commit for "breaking change — skill frontmatter field 'description' renamed to 'when'"; output full message and split mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:27:42Z, exit 0, 103 log lines (incl. model reasoning).
- **Outcome:** model produced `refactor(skills)!: rename frontmatter \`description\` field to \`when\`` + body + `BREAKING CHANGE:` footer; explicitly reasoned about `refactor` vs `feat!` (same SemVer effect, different framing).

## Observed meta-decisions

- Read `skills/conventional-commits/SKILL.md` first, then applied the v1.0.0 spec rules as a checklist.
- The type pick (`refactor` vs `feat`) was flagged as a *framing* judgement with identical SemVer consequence (`MAJOR` either way) — a subtle observation the model surfaced unprompted.
- Mechanical rules were applied verbatim: `!` after scope, `BREAKING CHANGE:` uppercase, blank-line separators, imperative subject, no period.
- Counted final message lines (8) against the 15-line budget — fine as printed.
- Did **not** modify files (respected the DRY RUN contract).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Apply the format shape (`<type>[(scope)]!: <description>` + blank lines + footer) | none | full — fixed by the v1.0.0 spec | **deterministic linter** — a `commit-msg`-style hook validates every rule (prefix, `!`, `BREAKING CHANGE:` uppercase, blank-line separators). | input: message text; output: `{valid: bool, violations: [...]}`. |
| 2 | Enforce the type enum (11 types) | none | full — fixed enum | **kept-as-model** for the pick, but type validation is a script. | input: type string; output: valid ∈ enum. |
| 3 | Type pick from the change description | low — many cases map 1:1 | mostly — only the refactor-vs-feat edge is ambiguous | **shell script** for the obvious cases (path-prefix heuristic, same as caveman-commit); keep-as-model for ambiguous framing. | input: changed-path list + diff; output: type candidate or `AMBIGUOUS`. |
| 4 | `!` marker / `BREAKING CHANGE:` footer | none | full — spec rule | **static detection** — any diff that removes a public symbol, renames a field, or changes a signature triggers `!`; the marker is then templated. | input: diff; output: `{breaking: bool, evidence: [...]}`. |
| 5 | Imperative subject, ≤72 chars, no trailing period, lowercase first letter | none | full — fixed | **linter** — regex/length checks. | input: subject; output: valid. |
| 6 | Body wrap at 72 chars | none | full — fixed | **linter** — wrap on emit. | input: body line; output: wrapped line ≤72 chars. |
| 7 | Footer tokens (`BREAKING CHANGE:`, `Refs:`, `Closes:`) | none | full — known token set | **linter** — token presence/case check. | input: footer; output: valid. |
| 8 | Subject wording (the imperative summary) | high — semantic compression | none | **keep-as-model** — authoring judgment. | input: diff + type; output: subject. |
| 9 | Body content (non-obvious why) | medium | none | **keep-as-model** — the why is judgment. | input: diff + context; output: body or empty. |
| 10 | Footer wording for breaking change | medium | none | **keep-as-model** — wording is judgment, presence is mechanical. | input: change description; output: footer text. |

## Notes

- The seam analysis is nearly identical to caveman-commit: 4–5 mechanical rules (linter-valiable), 2 wording judgments (subject, body, footer).
- The interesting model move — flagging `refactor` vs `feat!` as framing-identical — shows the model is sensitive to the **SemVer coupling** even when the spec is silent on it. This is a property to preserve in any automation (the type enum should be taxonomically honest, not a SemVer switch).
- The strongest determinism win is again a **`commit-msg` linter** that validates every spec rule in one pass; the format is so canonical that no model judgement is needed for *correctness* once the wording is generated.
- This skill and caveman-commit overlap heavily; a single shared linter would serve both.
