# ADR 0005: Mechanism assignment policy — MCP-first, Node wrappers, AgentSwarm builtin

Status: Accepted
Date: 2026-08-18
Decision Makers: weselben + agent

## Context

Determinizable forge steps need a deterministic replacement mechanism.
Several candidates exist: shell scripts, a custom MCP server, `kimi -p`
spawns with premade prompts, the existing `loops` framework, and Kimi
Code's native subagent/AgentSwarm with `{{item}}` template support.
Without an assignment policy, each step decision would re-litigate the
same trade-offs, and the pipeline would accumulate a mixed bag of
bespoke mechanisms — more bloat, more customization surface, the
opposite of the goal.

The user's standing intent: reduce bloat and dependence on custom
harness machinery, even to the point of deleting whole skills when
their work collapses to tool calls.

## Decision

Per-step mechanism assignment follows this fixed policy:

1. **Tracker/infra operations → MCP tool.** Operations with hidden
   inputs (database ids, dependency wires) or cross-skill reuse (label
   setup, frontier query, claim, resolve) become typed tools on
   `forge-mcp`. Not shell scripts: these are less a shell
   implementation scope and benefit from typed I/O.
2. **Model-in-loop steps → Node (.js) wrapper + premade prompt
   template.** `kimi -p` invocations are spawned by Node wrappers that
   render `.md` templates with strict input/output contracts. Not
   shell: wrappers live in `.js` going forward.
3. **Parallel fan-out → AgentSwarm (built-in).** Homogeneous item
   dispatch uses the harness's native swarm feature with `{{item}}`
   templates.
4. **Iterate-until-criterion → loops (migrated to Node, see ADR 0007).**
5. **Genuine judgment → keep as model, with rationale.** Chart-mode
   grilling, fog graduation, plan authoring, breaker adjudication,
   conflict-hunk intent stay model-driven.

**Skill collapse is permitted, carefully**: when T1/T3 analysis shows a
skill's entire work collapses to one or a few tool calls, the skill may
be deleted and replaced. Never blanket — each candidate must earn its
collapse, and the collapse decision itself is a grilling ticket.

Shared premade-prompt templates live in `skills/loops/templates/`;
per-skill custom template parts live in `skills/<skill>/templates/`.

## Consequences

**Positive**
- One policy, applied mechanically — step decisions stop being debates.
- Skill collapse path gives a concrete route to less bloat.
- Template homes are fixed, so new premade prompts have an obvious
  place to live.

**Negative**
- Some steps will sit awkwardly on a boundary (e.g. a mostly-shell
  operation with one typed-output need); the matrix review (T3) must
  adjudicate these case by case.
- Committing to Node wrappers adds a runtime requirement where pure
  shell previously sufficed.

**Risks**
- Over-eager collapse could delete a skill whose prose carries
  subtle judgment the sampling pass missed. The "carefully" clause
  plus HITL matrix review is the mitigation.

## Related

- Wayfinder map: issue #31
- Tickets: #33 (T2 MCP surface), #34 (T3 mechanism matrix)
- ADR 0004 (sampling criterion), ADR 0006 (forge-mcp), ADR 0007
  (loops migration)
