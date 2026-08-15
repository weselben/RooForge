---
name: forge
description: "Always load first — before responding to any user prompt — unless the user states otherwise in the prompt itself. Examples that trigger forge: 'let's continue on the auth refactor', 'work on the next ticket', 'open the map for the payment effort', 'what's next', 'start a new effort: <idea>'. Mandatory while any goal or map is active."
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/forge/SKILL.md
---

# Forge

Forge owns a sequence the agent runs every session: **map → resolve → plan → work → verify → review → resolve**. Each step ends on a checkable criterion; the next step is the proof.

## Invariant rules

These are binding on every session where forge is active.

- **Mandatory load.** Forge loads at every session start. No chat until `Skill(skill='forge-flow')`, `Skill(skill='caveman')` (ultra), and `Skill(skill='wayfinder')` are loaded. Forge is the orchestrator.

## Skill Reference Convention

Every cross-skill mention in this file uses the `Skill(skill='name')` form in backticks. Verb normalises to "load". The `Skill` tool call name is the canonical prefix — it makes skill invocations explicit and searchable.

- **Mandates are mandatory.** When any skill or message uses *must*, *mandatory*, *MUST*, or *always*, follow it exactly. No hedging. The author wrote those words to prevent a concrete failure.
- **caveman is default.** `Skill(skill='caveman')` (ultra) is active every response. Off only on explicit "stop caveman" / "normal mode". Code, commit messages, PR bodies follow their own skill formats; everything else is caveman.
- **Own repos only.** Forge operates only in repos owned by the user's git identity. No pushes, no issues, no PRs in unfamiliar or public repos. For an upstream repo (`x/y`): `gh repo fork x/y --clone && gh repo edit --visibility private --accept-visibility-change-consequences`. Private `z/y` is the work surface.
- **Single path.** One flow through the steps. No branching in the orchestrator. Each step ends on a checkable criterion; the next step is the proof.
- **Forge Flow first.** `Skill(skill='forge-flow')` runs before step 1: creates the feat branch from `main`, sets the harness goal, hands off. Forge never creates branches or goals.

## Auto-load at session start

`Skill(skill='forge-flow')`, `Skill(skill='caveman')` (ultra), and `Skill(skill='wayfinder')`. No chat until all are loaded.

## Flow

### 1. Map — load or chart

- Map URL or number given → load it.
- No map → load `Skill(skill='wayfinder')` **chart** mode (grilling + domain-modeling → map + tickets).
  - **Parallel map work:** when the map has multiple independent fog patches, load `Skill(skill='dispatching-parallel-agents')` to work them concurrently. Each subagent receives its fog area as `{{item}}` plus **broader context** (destination, notes, decisions-so-far) **AND task context** (exact fog description, what questions to resolve). STE100 prose, no ambiguity.
- Map clear on load → skip to step 3.

**Done when:** the map issue is loaded and open frontier tickets are visible.

### 2. Resolve — work one ticket

Invoke the skill the ticket's `wayfinder:<type>` label names (`Skill(skill='grilling')`, `Skill(skill='prototype')`, `Skill(skill='deep-research')`, `Skill(skill='domain-modeling')`, `task`). Wayfinder records the resolution and closes the ticket.

**After every grilling ticket closes**, load `Skill(skill='domain-modeling')` to sweep for new terms (update `docs/dev/CONTEXT.md`) and decisions worth recording (add ADR to `docs/adr/`). Don't wait for the user — the model crystallises the moment a decision lands.

**Done when:** the ticket is closed, the map's Decisions-so-far points at it, and any new domain terms/ADRs are captured. **One ticket per session** (research subagents in parallel excepted).

### 3. Plan — break the cleared map into ordered tasks

When the frontier is empty:

1. Invoke `Skill(skill='planning-and-task-breakdown')`.
2. Enter plan mode, write the plan file, request user approval.
3. **Do not exit plan mode yourself.**

**Done when:** the user has approved the plan file.

### 4. Work — delegate to `Skill(skill='subagent-driven-development')`

Once the plan is approved, hand off to `Skill(skill='subagent-driven-development')`. SDD owns: worktree creation (`Skill(skill='using-git-worktrees')`), per-task subagent swarm (`Skill(skill='dispatching-parallel-agents')`), per-task review, fix loop, integration, and squash-merging into the feat branch as one natural Conventional Commit per subagent (e.g. `feat(api): add user profile endpoint`, not `ticket-1`).

**If conflicts occur during parallel worktree integration**, load `Skill(skill='resolving-merge-conflicts')`. It resolves hunk-by-hunk; for multi-branch conflicts it delegates back to SDD to unblock in parallel. Rebase conflicting branches onto the integration branch head first, then resolve.

**After squash-merge**, load `Skill(skill='forge-docs')` and follow it. Docs updates travel with the squash commit.

**Done when:** every worktree has produced a squash commit on the feat branch, each commit a complete Conventional Commit, and `Skill(skill='forge-docs')` has been applied.

### 5. PR — draft with `Skill(skill='creating-pull-requests')`

- Open PR draft using `Skill(skill='creating-pull-requests')` (draft mode, AI disclosure).
- Write PR description using `Skill(skill='ste100')`.
- **Update the PR description after each squash commit lands.**

**Done when:** the PR draft covers every task with a real commit and a `Skill(skill='ste100')` description.

### 6. Verify — `Skill(skill='verification-before-completion')`

