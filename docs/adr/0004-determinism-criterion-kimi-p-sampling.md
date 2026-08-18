# ADR 0004: Determinism criterion via per-skill `kimi -p` sampling

Status: Accepted
Date: 2026-08-18
Decision Makers: weselben + agent

## Context

The forge pipeline contains many steps where the model makes open-ended
judgment calls ("pick the next unclaimed ticket", "group findings by
concern", "which command proves it"). Deciding which of these steps can
be replaced by a deterministic mechanism requires an empirical answer to
the question: *which parts of a skill's invocation are always the same?*

A static reading of `SKILL.md` files cannot answer this — the same prose
can produce wildly different model behaviour depending on task context.
Only real runs against the actual harness reveal the always-same parts.

## Decision

Determinism eligibility is established by **sampling**: for every skill
folder under `skills/`, a realistic sample task is chosen and executed
with `kimi -p` via the bash tool. The raw stdout, the model's
meta-decisions (branching, ordering, phrasing), and the process shape
are captured. Parts of the output or process that are invariant across
the sample are deemed *always-same* and become candidates for a
deterministic replacement (shell script, MCP tool, premade prompt
template, or AgentSwarm `{{item}}` invocation).

The sampling methodology itself is the criterion: a step is
"determinizable" only if sampling shows its variable parts are confined
to prose content, not to structure or control flow.

Sampling findings are recorded as one
`docs/dev/agents/determinism-<skill>.md` per skill folder, committed to
the map's feat branch.

## Consequences

**Positive**
- Empirical, not speculative: determinism claims rest on observed runs.
- Per-skill artifacts keep the audit reviewable and incremental.
- The same sampling pass feeds both the mechanism matrix (T3) and the
  MCP tool-surface proposal (T2).

**Negative**
- One sample per skill is thin evidence; borderline calls may need a
  second sample with a different task.
- Running `kimi -p` across ~35 skills costs real tokens and time.

**Risks**
- A skill whose determinism only shows with multiple samples could be
  mis-judged. The T3 matrix review (HITL) is the second line of defence.

## Related

- Wayfinder map: issue #31 (Forge pipeline determinism)
- Ticket: issue #32 (T1 Per-skill `kimi -p` sampling pass)
- ADR 0005 (mechanism assignment policy that consumes these findings)
