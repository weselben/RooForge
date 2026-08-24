# Determinism sampling — loops

Sampling pass per ADR 0004. Raw stdout at `.tmp-determinism/logs/loops.log` (gitignored).

## Sample

- **Task:** trace what `run_loop.sh` does given a template body that yields `DONE: ok` on iteration 1.
- **Run:** `kimi -p` on 2026-08-18T01:29:38Z, exit 0, 39 lines.
- **Outcome:** model produced a 5-phase trace and an exact I/O contract (argv, stdout, exit codes). It correctly identified the script itself as **pure plumbing** with zero judgment; all judgment lives outside (template author, kimi's `DONE:` signal).

## Observed meta-decisions

- Argued that "all judgment lives outside" — i.e. the script never interprets content. Correct.
- Produced an exit-code map (0/1/2) that matches the SKILL.md spec.
- Noted that the caller owns the prompt template (per `loops`' "leading word: render" discipline).
- No file mutations.

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Parse argv (`prompt.md`, `max_iter=10`, `workdir=.`) | none | full | **shell script** — already deterministic; ADR 0007 mandates migration to Node, this row falls in that work. | argv contract: `$1` required, `$2` int default 10, `$3` dir default `.`. |
| 2 | `cd` to workdir | none | full | shell/Node — deterministic. | side-effect: subsequent `kimi -p` chats land under workdir in history. |
| 3 | Render template through `cavemanize.sh` | none — text in / text out, code preserved | full | **shell** or Node pipe; cavemanize rule is fixed. | stdin: prompt body; stdout: rendered prompt; gate: code/identifiers/errors preserved verbatim. |
| 4 | `kimi -p "<rendered>"` | none — shell exec | full | already a deterministic shell call. | one-shot CLI; result is the agent's reply. |
| 5 | Parse status — grep `DONE:` / `BLOCKED:` in output | none — fixed regex | full | already deterministic. | regex contract: literal `DONE:` or `BLOCKED:` at line start (skill may refine). |
| 6 | On `DONE:` — write artifact path, exit 0 | none — fixed exit | full | already deterministic. | exit 0; last stdout line = artifact path. |
| 7 | On `BLOCKED:` — write blocker reason, exit 2 | none — fixed exit | full | already deterministic. | exit 2; last stdout line = blocker reason. |
| 8 | On neither — append reply to prompt, re-render, next iteration | none — fixed loop logic | full | already deterministic. | append-only; preserves history. |
| 9 | Cap reached (max_iter) | none | full | already deterministic. | exit 1; reason "max_iter reached without DONE". |
| 10 | Template authoring (the caller's job) | high — what to put in the template | none — judgment | **keep-as-model** at the template-author level (per skill); the rendering itself is shell. | ADR 0005 #2 — Node wrapper + premade prompt template. |

## Notes

- `loops` is **the cleanest determinism candidate in the repo**: zero judgment inside the script.
- ADR 0007 already commits to migrating the shell to Node. This sampling pass confirms the migration is mechanical-only (no logic changes needed).
- The only judgment-bearing component is the **caller-supplied template** — which lives outside `loops` and is owned per-skill (`pr-review/templates/review-loop.md`, `pr-resolve/templates/resolve-loop.md`).
- Surprise: even the `cd`-to-workdir step is a side effect with an observable contract (chats land under that workdir in history). That contract should be tested if the migration to Node happens.