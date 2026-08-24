# Subagent model pool — T17 (#78)

Per T17 ([#78](https://github.com/weselben/RooForge/issues/78)), a project-local configuration snippet committed to `.kimi-code/local.toml` on `feat/forge-determinism`. The pool routes subagents to the right model for the job.

## Why

The T1 sampling audit (`docs/dev/agents/determinism-seams-summary.md`) classifies every forge-flow step into one of five buckets: MCP tool, Node wrapper, AgentSwarm fan-out, linter, or keep-as-model. Each bucket's right model differs:

| Bucket | Default model | Why |
|--------|---------------|-----|
| MCP tool | n/a | No LLM in the loop. |
| Node wrapper | n/a | No LLM in the loop. |
| AgentSwarm sweep | `kimi-for-coding-highspeed` | Many cheap parallel `explore` runs. |
| Linter | `kimi-for-coding-highspeed` | Mechanical prose checks. |
| Custom agent (review/resolve) | `kimi-for-coding` | Balanced for feature-grade judgment. |
| Domain-judgment residue | `kimi-code/k3` | Hard reasoning, architecture, deep debugging. |

A single default model wastes either speed (highspeed for hard problems) or quality (k3 for cheap sweeps). The pool lets the main agent pick per spawn, and the custom agents' `subagents` allowlist (`tools:`/`subagents:` frontmatter) constrains which models each can dispatch to.

## Format reference (per Kimi Code CLI `config-files.html#subagent-model-pool`)

The subagent model pool is experimental. Gated by:

```bash
export KIMI_CODE_EXPERIMENTAL_SECONDARY_MODEL=1
# or
export KIMI_CODE_EXPERIMENTAL_FLAG=1
```

Without the flag, the `[secondary_model]` keys are inert and subagents inherit the caller's model.

### `[secondary_model]` fields

| Field | Default | Notes |
|-------|---------|-------|
| `default_model` | — | Subagent default; required when `[secondary_model.models]` is set. |
| `models` | — | Pool of aliases; each value is the description the main agent sees. |
| `force` | `false` | Pin every subagent to `default_model`; cannot combine with `models`. |

### Pool aliases

Each key in `[secondary_model.models]` must resolve to a `[models]` entry. The descriptions appear in the Agent / AgentSwarm tool description, so the main agent picks with intent. The pool only references configured `[models]` entries — the `kimi-code/*` aliases below are provisioned by `/login`.

### Variant pattern (per docs)

Different pool entries can carry different thinking levels — register a `[models]` entry as a "variant" of the same underlying model, override only its `default_effort` via `[models."<alias>".overrides]`, and list both aliases in the pool. The `kimi-for-coding-highspeed-deep` entry in the snippet is an example of this pattern.

### Resolution

A spawn resolves the subagent's model in this order:
1. An explicit tool-call `model` argument.
2. `default_model`.

The `model` parameter accepts any pool alias, or `"primary"` (the caller's model). `primary` is always valid. Binding a pool alias carries no explicit thinking effort — the subagent resolves it naturally.

## Snippet (committed at `.kimi-code/local.toml`)

See the committed file. Highlights:

- `default_model = "kimi-code/kimi-for-coding-highspeed"` — AgentSwarm sweep default.
- Pool entries: `kimi-for-coding-highspeed`, `kimi-for-coding`, `k3`, `kimi-for-coding-highspeed-deep`.
- `[thinking]` left without a global `effort` so variant overrides work.
- `[background].max_running_tasks = 6` to absorb the determinism push's parallel sweep load.
- `[subagent]` timeout default (2h) kept.

## Linked tickets

- T17 ([#78](https://github.com/weselben/RooForge/issues/78)) — this work.
- T16 ([#77](https://github.com/weselben/RooForge/issues/77)) — custom agents. The `subagents` allowlist per agent restricts which pool entries it can pick.
- T2 ([#33](https://github.com/weselben/RooForge/issues/33)) — surface the model-routing decisions as part of the per-step mechanism matrix.
- T15 ([#82](https://github.com/weselben/RooForge/issues/82)) — regression harness uses the same pool to re-run prompts against a fixed model.

## Verification

After setting the experimental flag and starting a session:

1. Run `/secondary-model` (alias `/subagent-model`) — the picker should list the four pool entries.
2. Inspect the Agent / AgentSwarm tool description — it should list the pool with the default marked `[default]`.
3. Spawn one `explore` subagent on a representative task and confirm it binds `kimi-for-coding-highspeed` (or whatever the spawn `model` argument names).

If the pool does not appear, the flag is unset; check the session startup logs.

## Configuration errors

Fail loud, not silently (per docs):
- `default_model` missing → session create / resume / fork fail at startup.
- `default_model` not a pool key → startup fails.
- Pool key not resolving to a `[models]` entry → startup fails.
- `force = true` without `default_model` → startup fails.
- `force = true` with `[secondary_model.models]` → startup fails.
- Spawn with `model` neither a pool alias nor `"primary"` → error listing available choices.
- `primary` as a pool key → rejected.
