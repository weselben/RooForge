# planning-and-task-breakdown

This skill decomposes work into small, ordered, verifiable tasks with explicit acceptance criteria. It turns a spec or large feature request into a structured plan of implementable units, each small enough for an agent to complete, test, and verify in a single focused session. The output is a plan document written to the harness plan file, not code.

## When to load

- A spec or clear requirements exist but the work hasn't been broken into tasks yet.
- A task feels too large or vague to start — you can't see the first step.
- Work needs to be parallelized across multiple agents or sessions.
- You need to communicate scope to a human before implementation begins.
- The implementation order depends on non-obvious dependencies.
- Forge's step 3 (Plan) fires when the wayfinder map is clear — it explicitly invokes this skill.

**Do not load** when: the change is a single-file fix with obvious scope, or the spec already contains well-defined tasks.

## How it works

1. **Enter plan mode.** Operate in read-only mode: read the spec, relevant codebase sections, existing patterns. Do not write code during planning. Write the plan to the harness plan file, then request user approval via `ExitPlanMode`. Do not exit plan mode yourself (lines 35–42 of `SKILL.md`).

2. **Identify the dependency graph.** Map what depends on what (e.g., schema → API models → endpoints → frontend). Implementation order follows the graph bottom-up (lines 44–58).

3. **Slice vertically.** Build one complete feature path at a time (schema + API + UI for a single user action), not all of one layer then the next. Each slice delivers working, testable functionality (lines 60–80).

4. **Write tasks.** Each task gets: a short title, a description paragraph, acceptance criteria checkboxes, verification steps, dependency list, files likely touched, and an estimated scope (XS/S/M/L/XL). The full template is at lines 82–117 of `SKILL.md`.

5. **Order and checkpoint.** Arrange tasks so dependencies are satisfied and the system stays in a working state. Add explicit checkpoints after every 2–3 tasks and after each major phase (lines 119–134). High-risk tasks go early.

6. **Present for approval.** After writing the plan file, request approval from the user. Implementation only begins once the user approves (line 136).

## Files in this skill

- `skills/planning-and-task-breakdown/SKILL.md` — The complete skill definition: overview, planning process, task structure template, sizing guidelines, plan document template, parallelization guidance, red flags, and verification checklist (231 lines).

No companion scripts, templates, or additional files exist in this skill directory.

## See also

- `Skill(skill='forge')` — The orchestrator that invokes this skill at step 3 (Plan) when the wayfinder map is clear. Forge's step 3 reads: "Invoke `Skill(skill='planning-and-task-breakdown')`. Enter plan mode, write the plan file, request user approval." (`forge/SKILL.md`, lines 72–76).
- `Skill(skill='dispatching-parallel-agents')` — This skill references parallelization via `Skill(skill='dispatching-parallel-agents')` for concurrent subagent work, one subagent per worktree (`SKILL.md`, lines 157–159).
- `Skill(skill='planning-and-task-breakdown')` references verifying against `Skill(skill='verification-before-completion')` implicitly through its checkpoint verification checklist (`SKILL.md`, lines 225–231).

## Notes

- The skill directory contains only `SKILL.md`; there are no separate template files or scripts — all templates are inline in the Markdown.
- The parallelization section previously contained a self-contradiction (background subagents vs single AgentSwarm call). Fixed in `89ea88b` — the `Skill(skill='dispatching-parallel-agents')` / `AgentSwarm` form is now the only execution mode stated.
