# ADR 0006: Build `forge-mcp` — a custom MCP server for tracker operations

Status: Accepted
Date: 2026-08-18
Decision Makers: weselben + agent

## Context

Tracker operations in the forge pipeline (label setup, map/ticket CRUD,
sub-issue wiring, native blocking, frontier queries, claim, resolve,
branch association) are currently prose-described `gh` commands inside
`skills/git-issue-tracker/SKILL.md`. Every skill that touches the
tracker re-derives these commands from prose — model judgment applied
to what is fundamentally a typed API surface.

ADR 0005 assigns tracker/infra operations to an MCP server. No MCP
server exists in the pipeline today (only the peripheral
`mcp/pdf-curl-server.*` for docs fetching).

## Decision

Build **`forge-mcp`**, a custom MCP server exposing tracker operations
as typed tools. The exact tool surface is deliberately **not fixed
here**: it is proposed from the T1 sampling findings (ticket #32),
reviewed line-by-line by the user (ticket #33), and only approved
entries are built (ticket #37). This decision commits to the server's
existence, not to any specific tool list.

First tool set is expected to cover the high-reuse seams: label setup,
frontier query, map/ticket CRUD, claim, resolve, blocking wire, branch
association lookup — pending T2 approval.

Server registration follows the existing `mcp/*.sh` / `mcp/*.ps1`
launcher convention.

## Consequences

**Positive**
- Typed I/O replaces prose-derived `gh` invocations; hidden inputs
  (database ids) stop being model-managed.
- One server consolidates what was scattered across skill bodies.
- Deferred tool-surface decision keeps this ADR stable even as the
  surface evolves.

**Negative**
- A new runtime component to install, register, and maintain.
- Skills must be re-pointed at the server (follow-up effort, out of
  scope of the map).

**Risks**
- If the T2 review rejects most candidates, the server ships thin and
  the build cost outweighs the benefit. Mitigation: the frontier query
  alone has enough cross-skill reuse to justify the skeleton.

## Related

- Wayfinder map: issue #31
- Tickets: #33 (T2 surface proposal), #37 (T6 build)
- ADR 0005 (policy that routes tracker ops here), ADR 0008 (the
  server's second surface: OpenAI-compatible endpoint)
