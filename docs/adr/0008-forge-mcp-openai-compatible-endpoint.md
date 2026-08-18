# ADR 0008: `forge-mcp` exposes an OpenAI-compatible endpoint, BYO upstream

Status: Accepted
Date: 2026-08-18
Decision Makers: weselben + agent

## Context

Some pipeline work is "model in the middle": take structured input,
let an LLM transform it, take structured output. The canonical example
is PR body creation — a pre-formatted prompt (diff summary, task list,
disclosure line) compressed by one LLM pass into a ready-to-post body.
Today this kind of work lives inside skill prose, executed by whatever
agent happens to be running — same customization-surface problem as the
tracker operations.

If `forge-mcp` (ADR 0006) already exists as a tool gateway, giving it a
second surface — an LLM gateway — collapses these model-in-the-middle
steps into single tool calls, with provenance tagging (e.g. an
LLM-generated marker) applied centrally.

## Decision

`forge-mcp` exposes `/v1/chat/completions`, OpenAI-compatible, as a
second surface alongside its MCP tools (ticket #39).

- **BYO upstream only**: the server ships no bundled default LLM.
  Upstream URL, key, and model come from environment config
  (`FORGE_MCP_LLM_URL`, `FORGE_MCP_LLM_API_KEY`,
  `FORGE_MCP_LLM_MODEL`). Missing config → the server fails loudly at
  startup.
- The server can run an internal LLM tool-calling loop against its own
  MCP tools — it is both MCP server and chat-completions gateway.
- Outputs the server transforms carry a provenance prefix/suffix tag
  declaring them LLM-generated.

First validated caller: deterministic PR body generation
(ticket #40).

## Consequences

**Positive**
- Model-in-the-middle steps become callable tools with typed I/O —
  no per-skill prose machinery.
- Provenance tagging is centralised, not per-skill policy.
- BYO keeps the server free of provider lock-in and credentials.

**Negative**
- Two surfaces (MCP + chat-completions) double the server's contract
  surface; both need documentation and smoke tests.
- Fail-loud startup means environments without a configured upstream
  cannot run the server at all, even for tool-only use — acceptable
  trade-off per the decision, but worth revisiting if tool-only
  deployments emerge.

**Risks**
- The endpoint invites scope creep ("just one more LLM feature"). The
  map's Not-yet-specified section, not this ADR, absorbs new use cases
  — each must graduate through its own ticket.

## Related

- Wayfinder map: issue #31
- Tickets: #39 (T8 endpoint), #40 (T9 PR-body prototype)
- ADR 0006 (the server this endpoint extends)
