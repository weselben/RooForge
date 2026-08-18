# Determinism sampling — dispatching-parallel-agents

Sampling pass per ADR 0004. Raw stdout at `.tmp-determinism/logs/dispatching-parallel-agents.log` (gitignored).

## Sample

- **Task:** dispatch 3 read-only explorations over `skills/forge`, `skills/wayfinder`, `skills/loops`.
- **Run:** `kimi -p` on 2026-08-18T01:27:57Z, exit 0, 55 lines.
- **Outcome:** produced a clean YAML-shape AgentSwarm call with `{{item}}` placeholder, `subagent_type: explore`, items list, and the MANDATORY FIRST block. Correctly identified what is always-the-same vs judgment.

## Observed meta-decisions

- Used `subagent_type: explore` (correct — read-only).
- Stated the MANDATORY FIRST block explicitly (per the skill's "MANDATORY FIRST" mandate).
- Identified that for **read-only exploration**, no skill load is required — but the block still appears, stating that.
- Did **not** modify files.

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Identify independent domains | high — partition quality drives parallel safety | none | **keep-as-model** — judgement-heavy, ADR 0005 #5 keeps it. | input: problem; output: domains[] with non-overlap claim. |
| 2 | Partition into items — one per domain | medium — naming and granularity | one-item-per-domain rule | **keep-as-model** for the partition; the wrapper just consumes it. | input: domains[]; output: items[]. |
| 3 | Write `prompt_template` with `{{item}}` | high — broader + task context, STE100 | `{{item}}` placeholder, MANDATORY FIRST header, ≥2 items, named deliverable | **keep-as-model** for the prose; the template shell is mechanical. | input: item[]; output: filled prompts[]. |
| 4 | `AgentSwarm` dispatch — single tool call in the response | none — one tool call per response | full | **AgentSwarm `{{item}}`** — already the canonical mechanism (ADR 0005 #3). | input: prompt_template, items[], subagent_type, optional resume_agent_ids; output: per-item reports[]; cap 10. |
| 5 | Review and integrate | high — read summaries, spot-check claims | none | **keep-as-model** — the verification-after-the-swarm step. | input: reports[]; output: integration result + any overlap findings. |
| 6 | Verification after swarm | medium — run full suite, spot-check per-agent claim | full suite run is mechanical | covered by `verification-before-completion`. | gate: full suite green. |

## Notes

- This skill is **already the canonical mechanism** for parallel fan-out — AgentSwarm with `{{item}}` is the harness's built-in. The skill itself does not need replacement; downstream callers need to use it correctly.
- The MANDATORY FIRST block is a **hard contract** — it's the only way the skill library reaches a blank subagent. Should be a literal token in templates.
- The **partition** step (which domains, what's independent) is the genuine judgment; everything else is wrapper/dispatch.
- Surprising observation: the model itself, given the skill, generated a YAML-shape spec for the call. That's a useful hint — the spec is already typed-shaped, which would translate cleanly to a typed wrapper if any caller needed it.