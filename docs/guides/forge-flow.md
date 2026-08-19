# forge-flow

`Skill(skill='forge-flow')` is the session-start frontier sub-skill invoked by `Skill(skill='forge')`. It prepares the work surface (a `feat/<slug>` branch cut from `main`) and the contract (a long-living harness goal covering the entire wayfinder map), then hands off to forge step 1. It runs **once per session** and exits.

## When to load

- The user starts a new session on an ongoing effort — fresh chat, "let's continue", "pick up where we left off", or the first turn of any working session.
- `Skill(skill='forge')` invokes `Skill(skill='forge-flow')` automatically at session start. You should not invoke it manually.

## How it works

1. **Detect the wayfinder map** — three cases (forge-flow SKILL.md:16–27):
   - Map URL/number provided → load it
   - Map exists in tracker → query for open `wayfinder:map` issue
   - No map → hand off to forge step 1 (invokes `Skill(skill='wayfinder')` chart mode); goal written with placeholder map reference

2. **Name the feat branch** (forge-flow SKILL.md:29–37):
   - Pattern: `feat/<slug>`
   - Slug derived from map name (e.g., `"Idempotency keys for payment endpoint"` → `feat/idempotency-keys`)
   - If no map, derive from user's first turn (e.g., `"fix cache race"` → `feat/cache-race-fix`)
   - Reuse existing `feat/*` branch if already associated with the map

3. **Create or switch to the feat branch from main** (forge-flow SKILL.md:39–44):
   ```bash
   git checkout main
   git pull
   git checkout -b feat/<slug>   # or: git checkout <existing-feat-slug>
   ```
   - Always cut from `main` — never from another feat, hotfix, or chore branch
   - Verify: `git branch --show-current` returns feat branch; `git merge-base --is-ancestor main HEAD` is true

4. **Write the contract goal** (forge-flow SKILL.md:46–70):
   - Created via `CreateGoal` (or `GOAL.md` file fallback after `Skill(skill='forge-setup')`) with STE100-formulated objective covering the **full map** (all tickets, all decisions)
   - Mandatory fields in objective:
     1. `load forge skill (mandatory while goal is active)`
     2. Map URL/number (or explicit placeholder if no map yet)
     3. STE100 prose — short sentences, one meaning per word
   - Goal is immutable after creation; expansions go into `description` or `metadata`, never the `objective`
   - If harness supports extra fields, put full STE100 expansion there

5. **Hand off to forge step 1** (forge-flow SKILL.md:72–74):
   - Tell agent: "Continue with forge step 1 — load or chart the wayfinder map."
   - Forge then runs map → resolve → plan → work → verify → review → resolve (8 steps)

## Files in this skill

- `skills/forge-flow/SKILL.md` — The complete skill definition: purpose, steps 1–5 with completion criteria, rules, and boundaries

## See also

- `Skill(skill='forge')` — The orchestrator that runs after forge-flow; owns the full session flow (map → resolve → plan → work → verify → review → resolve)
- `Skill(skill='wayfinder')` — Chart/load the wayfinder map; invoked by forge step 1 when no map exists
- `Skill(skill='caveman')` — Default communication mode (ultra); auto-loaded with forge at session start
- `Skill(skill='planning-and-task-breakdown')` — Invoked by forge step 3 to break the cleared map into ordered tasks
- `Skill(skill='subagent-driven-development')` — Owns worktree creation, per-task subagent swarm, integration, and squash-merging (forge step 4)
- `Skill(skill='creating-pull-requests')` — Opens PR draft with AI disclosure and STE100 description (forge step 5)
- `Skill(skill='verification-before-completion')` — Runs full test suite on merged feat branch (forge step 6)
- `Skill(skill='pr-review')` / `Skill(skill='pr-resolve')` — Review/resolve loop until user merges (forge steps 7–8)
- `Skill(skill='dispatching-parallel-agents')` — Single home for parallel subagent swarms (map charting, deep-research, SDD, conflict resolution)
- `Skill(skill='loops')` — Single home for `kimi -p` iteration (used by pr-review, pr-resolve)

## Notes

- No scripts, templates, or companion files exist in `skills/forge-flow/` — only `SKILL.md`.
- The skill references `CreateGoal` as the mechanism for goal creation; confirm this tool exists in your harness.
- The "map URL or number" convention assumes a tracker integration (e.g., GitHub issues with `wayfinder:map` label); adapt if your tracker differs.