# ADR 0001: Vendoring strategy — upstream skills get adapted, not symlinked

Status: Accepted
Date: 2026-08-08
Decision Makers: weselben + agent

## Context

The skills-and-conventions repo contains skills adapted from upstream collections
(notably `mattpocock/skills` and `MoweME`). Initial imports embedded GitHub-specific
wiring details (sub-issues, `blocked_by`) directly into `skills/wayfinder/SKILL.md`
because the maintainer had read those upstream skills. The alternative — keeping
a thin pointer and relying on the agent to load the upstream skill — was
considered but rejected because the canonical GitHub operations live in
`skills/git-issue-tracker`, which the agent loads on demand.

The conflict surfaced in a wayfinder edit where line 25 read:

> For repos tracked on GitHub, load the `git-issue-tracker` skill — it wires the
> map↔ticket link via GitHub's native sub-issues and blocking via native issue
> dependencies (`blocked_by`), so both render in the GitHub UI.

## Decision

When porting a skill from an upstream collection, **strip implementation
details that re-state what the loaded skill already exposes**. Wayfinder and
other orchestrator skills reference dependent skills by name and trust the
loader to surface their details. Each skill remains the single source of
truth for its own mechanics; cross-references in upstream skills are not
copied verbatim.

The corollary: a source-attribution link pointing into an upstream skill's
folder (e.g. `git-issue-tracker/SKILL.md:10` referencing the
`setup-matt-pocock-skills` path) is acceptable because it documents
provenance, not because it documents an invocation.

## Consequences

**Positive**
- Skills stay short and don't drift out of sync with the skills they
  reference.
- Editing one skill doesn't risk contradicting the other — the loader
  resolves the conflict at runtime.
- Easier to swap the dependency later (e.g. local-markdown tracker vs
  GitHub) without rewriting the orchestrator.

**Negative**
- A reader who hasn't loaded the referenced skill sees less detail in the
  orchestrator — relies on the loader doing its job.
- Slightly less useful as a standalone document outside an agent session.

**Risks**
- If the loader fails to surface a referenced skill, the orchestrator's
  guidance becomes too thin to act on. Mitigated by the `path:` field in
  skill listings — the loader is required to expose it.

## Related

- `skills/wayfinder/SKILL.md:25` (the post-edit line that triggered this ADR)
- `skills/git-issue-tracker/SKILL.md:10` (source attribution that remains)
