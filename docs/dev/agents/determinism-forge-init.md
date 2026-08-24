# Determinism sampling — forge-init

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/forge-init.log` (gitignored).

## Sample

- **Task:** trace steps 1–2 as dry run when AGENTS.md already exists with a `## Build` section; state what to prepend/append, what grilling waves target, and the mechanical/judgment split. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:28:25Z, exit 0, 30 log lines (incl. model reasoning).
- **Outcome:** model produced the smart-append plan (preserve `## Build`, prepend header, merge jargon, append footer), listed candidate grilling topics, and correctly identified which parts are rule-shaped vs interpretive.

## Observed meta-decisions

- Read `skills/forge-init/SKILL.md` first, then read `./agents.template.md` to get the actual template content.
- Treated the **existing `## Build` section as user-written** — flagged the "do not touch user prose" rule as the dominant constraint on smart-append.
- Decomposed the merge into per-term operations: check if term exists, skip duplicates, append missing — an explicit algorithm the skill implies but doesn't spell out.
- Probed whether `## Build` content is stack-inferable (candidate for removal per the "no stack-specific content" rule) — but only via user confirmation, consistent with the grilling rule.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Detect AGENTS.md existence | none | full — `test -f` | **shell script** — file existence check. | input: repo root; output: `{exists: bool}`. |
| 2 | Prepend mandatory header if absent | low — detect "absent" by marker | mostly — header is fixed text | **shell script** — grep for the letter's opening line; prepend fixed block if missing. | input: file; output: prepend-or-noop. |
| 3 | Merge jargon terms (skip duplicates) | medium — detect duplicates | rule is fixed | **premade prompt template + Node wrapper** — template asks "for each template term, is it already defined here?"; wrapper appends only missing. | input: template + existing AGENTS.md; output: merged file. |
| 4 | Append footer once (idempotent) | none | full — fixed string | **shell script** — append if grep fails. | input: file; output: append-or-noop. |
| 5 | Never commit / stage AGENTS.md | none | full — fixed rule | **shell script** — `.git/info/exclude` or pre-commit check. | n/a. |
| 6 | Completion criterion grep (header + jargon + footer present) | none | full — fixed markers | **shell script** — three greps. | input: file; output: `{complete: bool}`. |
| 7 | Load `grilling` and run waves of 4 | low — already delegated | full — fixed wave cadence | **AgentSwarm `{{item}}`** — dispatch one subagent per wave? No — grilling is interactive with the user; keep the wave driver model-driven but the wave *shape* scriptable. | n/a. |
| 8 | Translate user answers to STE100 | medium — interpretation | rule is fixed | **keep-as-model** — STE100 is a separate skill with its own seam analysis. | per `ste100`. |
| 9 | Goal-driven phrasing ("the goal is X, so the agent must Y") | high — semantics | none | **keep-as-model** — authorship. | input: user answer; output: contract line. |
| 10 | "Is this as intended?" confirmation | none | full — fixed phrase | **shell script** — prompt + response capture. | input: drafted line; output: confirm/revise. |
| 11 | Skip stack-specific content (frameworks, runtimes) | none | full — fixed rule | **linter** — scan drafted lines for framework/ORM/language mentions. | input: draft; output: violations. |
| 12 | One-shot idempotency (re-runs only update) | low — detect "already ran" | state markers exist | **shell script** — same grep markers as step 6. | input: file; output: {ran_before: bool}. |

## Notes

- Forge-init is a **configuration bootstrap**: the mechanical half is file existence, header prepend, footer append, jargon merge, idempotency — all scriptable. The judgment half is grilling content and STE100 interpretation.
- The single most valuable deterministic win is a **`forge_mcp.agents_merge(template, existing)` MCP tool** that performs steps 1–6 without a model: prepend-if-missing, merge-jargon-skip-duplicates, append-footer, verify. The model is then only needed for the grilling loop.
- The grilling loop is interactive by design; the only determinism worth adding is the *question cadence* (waves of 4, confirmation after each), which a wrapper can drive by counting turns.
- The "no stack-specific content" rule is already a lintable constraint — a regex pass can flag framework/ORM mentions before the user confirms.