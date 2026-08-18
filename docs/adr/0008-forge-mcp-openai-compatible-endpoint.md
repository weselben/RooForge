# ADR 0008: `forge-mcp` exposes an OpenAI-compatible endpoint, BYO upstream

Status: Deferred (2026-08-18)
Superseded-by: none — will be reactivated when the chat-completions endpoint is planned

## Decision

`forge-mcp` exposes `/v1/chat/completions`, OpenAI-compatible, as a
second surface alongside its MCP tools.

**Status: deferred per user direction (2026-08-18).** The feature is
non-blocking and can be planned later. The endpoint, its BYO upstream,
the provenance tagging, and the redaction story all pause here. Tickets
#39 (T8) and #40 (T9) are closed with `deferred` labels. ADR 0008 is
amended to `Deferred` status — the architectural questions (provenance
tagging, redaction, data-boundary policy) remain open for a future
effort, not this map's scope.

## Consequences

**Positive**
- Model-in-the-middle steps become callable tools with typed I/O —
  no per-skill prose machinery.
- Provenance tagging is centralised, not per-skill policy.
- BYO keeps the server free of provider lock-in and credentials.

**Negative**
- Deferred: the trust model, privacy model, and data-boundary policy
  for the endpoint are all open questions for a future effort.
- Tickets #39 (T8 endpoint build) and #40 (T9 PR-body prototype) are
  closed as deferred; they reactivate when the endpoint is planned.
- Provenance tagging, redaction, and BYO upstream details remain
  undecided.

**Risks**
- The deferral is explicit — a future porter reactivating the endpoint
  must re-open T19 (#84) and re-grill the trust/privacy questions.

## Related

- Wayfinder map: issue #31
- Tickets: #39 (T8 endpoint), #40 (T9 PR-body prototype)
- ADR 0006 (the server this endpoint extends)
