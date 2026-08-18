# CONTEXT

Domain glossary for the `skills-and-conventions` repository. Each entry explains a term an agent must know to work this repo, and cross-references any ADR that records the decision behind the term.

## Skills

A `skill` is a self-contained directory under `skills/<name>/` whose primary entry is `SKILL.md`. Skills are loadable units of behaviour an agent pulls in mid-session. A skill may bundle extra files — `scripts/`, `templates/`, companion markdown — referenced from its `SKILL.md`.

A `scope` is the `(<name>)` part of a Conventional Commit message (`feat(<scope>): ...`). In this repo each skill gets its own scope so commits group by skill. A commit that touches more than one skill uses the scope of the dominant change, or splits into multiple commits.

A `bundle` is a Conventional Commit that introduces or updates one skill, plus any of its companion files, in a single commit.

## ADR

An `ADR` is an Architecture Decision Record under `docs/adr/NNNN-slug.md` that captures a hard-to-reverse, surprising, or trade-off-bearing decision. The glossary in this file is the ADR index — there is no `docs/adr/README.md`.

## Forge

This repo is the upstream home of the `Skill(skill='forge')` skill family. Other skills in the collection reference `Skill(skill='forge')` and cascade through it. The orchestrator flow itself is `map → resolve → plan → work → verify → review → resolve`, and is described in `skills/forge/SKILL.md`.

## ADRs

- **ADR 0001** — Vendoring strategy: upstream skills get adapted, not symlinked. Strip implementation details that re-state what loaded skills already expose. See `docs/adr/0001-vendoring-strategy-upstream-adapted.md`.
- **ADR 0002** — Deprecate `/setup-matt-pocock-skills` command. One less bootstrap step, tracker resolution via `Skill(skill='git-issue-tracker')` or local-markdown fallback. See `docs/adr/0002-deprecate-setup-matt-pocock-skills.md`.
- **ADR 0003** — `Skill(skill='deep-research')` skill replaces upstream `/research` subagent. Single research skill, one convention. Wayfinder references updated. See `docs/adr/0003-deep-research-replaces-research-subagent.md`.