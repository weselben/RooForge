# CONTEXT

Domain glossary for the `skills-and-conventions` repository. Each entry explains a term an agent must know to work this repo, and cross-references any ADR that records the decision behind the term.

## Skills

A `skill` is a self-contained directory under `skills/<name>/` whose primary entry is `SKILL.md`. Skills are loadable units of behaviour an agent pulls in mid-session. A skill may bundle extra files — `scripts/`, `templates/`, companion markdown — referenced from its `SKILL.md`.

A `scope` is the `(<name>)` part of a Conventional Commit message (`feat(<scope>): ...`). In this repo each skill gets its own scope so commits group by skill. A commit that touches more than one skill uses the scope of the dominant change, or splits into multiple commits.

A `bundle` is a Conventional Commit that introduces or updates one skill, plus any of its companion files, in a single commit.

## ADR

An `ADR` is an Architecture Decision Record under `docs/adr/NNNN-slug.md` that captures a hard-to-reverse, surprising, or trade-off-bearing decision. The glossary in this file is the ADR index — there is no `docs/adr/README.md`.

## Forge

This repo is the upstream home of the `forge` skill family. Other skills in the collection reference `forge` and cascade through it. The orchestrator flow itself is `map → resolve → plan → work → verify → review → resolve`, and is described in `skills/forge/SKILL.md`.

## Determinism

A `determinism seam` is a step in a skill where model judgment can be replaced by a deterministic mechanism (shell script, MCP tool, premade prompt template, AgentSwarm invocation). Seams are identified empirically via a `sampling pass`: running a realistic sample task per skill through `kimi -p` and checking which parts of the run are always the same. See ADR 0004.

A `mechanism matrix` is the per-step assignment of each determinized step to exactly one mechanism — MCP tool, Node wrapper + template, AgentSwarm, or keep-as-model. Assigned per ADR 0005.

`forge-mcp` is the custom MCP server exposing tracker operations as typed tools, plus an OpenAI-compatible `/v1/chat/completions` endpoint (BYO upstream). See ADRs 0006 and 0008.

`skill collapse` is the deletion of a skill whose entire work collapses to one or a few tool calls. Permitted carefully, per ADR 0005.

A `premade prompt template` is a `.md` prompt file rendered with placeholder substitution into a `kimi -p` spawn. Shared templates live in `skills/loops/templates/`; per-skill custom parts in `skills/<skill>/templates/`.

## ADRs

- **ADR 0001** — Vendoring strategy: upstream skills get adapted, not symlinked. Strip implementation details that re-state what loaded skills already expose. See `docs/adr/0001-vendoring-strategy-upstream-adapted.md`.
- **ADR 0002** — Deprecate `/setup-matt-pocock-skills` command. One less bootstrap step, tracker resolution via `git-issue-tracker` or local-markdown fallback. See `docs/adr/0002-deprecate-setup-matt-pocock-skills.md`.
- **ADR 0003** — `deep-research` skill replaces upstream `/research` subagent. Single research skill, one convention. Wayfinder references updated. See `docs/adr/0003-deep-research-replaces-research-subagent.md`.
- **ADR 0004** — Determinism criterion: per-skill `kimi -p` sampling finds always-same parts. See `docs/adr/0004-determinism-criterion-kimi-p-sampling.md`.
- **ADR 0005** — Mechanism assignment policy: MCP-first infra, Node wrappers + templates for model-in-loop, AgentSwarm for fan-out, careful skill collapse. See `docs/adr/0005-mechanism-assignment-policy.md`.
- **ADR 0006** — Build `forge-mcp` MCP server for tracker operations; tool surface deferred to T1/T2 findings. See `docs/adr/0006-build-forge-mcp-server.md`.
- **ADR 0007** — `loops` scripts migrate shell → Node; single template source of truth. See `docs/adr/0007-loops-migrate-shell-to-node.md`.
- **ADR 0008** — `forge-mcp` exposes OpenAI-compatible `/v1/chat/completions`, BYO upstream, provenance-tagged output. See `docs/adr/0008-forge-mcp-openai-compatible-endpoint.md`.