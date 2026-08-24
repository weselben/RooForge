# ADR 0007: `loops` scripts migrate from shell to Node

Status: Accepted
Date: 2026-08-18
Decision Makers: weselben + agent

## Context

`skills/loops/scripts/run_loop.sh` is the pipeline's single home for
`kimi -p` iteration, driving review/resolve loops with grep-based
`DONE:`/`BLOCKED:` contracts. Per ADR 0005, wrappers around the harness
syntax (kimi -p, loops) are Node (.js) going forward, not shell. Shell
templating of prompt files is brittle (sed-based placeholder
substitution), and the companion `cavemanize.sh` already has a known
caveat (strips "the" inside code blocks).

The migration also carries housekeeping: stale duplicate templates at
`skills/pr-review/templates/review-loop.md` and
`skills/pr-resolve/templates/resolve-loop.md` (older placeholder
conventions) coexist with the live `scripts/templates/` copies — two
sources of truth.

## Decision

Migrate the `loops` script framework to Node within the determinism
map's scope (ticket #36):

- `run_loop.js` replaces `run_loop.sh` (same contract semantics:
  `DONE:`/`BLOCKED:` lines, exit codes, per-iteration logs in
  `.loops/`).
- Prompt templates render via the Node wrapper API (prototyped in
  ticket #35) — no shell templating.
- Shared reusable templates move into `skills/loops/templates/`;
  per-skill custom parts stay in `skills/<skill>/templates/`.
- Stale duplicate templates in `skills/pr-{review,resolve}/templates/`
  are deleted in the same change.
- Callers (pr-review, pr-resolve) switch to `node run_loop.js`.

The migration is behaviour-preserving: identical contract lines and
exit codes, validated against existing callers.

## Consequences

**Positive**
- One language for wrappers and loop drivers; template rendering
  becomes real substitution instead of sed.
- Single source of truth for loop templates; drift eliminated.
- Node wrapper API gets its first production consumer.

**Negative**
- Node becomes a hard runtime requirement for review/resolve flows.
- The migration must not silently change loop semantics; validation
  against existing callers is mandatory.

**Risks**
- Subtle behaviour drift between `run_loop.sh` and `run_loop.js`
  (e.g. buffering, exit-code propagation) could break pr-review's
  contract parsing. Mitigation: acceptance requires identical exit
  codes and contract output on existing callers.

## Related

- Wayfinder map: issue #31
- Tickets: #35 (T4 wrapper prototype), #36 (T5 migration)
- ADR 0005 (policy mandating Node wrappers)
