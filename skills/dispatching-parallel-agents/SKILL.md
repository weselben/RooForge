---
name: dispatching-parallel-agents
source: https://raw.githubusercontent.com/obra/superpowers/main/skills/dispatching-parallel-agents/SKILL.md
description: "Dispatch up to 10 parallel subagents via AgentSwarm for 2+ independent tasks. Triggers: \"swarm mode\", \"parallel agents\", \"dispatch in parallel\", or 2+ independent tasks with no shared state."
---

# Dispatching Parallel Agents — Swarm Mode

Subagents start blank — zero context. Construct exactly the context each one needs; subagents don't discover the library on their own.

**Leading word: MANDATORY FIRST.** Every subagent prompt must name the skills to load. A short "MANDATORY FIRST: load these skills" block at the top of the prompt is how the skill library reaches the work.

## When to swarm

- 2+ independent tasks with no shared state, no sequential dependency
- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Same kind of task over many inputs (per-file reviews, per-module audits)
- Any task `forge` hands off to a phase

**Stay sequential** when failures might be related (one fix may fix others), when agents would edit the same files, or when you don't yet know what's broken.

## The pattern

1. **Identify independent domains.** Group by what is broken or what changes together. Fixing one domain must not affect another.
2. **Partition into items.** One item per domain. Each becomes one subagent via the `{{item}}` placeholder.
3. **Write the prompt template.** One `prompt_template` containing `{{item}}`; every filled-in prompt must be distinct.
4. **Dispatch once.** A single `AgentSwarm` call runs all items in parallel — up to 10 agents. Must be the only tool call in your response.
5. **Review and integrate.** Read each summary, check no overlap, run full test suite, spot-check for systematic errors.

**Done when:** every subagent returned a summary, no overlap, full suite green.

## AgentSwarm mechanics

- `prompt_template` + `items`: `{{item}}` replaced with each value. ≥ 2 items required.
- `subagent_type`: `explore` (read-only), `coder` (edits), `plan` (read-only planning), `agent` (general default).
- `resume_agent_ids`: continue existing agents instead of spawning new — prefer resume over fresh.
- Up to 10 parallel; queueing is automatic.
- For a single subagent, use `Agent` directly; `run_in_background=true` detaches it.
- Subagent results are visible only to you — summarize what matters to the user.
- Leave running subagents alone; don't redo their searches, don't finish manually.

## Prompt rules

Good prompts are focused, self-contained, specific about the return value.

**No ambiguity.** A subagent starts with zero context. Write prompts in **STE100** (one meaning per word, short sentences, active voice) so the subagent cannot misinterpret. State everything the subagent needs — **broader context** (why this task exists, where it fits in the plan, what came before, what comes after) AND **task context** (exact path, exact command, exact expected output). No inferring, no assuming. A prompt a new colleague with zero context can act on without asking a single question.

- **Brief like a new colleague.** Goal, what you know, specifics: exact paths, commands, line numbers.
- **Include broader context first.** Why this task exists. Which plan it belongs to. What's already done. What's downstream of it. The subagent has not seen your session.
- **Include task context second.** Exact files, exact commands, exact output format.
- **Lookups get exact targets.** "Read `src/auth.ts` and run `npm test`" — never make the agent search for what you already know.
- **Investigations get questions, not scripts.** Prescribed steps become dead weight when the premise is wrong.
- **Delegate work, not understanding.** If the task hinges on a file/line, find it yourself first.
- **Name the deliverable.** "Return: root cause + what you changed" beats "fix it".
- **MANDATORY FIRST block.** Name the skills to load — implementer: `using-git-worktrees` + `conventional-commits` + `caveman-commit` + `verification-before-completion`; reviewer: add `caveman-review`.

### Example

```text
prompt_template: "Fix the failing tests in {{item}}. Read the test file, find
the root cause (timing or real bug), fix it, run the suite for that file.
Constraints: change only that file's tests and the code they cover.
Return: root cause + changes."

items:
  - "src/agents/agent-tool-abort.test.ts"
  - "src/agents/batch-completion-behavior.test.ts"
  - "src/agents/tool-approval-race-conditions.test.ts"
```

## Common mistakes

- **Too broad:** "Fix all the tests" — agent gets lost. One file/subsystem per item.
- **No context:** paste error messages and test names, not "fix the race condition".
- **No constraints:** agent refactors everything. State what may/may not change.
- **Vague output:** "Fix it" — can't integrate what you can't see. Require a summary.
- **Swarming shared state:** two agents editing the same file collide. Partition so each owns its files.

## Verification after the swarm

1. Read every summary — understand what each agent claims it changed.
2. Check for overlap — did two agents edit the same code?
3. Run the full test suite — fixes must work together.
4. Spot-check one claim per agent — subagents make systematic errors.

Before reporting integration done, load `verification-before-completion` — every "agent said success" must be checked against the actual diff and test run.