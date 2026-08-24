# Determinism sampling — planning-and-task-breakdown

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/planning-and-task-breakdown.log` (gitignored).

## Sample

- **Task:** for "add a BFSG accessibility statement page at /accessibility", produce 4–6 vertical-slice tasks with AC, verification, dependencies, sizing; split mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:29:38Z, exit 0, 37 log lines (incl. model reasoning).
- **Outcome:** model produced 5 tasks (route + shell, BFSG content, feedback mechanism, accessibility audit, discoverability) with explicit dependencies, sizes, and a checkpoint after Task 4 — and explicitly flagged the legal sign-off checkpoint as a judgement the template can't generate.

## Observed meta-decisions

- Read `skills/planning-and-task-breakdown/SKILL.md` first.
- Chose **vertical cuts** (route shell first, then content, then feedback, then a11y audit, then discoverability) — the skill's named rule applied explicitly.
- Sized Task 2 as M, not S, **despite the file count** — the model's reasoning: "M for Task 2 reflects legal-content uncertainty, not file count." This is a genuinely useful disclosure of the mental model.
- Identified parallelization opportunities (Task 5 with 2–3) and sequential dependencies (audit needs all UI present).
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Enter plan mode (read-only, no code writes) | none | full — harness-side | **harness tooling** — no model role. | n/a. |
| 2 | Read spec + repo conventions | none | full — harness reads | **shell script** — read the spec file and a config digest. | input: spec path; output: spec text. |
| 3 | Map dependency graph | high — graph inference | none | **keep-as-model** — the graph is the design. | input: requirements; output: dependency graph. |
| 4 | Choose vertical cuts | high — slicing judgment | none | **keep-as-model** — slicing is the core. | input: graph; output: slices. |
| 5 | Task template (AC/verification/deps/size/files) | none | full — fixed template | **premade prompt template + Node wrapper** — template fills AC/verification slots; wrapper enforces file-count cap and 3-bullet AC rule. | input: task fields; output: formatted task. |
| 6 | Order tasks (deps bottom-up, high-risk early) | medium — risk ranking | rule is fixed | **keep-as-model** for risk; **shell** for topological sort. | input: tasks + risks; output: ordered list. |
| 7 | Sizing (XS/S/M/L/XL) | medium — file count vs uncertainty | table thresholds are fixed | **hybrid** — shell computes file count; model adjusts for uncertainty. | input: task; output: size. |
| 8 | Checkpoint placement (every 2–3 tasks, after risk-heavy step) | low — rule is fixed | full | **shell script** — group tasks into 2–3 chunks. | input: ordered tasks; output: checkpoint list. |
| 9 | Parallelization routing (safe/Must-sequential/needs-coordination) | medium — classification | categories are fixed | **keep-as-model** for the classification; **AgentSwarm `{{item}}`** for the dispatch. | input: task list; output: {safe: [...], seq: [...], coord: [...]}. |
| 10 | Verification checklist (8 items before implementation) | none | full — fixed | **linter** — runs against the plan file, flags missing items. | input: plan file; output: per-item pass/fail. |
| 11 | Plan document template | none | full — fixed | **premade prompt template** — fills skeleton; model populates the variable bits. | input: plan fields; output: plan file. |
| 12 | Plan approval gate (`EnterPlanMode` → user review → exit) | none | full — harness-side | **harness tooling** — no model role. | n/a. |

## Notes

- The skill's **judgment core** is narrow and clear: dependency graph, vertical slicing, ordering, sizing, and risk identification. Everything else is template- or rule-shaped.
- The sample's *honest* sizing note (Task 2 is M because of legal-content uncertainty, not file count) is exactly the kind of disclosure worth preserving in a deterministic version — the wrapper should accept a "size reason" field rather than inferring from file count alone.
- The vertical-slice rule is the single most valuable product of the skill. A wrapper that *forces* vertical slices (refuses to emit a horizontal task) would be valuable, since the model's own example shows horizontal slicing is the natural temptation.
- Plan mode + approval gate are harness-side; no determinism work needed inside the skill.