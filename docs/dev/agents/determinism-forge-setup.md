# Determinism sampling — forge-setup

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/forge-setup.log` (gitignored).

## Sample

- **Task:** trace steps 1–5 as dry run for target harness Claude Code; show the grep inventory, expected mapping table rows, and the mechanical/judgment split. No clones, no network. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:29:04Z, exit 0, 47 log lines (incl. model reasoning).
- **Outcome:** model produced the grep command verbatim, sketched the four mapping rows (`kimi -p` → `claude -p`, `CreateGoal` → `GOAL.md` fallback, `EnterPlanMode`/`ExitPlanMode` → same-name identity, `AgentSwarm` → sequential `Task`), and correctly classified step 3 as the judgment core.

## Observed meta-decisions

- Read `skills/forge-setup/SKILL.md` first.
- Recalled the exact grep inventory command from the skill rather than re-deriving it — evidence the skill's enumeration is canonical.
- Recognized the **identity match** for plan mode (Claude Code has the same `EnterPlanMode`/`ExitPlanMode` names) and treated it as "verify and skip" — a judgment call the skill's "research equivalents" step anticipates.
- Surfaced the `AgentSwarm` → sequential `Task` fallback while preserving the `{{item}}` template mechanics and role mandates — the skill's "contracts stay" rule applied verbatim.
- Did **not** clone or mutate (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Clone repo to temp dir | none | full — fixed command | **shell script** — verbatim. | input: repo URL; output: `$WORKDIR`. |
| 2 | Identify the harness (own tool surface, env probe, ask user) | low — mostly probe | mostly — the probe is a fixed list | **shell script** — run `which` + env checks; if still unknown, ask the user. | input: none; output: `{harness, cli}`. |
| 3 | Grep inventory of non-agnostic surfaces | none | full — fixed grep | **shell script** — verbatim from the skill. | input: `$WORKDIR`; output: hit list. |
| 4 | Research harness equivalents (per surface) | high — the harness docs are unbounded | the *surface list* is fixed | **keep-as-model** — research is judgment; a `forge_mcp.harness_docs(harness, surface)` lookup could pre-fetch docs. | input: harness + surface; output: mapping candidate. |
| 5 | Decide fallback when no equivalent exists (`GOAL.md`, file-based plan, sequential swarm) | medium — three enumerated fallbacks | full — fixed fallbacks per surface | **premade prompt template** — the three fallbacks are templated; model picks which applies. | input: surface; output: fallback choice. |
| 6 | Patch with sed swaps (narrow, minimal diffs) | low — pick which sed to run | full — fixed sed patterns | **shell script** — run each swap conditionally on grep hits. | input: mapping table; output: patched files. |
| 7 | `bash -n` syntax check on patched scripts | none | full — fixed command | **shell script** — verbatim. | input: `.sh` files; output: `{valid: bool}`. |
| 8 | Step-5 verify (re-grep, syntax check, smoke test) | none | full — fixed commands | **shell script** — all three steps scriptable. | input: patched repo; output: `{pass: bool, report}`. |
| 9 | Step 6 identity prompt for `use-git-identity` | low — fixed prompt text | full | **shell script** — prompt + write to the skill file. | input: user answers; output: updated `use-git-identity/SKILL.md`. |
| 10 | Step 7 install (delete old, copy new, exclude forge-setup) | none | full — fixed loop | **shell script** — verbatim. | input: `$WORKDIR` + harness dir; output: installed skill list. |
| 11 | Decide when *not* to patch a surface (identity match) | medium — verify before skip | the *decision to skip* is judgment | **keep-as-model** — needs to verify the harness's plan-mode semantics match before skipping. | input: harness + surface; output: {skip: bool, reason}. |

## Notes

- Forge-setup is the most **shell-script-shaped** skill in the set: steps 0–2, 5–7, and most of 4 are verbatim shell. The only consistent judgment is step 3 (researching the harness's actual surface) and the small decision of when a sed swap is unnecessary (identity match).
- The skill's own design ("no per-harness mapping table — harnesses change faster than any table stays true") is a *deliberate* rejection of a static mapping. That choice is validated by the sample: the model correctly identified that Claude Code has same-name plan mode, which a static table would have missed.
- The strongest determinism win is a **`forge_mcp.harness_adapt(repo, harness)` MCP tool** that runs steps 0–2, 5–7 end-to-end and returns a structured diff + mapping table; the model only authors step 3's research and step 11's skip decisions.
- The skill is already idempotent-by-design (temp dir, grep-driven, re-runnable) — the determinism win is replacing the *orchestration*, not the *content*.