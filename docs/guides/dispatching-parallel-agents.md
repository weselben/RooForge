# dispatching-parallel-agents

Dispatches up to 10 parallel subagents via `AgentSwarm` for 2+ independent tasks with no shared state. Each subagent starts with zero context; the skill enforces prompt construction that bundles broader context (why the task exists, plan placement) and task context (exact paths, commands, expected output) so agents act without clarification.

## When to load

- "swarm mode", "parallel agents", "dispatch in parallel"
- 2+ independent tasks with no shared state, no sequential dependency
- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Same kind of task over many inputs (per-file reviews, per-module audits)
- Any task `forge` hands off to a phase (map fog areas, deep-research passes, SDD per-task swarm, multi-branch conflict resolution)

Stay sequential when failures might be related, when agents would edit the same files, or when the problem is not yet understood.

## How it works

1. **Identify independent domains** — Group by what changes together; fixing one domain must not affect another.
2. **Partition into items** — One item per domain. Each becomes one subagent via the `{{item}}` placeholder.
3. **Write the prompt template** — One `prompt_template` containing `{{item}}`; every filled-in prompt must be distinct. Include a **MANDATORY FIRST** block naming required skills (e.g. `using-git-worktrees`, `conventional-commits`, `caveman-commit`, `verification-before-completion`; reviewers add `caveman-review`).
4. **Dispatch once** — Single `AgentSwarm` call runs all items in parallel (up to 10 agents). Must be the only tool call in the response.
5. **Review and integrate** — Read each summary, check for overlap, run full test suite, spot-check one claim per agent. Load `verification-before-completion` before reporting done.

**Forge integration** (from `skills/forge/SKILL.md`): When Forge invokes DPA in map charting (fog areas), deep-research, SDD, or conflict resolution, the `prompt_template` passed to `AgentSwarm` MUST include a **Role Mandate** block defining the subagent's role, phase, and output destination — e.g.:

```
MANDATORY ROLE MANDATE — your role in forge's orchestration:
- You are a [role: e.g. "map fog resolver", "PR reviewer", "conflict resolver"]
- You run in [phase: e.g. "map charting", "PR review", "conflict resolution"]
- Your output feeds [next step: e.g. "map Decisions-so-far", "PR review body", "resolved PR"]
- Do not step outside this role. No autonomous decisions beyond your mandate.
```

## Files in this skill

- `skills/dispatching-parallel-agents/SKILL.md` — Main skill definition: when to swarm, the 5-step pattern, `AgentSwarm` mechanics, prompt rules (STE100, MANDATORY FIRST, broader + task context), common mistakes, and post-swarm verification.

## See also

- `forge` — Orchestrator that invokes DPA in multiple phases (map fog areas, deep-research, SDD, conflict resolution); mandates Role Mandate block in every DPA prompt template.
- `subagent-driven-development` — Uses DPA for per-task subagent swarms within worktrees; DPA handles the parallel dispatch, SDD owns worktree lifecycle and integration.
- `deep-research` — Uses DPA for parallel research passes (not `loops`); DPA is the single home for parallel subagent swarms.
- `resolving-merge-conflicts` — Delegates multi-branch conflicts to SDD, which uses DPA to unblock in parallel.
- `verification-before-completion` — Loaded after every DPA swarm to verify agent claims against actual diffs and test runs.
- `caveman-commit` / `conventional-commits` — Required in MANDATORY FIRST for implementer agents.
- `caveman-review` — Required in MANDATORY FIRST for reviewer agents.
- `using-git-worktrees` — Required in MANDATORY FIRST for worktree-based parallel work.

## Notes

- Only `SKILL.md` exists in this skill directory; no companion scripts or templates.
- The `forge/SKILL.md` reference to DPA in map charting says "STE100 prose, no ambiguity" — this aligns with the prompt rules in DPA's own SKILL.md.
- `loops` is explicitly *not* used for DPA work (deep-research refinement passes use DPA, not loops).