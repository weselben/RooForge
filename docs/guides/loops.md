# loops

A shell framework that drives `kimi -p` review/resolve loops. The calling skill supplies a prompt template; loops renders it, compresses it via `cavemanize.sh`, then iterates `kimi -p` until the subagent emits `DONE:` (success with artifact path) or `BLOCKED:` (failure with reason). Used exclusively by `pr-review` and `pr-resolve` — no other skill uses `kimi -p` loops.

## When to load

- "kimi -p loop" / "review loop" / "resolve loop" — trigger phrases from the skill frontmatter
- Running PR review cycles (`pr-review` skill) — it invokes `loops` to drive the `kimi -p` review iterations
- Running PR resolve cycles (`pr-resolve` skill) — it invokes `loops` to drive the `kimi -p` fix iterations
- Any skill needing a bounded `kimi -p` loop with `DONE:`/`BLOCKED:` contract (currently only the two above)

## How it works

1. **Caller provides prompt template** — the calling skill owns a `.md` template under its own `templates/` (e.g. `pr-review/templates/review-loop.md`). The template must include: mandatory first skill loads, no-plan-mode instruction, and the `DONE:`/`BLOCKED:` contract line, plus broader context (why this task exists, where it fits) and task context (exact paths, commands, output format) per the caller contract (`skills/loops/SKILL.md:35-42`).

2. **Render & compress** — `run_loop.sh` changes to `[workdir]`, then pipes the template through `cavemanize.sh` (removes filler words, collapses whitespace, preserves code blocks) to produce `.loops/<name>/prompt.rendered.md` (`scripts/run_loop.sh:18-23`). `validate.sh` then compares the template against the rendered prompt; errors block the loop with `BLOCKED:` and exit 2, warnings log to `.loops/<name>/validate.out` and the loop proceeds (`scripts/run_loop.sh:25-32`).

3. **Iterate `kimi -p`** — for `i` in `1..max_iter` (default 10):
   - Run `kimi -p "$(cat prompt.rendered.md)"`, capture output (`run_loop.sh:25-29`).
   - Append the reply to the running prompt for next iteration (`run_loop.sh:31`).
   - Check for `DONE:` — on match, write artifact path to `.loops/<name>/done.out`, exit 0 (`run_loop.sh:33-37`).
   - Check for `BLOCKED:` — on match, write reason to `.loops/<name>/blocked.out`, exit 2 (`run_loop.sh:39-43`).
   - Otherwise, re-cavemanize the running prompt and continue (`run_loop.sh:45-47`).

4. **Cap** — if `max_iter` reached without `DONE:`, write `BLOCKED: max_iter reached` and exit 1 (`run_loop.sh:49-51`).

## Files in this skill

- `skills/loops/SKILL.md` — main skill definition: usage, steps, caller contract, boundaries, and example wiring from `pr-review`
- `skills/loops/scripts/run_loop.sh` — the loop driver: renders prompt, runs `kimi -p` iterations, checks `DONE:`/`BLOCKED:`, manages `.loops/` logs
- `skills/loops/scripts/cavemanize.sh` — pre-compression filter: strips filler words, collapses whitespace, preserves fenced code blocks; reads stdin, writes stdout
- `skills/loops/scripts/validate.sh` — pre-kimi gate: compares the template against the rendered prompt and fails (exit 2, `BLOCKED:`) on lost headings, fences, URLs, or inline codes; logs warnings to `.loops/<name>/validate.out`

## See also

- `pr-review` — consumes `loops` to drive the `kimi -p` review loop; its `review-loop.sh` renders `templates/review-loop.md` → `cavemanize.sh` → `run_loop.sh` (`skills/loops/SKILL.md:44-48`)
- `pr-resolve` — consumes `loops` to drive the `kimi -p` resolve/fix loop; same invocation pattern
- `forge` — orchestrator that mandates `loops` as the single home for all `kimi -p` iteration (not `dispatching-parallel-agents`); deep-research refinement uses DPA, not loops (`skills/forge/SKILL.md:123-128`)
- `caveman` — the compression style `cavemanize.sh` approximates; the agent loads `caveman(ultra)` at session start per forge invariants (`skills/forge/SKILL.md:16`)

## Notes

- `run_loop.sh` previously aborted under `set -u` on an unset `$LOOPS_LOG` (line 17). Fixed in `09f33e1` — the dead LOGFILE assignment was deleted and SCRIPT_DIR is computed before the workdir `cd`.
- `cavemanize.sh` is now a pure `sed` filler-drop pass (the earlier awk command was malformed). The full `caveman` skill (loaded by the agent) drives the actual compression style at response time — the shell pass is a fast pre-compression before `kimi -p` sees it.
- The caller contract requires STE100 prose (one meaning per word, short sentences, active voice) and mandates that the subagent never needs to ask a clarifying question (`skills/loops/SKILL.md:41-42`).