# ADR 0002: Deprecate the `/setup-matt-pocock-skills` command

Status: Accepted
Date: 2026-08-08
Decision Makers: weselben + agent

## Context

`skills/wayfinder/SKILL.md` originally instructed agents to run
`/setup-matt-pocock-skills` when the issue tracker had not been provided.
The maintainer decided not to ship this setup flow inside the repo: it
requires interactive prompts, depends on the exact upstream bundle, and
adds a non-trivial bootstrap step before any real work can happen.

Removing the command creates a minor gap: an agent dropped into a fresh
repo with no tracker context still needs guidance. The replacement is to
trust that the relevant tracker-specific skill (`git-issue-tracker` for
GitHub repos) is loaded when needed, and fall back to a local-markdown
tracker when nothing else applies.

## Decision

The `/setup-matt-pocock-skills` command is **not** shipped in this repo
and **must not be referenced** by any vendored skill (wayfinder or
otherwise). All invocations of that command, and all cross-references to
the upstream `setup-matt-pocock-skills/` directory used as a command
source, are scrubbed. Source-attribution links into that directory's
file tree are kept as provenance only.

Tracker resolution simplifies to:

- If a GitHub tracker is implied, load `skills/git-issue-tracker`.
- Otherwise default to the local-markdown tracker.

## Consequences

**Positive**
- One less bootstrap step for every agent session in this repo.
- Removes a coupling to an external bundle the maintainer doesn't control.
- Smaller install footprint.

**Negative**
- An agent that doesn't auto-load `git-issue-tracker` may lack GitHub
  operations context when first asked to chart a map.
- Local-markdown fallback is the only out-of-the-box alternative; other
  trackers (GitLab, Jira) require the user to provide their own skill.

**Risks**
- Future skills copied from upstream may reintroduce the reference. Any
  new vendoring pass must grep for `setup-matt-pocock-skills` before
  accepting the skill.

## Related

- `skills/wayfinder/SKILL.md` (line 25 after edit)
- ADR 0001 (vendoring strategy that motivates the strip)
