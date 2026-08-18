# Custom subagents — T16 (#77)

Per T16 ([#77](https://github.com/weselben/RooForge/issues/77)), three agent files committed to `.kimi-code/agents/` on `feat/forge-determinism`:

| File | Type | Purpose |
|------|------|---------|
| `explore.md` | override of built-in `explore` | Read-only exploration that cites `docs/dev/CONTEXT.md`, returns structured `## Handoff` summaries, never modifies files. |
| `pr-review.md` | new mode | Replaces `skills/pr-review/scripts/review-loop.sh`. Fans out to one `explore` per touched file via AgentSwarm. Emits caveman-review one-liners. |
| `pr-resolve.md` | new mode | Replaces `skills/pr-resolve/scripts/resolve-loop.sh`. Groups findings by file, dispatches one `coder` per group, commits, pushes, replies in-thread. |

## Format reference (per Kimi Code CLI `agents.html`)

Each file is plain Markdown with a YAML frontmatter block. Required fields:
- `name` (kebab-case) — auto-derived from filename if missing.
- `description` — shown to the main agent when picking a subagent; the routing key.
- `whenToUse` (optional) — extra hint for delegation.
- `override` (default `false`) — must be `true` for built-in overrides (`explore.md` only in this set).
- `tools` (optional) — allowlist of tool names; MCP tools matched with `mcp__<server>__*` globs.
- `disallowedTools` (optional) — denylist, applied after `tools`.
- `subagents` (optional) — allowlist of subagent names this agent may delegate to.

The body is the system prompt. Use `${base_prompt}` to embed the effective default (built-in default or SYSTEM.md override). Unknown variables stay verbatim; bare `$` is never special.

Three entry shapes never match anything (and report a warning):
- bare `*` outside an `mcp__` pattern;
- `mcp__github` literal (must be `mcp__github__*`);
- a name no registered tool has.

## Trust model (per the docs)

Project-level agent files are prompt configuration. A project-scoped file with `override: true` replaces the built-in's whole system prompt. Files without a `tools` list keep every tool. Review `.kimi-code/agents/` and `.agents/agents/` in unfamiliar repos with the same caution as scripts.

This is the user's own repo (`weselben/RooForge`) — no untrusted-code concern. The override is intentional and documented.

## Linked tickets

- T16 ([#77](https://github.com/weselben/RooForge/issues/77)) — this work.
- T2 ([#33](https://github.com/weselben/RooForge/issues/33)) — surface the `pr-review` / `pr-resolve` collapse candidates from T3.
- T5 ([#36](https://github.com/weselben/RooForge/issues/36)) — `loops` migration; the custom agents consume the Node wrapper API.

## Validation

The agent-file format is validated by the harness on load. Skim the docs (`agents.html`) for the latest field semantics before editing. A file with invalid content is skipped with a warning; explicit `--agent-file` invocations fail loudly.
