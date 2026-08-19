# ADR 0003: `Skill(skill='deep-research')` skill replaces upstream `/research` subagent

Status: Accepted
Date: 2026-08-08
Decision Makers: weselben + agent

## Context

`skills/wayfinder/SKILL.md` originally described research tickets as
"Resolved by a `/research` subagent" and "spin up a `/research` subagent"
in the map-charting flow. The `/research` slash command points to the
upstream `mattpocock/skills` collection, which isn't vendored in this
repo. The maintainer ships `skills/deep-research` (sourced from
`MoweME`) instead — it covers the same surface area (evidence-based
research, long-form reports) and is already loaded by other parts of the
workflow.

Two near-identical edit patterns made the replacement mechanical: the
ticket-type description (line 77) and the chart-the-map step 5
(line 115). Both were rewritten to load `Skill(skill='deep-research')` rather
than `/research`.

## Decision

Research tickets in wayfinder are resolved by a subagent running the
**`Skill(skill='deep-research')`** skill (not `/research`). The substitution is applied
wherever wayfinder's body of text describes ticket resolution or the
map-charting sequence.

Upstream `/research` is **not** vendored. If a future need diverges
from `Skill(skill='deep-research')` enough to justify a second research skill, it
should be added under a distinct name rather than reintroducing the
upstream reference.

## Consequences

**Positive**
- One research skill, one set of conventions, one place to maintain.
- `Skill(skill='deep-research')` already integrates with `.memory/` and the slash
  command flow, so resolution artifacts land where the rest of the
  workflow expects them.
- Removes an unreviewed dependency on upstream behavior.

**Negative**
- Wayfinder readers must trust that `Skill(skill='deep-research')` covers what
  `/research` covered; the cross-reference in wayfinder doesn't list
  the protocol.
- If `Skill(skill='deep-research')` evolves away from the AFK-ticket semantics
  wayfinder needs (10+ iteration loop, evidence-based), the fit
  degrades silently.

**Risks**
- A future porter may add `/research` back as a "convenience alias"
  without realizing the deprecation. Vendoring passes must grep for
  `/research` in wayfinder.

## Related

- `skills/wayfinder/SKILL.md` (lines 77 and 115 after edit)
- `skills/deep-research/SKILL.md` (the replacement skill)
- ADR 0001 (the vendoring rule that surfaced the need for this change)
