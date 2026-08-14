# forge-setup

One-shot adaptation skill that rewrites this repo's skills for the harness actually running them. The skills are authored against Kimi Code CLI; on a different harness (Claude Code, Codex, Gemini CLI, opencode, …) the `kimi -p` non-interactive loops, `CreateGoal` tool, plan mode, and `AgentSwarm` / `Agent` subagent API are either unreachable or live under different names. Forge-setup is the discovery + adaptation procedure that makes the running agent find every non-agnostic reference itself, research its own harness's equivalent, and patch with minimal diffs.

## When to load

- First session after cloning this repo, when the harness is not Kimi Code CLI.
- After upgrading the harness and a skill's referenced tool/flag no longer exists.
- When `loops`, `pr-review`, `pr-resolve`, `forge-flow`, `dispatching-parallel-agents`, or `subagent-driven-development` reference tooling the current session does not have.

## How it works

1. **Identify the harness** (SKILL.md:31–42)
   - Check own tool surface (`AgentSwarm`, `CreateGoal`, `EnterPlanMode`, skill/task tools, etc.)
   - Check environment: CLI binary on `PATH`, harness config dirs, env vars
   - If none of the above identifies it → ask the user: *"Which harness/CLI is running this session?"*

2. **Discover non-agnostic surfaces** (SKILL.md:46–67)
   - Run the inventory grep from the repo root:
     ```
     grep -rn -E 'kimi -p|kimi\b|CreateGoal|EnterPlanMode|ExitPlanMode|plan mode|AgentSwarm|subagent_type|Agent\(resume|run_in_background' skills/ --include='*.md' --include='*.sh'
     ```
   - Match hits against the known-surfaces table (SKILL.md:54–62): non-interactive loop, goal persistence, plan mode, parallel subagent dispatch, skill loading.

3. **Research the harness's equivalents** (SKILL.md:69–86)
   - Own docs first — harness docs dir, `--help` output, built-in skill/command listings, config schema
   - Web second — official docs for the harness's headless mode, subagent API, goal/plan features
   - Record each mapping before patching. If no equivalent exists (e.g. no goal API), fall back to a file-based convention and document the fallback in the patch.

4. **Patch with minimal diffs** (SKILL.md:88–116)
   - Premade example sed commands are in the skill (SKILL.md:96–108) — adapt the replacement side, never the surrounding logic
   - One reference swapped for its equivalent: no reformatting, no rewording, no opportunistic cleanup
   - Contracts stay (`DONE:`/`BLOCKED:`, role-mandate blocks, MANDATORY FIRST loads, plan-approval gate)
   - Scripts must still parse: `bash -n` after every `.sh` patch
   - Commit as one `chore(forge-setup): adapt skills to <harness>` per repo convention

5. **Verify** (SKILL.md:118–127)
   - Re-run the step-2 grep; expect zero hits for the old harness's terms outside `forge-setup` itself (the file is exempted — it documents the Kimi forms on purpose)
   - `find skills/ -name '*.sh' -exec bash -n {} \;`
   - Smoke-test the loop engine if the harness CLI exists
   - Report the mapping table to the user

## Files in this skill

- `skills/forge-setup/SKILL.md` — Main skill definition with the five-step discovery-and-adaptation procedure, the harness-surfaces table, the premade example replace commands, and the verify checklist

## See also

- `forge-init` — Runs once per repo to create the local AGENTS.md contract; forge-setup runs before it on a non-Kimi harness
- `forge-flow` — Session bootstrap (branch + goal); after forge-setup has patched the harness references, forge-flow's `CreateGoal` call becomes a valid invocation
- `loops` — The `kimi -p` loop engine — the most patched target in this repo
- `pr-review` / `pr-resolve` — Consumers of `loops`; their templates and scripts reference `kimi -p` too
- `dispatching-parallel-agents` / `subagent-driven-development` — Reference the `AgentSwarm` and `Agent` subagent APIs that vary per harness
- `forge` — The orchestrator that drives the whole flow; mentions plan mode and `AgentSwarm` mechanically

## Notes

- The skill does not ship a per-harness mapping table. Harnesses change faster than any table stays true; the agent running on the target harness is the best researcher for that harness.
- Step 1's "ask the user" is a hard rule. Never guess and patch blind — the user knows their CLI better than any snapshot.
- Step 5's grep excludes `forge-setup` itself — that file names the Kimi forms as the reference baseline, so the matches there are documentation, not anything to fix.
- After forge-setup runs, invoke `forge-init` by name (user-invoked, once per repo). Then start a session — `forge` auto-triggers and invokes `forge-flow` itself.