Load `Skill(skill='verification-before-completion')`. Run the full test suite on the merged feat branch. Check each subagent's claimed state against `git status` and the suite result.

**Done when:** the suite is green and every subagent claim is verified against actual output.

### 7. Review — `Skill(skill='pr-review')`

Run `Skill(skill='pr-review')` in PR mode (`owner/repo#n`). It runs in a worktree, drives a `kimi -p` loop via `Skill(skill='loops')`, posts ONE review under the authenticated user's identity in `Skill(skill='caveman-review')` format.

**Done when:** the review URL exists; 🔴 or 🟡 findings → step 8.

### 8. Resolve findings — `Skill(skill='pr-resolve')`

`Skill(skill='pr-resolve')` loads `Skill(skill='pr-review')` output. One resolver per finding group, each in its own worktree off the PR head, commits under `Skill(skill='use-git-identity')`, pushes, replies in each review thread. Then load `Skill(skill='pr-review')` again. The loop ends when no 🔴 or 🟡 findings remain.

**If merge conflicts occur during push**, load `Skill(skill='resolving-merge-conflicts')` — it runs steps 1–3, and for multi-branch conflicts delegates to `Skill(skill='subagent-driven-development')` to unblock in parallel.

**Done when:** no 🔴/🟡 findings, push clean. The user merges.

## Session Start Behaviour

Autonomous by default: pick the next unclaimed ticket and resolve it. Only interrupt when every open ticket is HITL-blocked — then surface the map's URL with what's needed.

```
forge session start
  │
  ├─── load always-on: `Skill(skill='caveman')` (ultra) · `Skill(skill='wayfinder')`
  │
  ├─► map provided? ──yes──► load ──► work
  │
  ├─► map exists in tracker? ──yes──► load ──► work
  │                                      ├─► all tickets HITL-blocked?
  │                                      │     └── surface map link + needs
  │                                      └─► else work next ticket
  │
  └─► no ──► `Skill(skill='wayfinder')` chart map ──► work
```

If the map is already clear (no open frontier tickets) on load, skip to **Plan**.

## Git Flow

```
main
  └── feat/wayfinder-<map-name>
        ├── worktree/ticket-1 → squash → feat(api): add user profile endpoint
        ├── worktree/ticket-2 → squash → fix(auth): accept trailing whitespace
        └── worktree/ticket-3 → squash → refactor(db): extract connection pooling
        → PR draft → verify → `Skill(skill='pr-review')` ↔ `Skill(skill='pr-resolve')` → user merges
```

## Docs Structure

On session load, know where everything lives:

| Path | What lives there |
|------|-----------------|
| `docs/adr/` | Architecture Decision Records — hard-to-reverse, surprising, trade-off decisions |
| `docs/dev/CONTEXT.md` | Domain glossary — one `CONTEXT.md` per context |
| `docs/dev/CONTEXT-MAP.md` | Multi-context map (only if multiple contexts exist) |
| `docs/dev/agents/` | Deep research reports — `<topic>.md` |
| `docs/guides/` | How-to guides |
| `docs/system-design/` | System design documents |
| `docs/public/` | Public-facing docs |
| `.worktrees/<task-slug>/` | Isolated worktrees for parallel subagents |

## Role Mandate for DPA/loops

When forge invokes `Skill(skill='dispatching-parallel-agents')` or `Skill(skill='loops')`, the **role in forge's orchestration** MUST be part of the subagent prompt. The prompt template passed to `AgentSwarm` or `run_loop.sh` MUST include a **Role Mandate** block:

```
MANDATORY ROLE MANDATE — your role in forge's orchestration:
- You are a [role: e.g. "map fog resolver", "PR reviewer", "conflict resolver"]
- You run in [phase: e.g. "map charting", "PR review", "conflict resolution"]
- Your output feeds [next step: e.g. "map Decisions-so-far", "PR review body", "resolved PR"]
- Do not step outside this role. No autonomous decisions beyond your mandate.
```

This ensures subagents know their place in the single path. It also makes it **possible** (not implied) for future parallel map work: when one fog area unblocks, another can start because the role mandate defines the boundary.

- `Skill(skill='loops')` is the **single home** for all `kimi -p` iteration. Used by: `Skill(skill='pr-review')`, `Skill(skill='pr-resolve')`. No other skill loads `kimi -p` loops — deep-research refinement passes load `Skill(skill='dispatching-parallel-agents')`, not `Skill(skill='loops')`.
- `Skill(skill='dispatching-parallel-agents')` is the **single home** for all parallel subagent swarms. Used by: map charting (fog areas), deep-research (parallel research), SDD (per-task swarm), `Skill(skill='resolving-merge-conflicts')` (multi-branch conflicts).

## Sidecar skills

Domain skills that ride alongside the flow — load them when the task touches their domain:

- `Skill(skill='12-factor-app')` — SaaS / cloud-native / microservice design or review
- `Skill(skill='kiss-principle')` — design or code smells over-engineered
- `Skill(skill='frontend-design')` — building or reshaping UI with a distinctive visual direction
- `Skill(skill='forge-tailwindcss-conventions')` — Tailwind CSS work
- `Skill(skill='forge-eu-accessibility')` — EU accessibility (BFSG/EAA/WCAG) work
- `Skill(skill='forge-seo')` — SEO work (meta, sitemaps, structured data, Core Web Vitals)