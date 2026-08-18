# Determinism sampling — forge

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/forge.log` (gitignored).

## Sample

- **Task:** simulate session start, no map exists, user says "plan a payment idempotency effort".
- **Run:** `kimi -p` on 2026-08-18T01:29:04Z, exit 0, 91 log lines (incl. model reasoning).
- **Outcome:** model produced an 11-step trace, correctly classifying 5 mechanical phases and 4 judgment phases; surfaced a real tension between "Single path" and the user's "plan" phrasing.

## Observed meta-decisions

- Read `skills/forge/SKILL.md` first, then walked the diagram in order.
- Branched correctly per the no-map case → `wayfinder` chart.
- Surfaced an ambiguity the SKILL.md itself does not pre-resolve: when the user says "plan" but the no-map path mandates chart→resolve→plan, the model flagged a judgment call (lightweight chart vs full rigour).
- Did **not** modify files (respected the DRY RUN contract).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Auto-load always-on skills (`forge-flow`, `caveman`, `wayfinder`) | none | full — mandate in `SKILL.md` Invariant rules | **Skill auto-load is harness-side** — already deterministic; keep-as-model only because the harness exposes the load. | input: session start; output: three skills in context; machine-checkable: required skill list appears in prompt prefix. |
| 2 | Detect map (URL / number / tracker / none) | none | full — three-case lookup table | **MCP tool `forge_mcp.detect_map(repo)`** — typed I/O for the three branches. | input: `repo` string; output: `{status: "url"\|"tracker"\|"none", value?: string}`. |
| 3 | Branch load-vs-chart | none when no map (single-path rule); trivial when map exists | full | **collapses into #2** — MCP `detect_map` returns the branch. | covered by #2. |
| 4 | Invoke `wayfinder` chart (grilling + domain-modeling) | high — which questions, which terms | harness dispatch only | **AgentSwarm `{{item}}`** for fog areas (already standard); grilling itself stays model-driven per ADR 0005. | item: fog area string; output: chart artifact; gate: `frontier.length ≥ 1`. |
| 5 | Decide skip-Resolve-vs-full-rigour after chart when user asked "plan" | high — this is the genuine friction point | none | **keep-as-model** — surface to user; ADR 0005 lists "plan authoring" as judgement. | input: user intent + map state; output: branch choice + one-line rationale. |
| 6 | Invoke `planning-and-task-breakdown` and write plan file | high — slicing decisions | harness calls (`EnterPlanMode`, `ExitPlanMode`) | **keep-as-model** for content; plan-mode calls are harness-deterministic. | output: plan file at the harness's plan path; approval gate. |
| 7 | Step 4–8 (work / verify / review / resolve) | distributed across SDD / pr-review / pr-resolve | each phase is its own skill with its own seam analysis | see `determinism-subagent-driven-development.md` etc. | per skill. |

## Notes

- The biggest observable seam at the orchestrator level is **detect-map + branch**, which is pure lookup against the tracker and the git branch list. That belongs on `forge-mcp` per ADR 0005 (tracker/infra → MCP).
- Forge itself is mostly a **router**; the seam analysis lives downstream in the skills it dispatches to.
- The "skip Resolve after chart on user request" decision is the only genuine orchestrator-level judgment in this run — keep-as-model.