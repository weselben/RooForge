# Determinism sampling — forge-tailwindcss-conventions

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/forge-tailwindcss-conventions.log` (gitignored).

## Sample

- **Task:** reorder one className (`text-white hover:bg-blue-700 flex items-center px-4 py-2 bg-blue-600 rounded-lg dark:bg-blue-500 gap-2`) per the ordering convention; state whether ordering is mechanical or judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:29:04Z, exit 0, 103 log lines (incl. model reasoning).
- **Outcome:** model produced `flex items-center gap-2 px-4 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700 dark:bg-blue-500` — and, notably, **caught an inconsistency in the skill itself**: the numbered list puts colors before effects, but the canonical example puts `rounded-lg` (effects) before `bg-blue-600` (color). The model followed the example because `prettier-plugin-tailwindcss` is the mandatory enforcer.

## Observed meta-decisions

- Read `skills/forge-tailwindcss-conventions/SKILL.md` first.
- Classified each utility into its bucket explicitly (`gap-*` → layout, `rounded-*` → effects, `hover:` → states) — deterministic mapping.
- **Detected the numbered-list vs example contradiction** and resolved it by appealing to the tool that actually enforces the order (`prettier-plugin-tailwindcss`), not by picking one arbitrarily.
- Noted the residual ambiguity of `text-white` (typography vs color bucket) and resolved it from the example.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Detect Tailwind version (v3 vs v4) | none | full — look for `tailwind.config.js` vs CSS-first | **shell script** — check for config file / `@import "tailwindcss"`. | input: repo; output: `{version: "v3"\|"v4"}`. |
| 2 | Apply the class-ordering convention | low — bucket mapping is fixed | mostly — but the skill's own list and example disagree | **shell tool is canonical** — `prettier-plugin-tailwindcss` already implements this; the skill should defer to it rather than re-specify the order. | input: className string; output: sorted string. |
| 3 | Detect anti-patterns (string concat, `@apply`, `!important`, inline styles, missing img dims, no `cn`) | low — each has a fixed shape | mostly — patterns are enumerable | **linter** — `eslint-plugin-tailwindcss` covers several; the rest are grep-shaped (`'bg-' +`, `@apply`, `style={{`). | input: file; output: violation list. |
| 4 | Verification checklist (8 items) | none | full — fixed checklist | **linter** — each item is checkable. | input: file; output: per-item pass/fail. |
| 5 | Design-token authoring in `@theme` (v4) | high — design decisions | none | **keep-as-model** — choosing tokens is design judgment. | input: design intent; output: `@theme` block. |
| 6 | Component extraction (Button, Card, Nav) | high — boundaries are design | none | **keep-as-model** — decomposition is judgment. | input: markup; output: components. |
| 7 | Resolve skill-internal contradictions (list vs example) | medium — which source wins | none | **keep-as-model** — but this is a skill-bug, not a seam; the fix is correcting SKILL.md, not automating around it. | n/a. |
| 8 | Framework-specific patterns (React/Vue/Svelte) | low — reference selection | full — `references/frameworks.md` is a fixed file | **shell script** — detect framework from `package.json`, read matching reference. | input: repo; output: reference path. |

## Notes

- The sample exposed a **skill-internal inconsistency** (numbered list vs canonical example ordering) that a purely mechanical reader would resolve differently than the model did. The model's resolution (follow the Prettier plugin, which is the declared mandatory tooling) is the *correct* call but required judgment — a fixed, deterministic seam would be to correct SKILL.md so list and example agree.
- Once the contradiction is fixed, the ordering convention (step 2) is **fully mechanical and already tooled**: `prettier-plugin-tailwindcss` enforces it at format time. The skill's value is then pointing at the tool, not restating the order.
- Anti-pattern detection (step 3) is largely grep/lint-shaped — `eslint-plugin-tailwindcss` plus a few regexes cover most of the table. The model's residual role is detecting *novel* anti-patterns not yet in the table.
- Framework detection (steps 1, 8) is package.json parsing — pure shell.