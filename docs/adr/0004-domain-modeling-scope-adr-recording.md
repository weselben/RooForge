# ADR 0004: Domain-modeling scoped to ADR recording; future MCP tool

Status: Accepted
Date: 2026-08-07
Decision Makers: weselben + agent

## Context

The upstream `mattpocock/skills` domain-modeling skill was designed as a
conversational companion to grilling: it pins down domain terminology,
entities, and relationships so that tickets and map destinations share a
precise, shared language. After reading the skill, the maintainer judged
that the conversational aspects overlap with grilling enough to make a
separate skill redundant, but the **ADR-recording guidance** in the
skill is genuinely novel — it specifies when and how to write an ADR
after an architectural decision has been reached in a grilling session.

The maintainer wants the ADR workflow to eventually be powered by a
custom MCP tool rather than prompt-only instructions. Domain-modeling
thus becomes a **bridge** between the grilling skill's output and the
planned MCP tooling, not a standalone conversational skill.

## Decision

The domain-modeling skill's scope is reduced to:

1. **Trigger**: after a grilling session reaches an architectural
   decision, load domain-modeling to determine whether the decision
   warrants an ADR.
2. **Output**: produce a draft ADR file in `docs/adr/` following the
   ADR template (context / decision / consequences / related).
3. **Future**: the draft-and-commit workflow will be replaced by a
   custom MCP tool that writes ADRs programmatically and registers them
   in `CONTEXT.md`.

The conversational domain-terminology aspects of the upstream skill are
**not** pulled into this repo; grilling already covers that ground.

## Consequences

**Positive**
- Keeps the skill count low — one skill for one job.
- Creates a clean upgrade path: the MCP tool replaces a prompt-only
  skill without changing the trigger or output contract.
- ADRs produced by grilling sessions are now a first-class artifact
  rather than a side effect.

**Negative**
- Until the MCP tool exists, ADR creation depends on prompt following —
  no structured validation, no automatic numbering, no guaranteed
  CONTEXT.md updates.
- The skill's guidance (when to record) is only useful inside a
  grilling session; it can't drive standalone ADR creation.

**Risks**
- The MCP tool may arrive with a different file format or numbering
  convention; early ADRs will need a migration pass.
- If grilling sessions drift toward recording decisions inline (in
  README or CONTEXT.md), the ADR skill may become orphaned.

## Related

- `skills/wayfinder/SKILL.md` (lines 79, 111, 124 — references to
  `/domain-modeling` in grilling and map-charting flows)
- `docs/adr/` (the output directory for ADRs)
- `skills/grilling/SKILL.md` (the upstream trigger for ADR creation)
