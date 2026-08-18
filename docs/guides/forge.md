# forge

`Skill(skill='forge')` is the always-loaded session orchestrator. It owns the single path **map → resolve → plan → work → verify → review → resolve** (8 steps). Each step ends on a checkable criterion; the next step is the proof. `Skill(skill='forge')` invokes `Skill(skill='forge-flow')` once at session start to bootstrap the feat branch and the long-living contract goal, then runs steps 1–8 itself.

## When to load

- **Always** — load first, before responding to any user prompt, unless the user states otherwise in the prompt itself.
- Auto-triggers on session-start messages like "let's continue on the auth refactor", "work on the next ticket", "open the map for the payment effort", "what's next", "start a new effort: <idea>".
- Mandatory while any goal or map is active.

## How it works

1. **Forge Flow bootstraps** — `Skill(skill='forge')` invokes `Skill(skill='forge-flow')` (a frontier sub-skill) once at session start: detect map, name feat branch from `main`, write long-living contract goal, hand off.
2. **Map** — Load existing wayfinder map (by URL/number) or invoke `Skill(skill='wayfinder')` **chart** mode (grilling + domain-modeling → map + tickets). Parallel fog resolution via `Skill(skill='dispatching-parallel-agents')` when multiple independent fog patches exist.
3. **Resolve** — Work one ticket by invoking the skill named by its `wayfinder:<type>` label (`Skill(skill='grilling')`, `Skill(skill='prototype')`, `Skill(skill='deep-research')`, `Skill(skill='domain-modeling')`, `task`). After every grilling ticket closes, invoke `Skill(skill='domain-modeling')` to update `docs/dev/CONTEXT.md` and add ADRs to `docs/adr/`. One ticket per session.
4. **Plan** — When frontier empty, invoke `Skill(skill='planning-and-task-breakdown')`, enter plan mode, write plan file, request user approval. **Do not exit plan mode yourself.**
5. **Work** — Delegate to `Skill(skill='subagent-driven-development')` (SDD). SDD owns: worktree creation via `Skill(skill='using-git-worktrees')`, per-task subagent swarm via `Skill(skill='dispatching-parallel-agents')`, per-task review, fix loop, integration, squash-merging into the feat branch as one Conventional Commit per subagent via `git merge --squash` + `git commit`. On conflicts, load `Skill(skill='resolving-merge-conflicts')`. After squash-merge, load `Skill(skill='forge-docs')`.
6. **PR** — Open draft PR using `Skill(skill='creating-pull-requests')` (draft mode, AI disclosure). Write PR description using `Skill(skill='ste100')`. Update after each squash commit lands.
7. **Verify** — Load `Skill(skill='verification-before-completion')`. Run full test suite on merged feat branch. Check each subagent's claimed state against `git status` and suite result.
8. **Review** — Run `Skill(skill='pr-review')` in PR mode (`owner/repo#n`). Runs in a worktree, drives `kimi -p` loop via `Skill(skill='loops')`, posts ONE review in `Skill(skill='caveman-review')` format.
9. **Resolve findings** — `Skill(skill='pr-resolve')` consumes `Skill(skill='pr-review')` output. One resolver per finding group in its own worktree off PR head, commits under `Skill(skill='use-git-identity')`, pushes, replies in threads. Re-run `Skill(skill='pr-review')`. Loop ends when no 🔴/🟡 findings remain. On merge conflicts during push, load `Skill(skill='resolving-merge-conflicts')`.

## Files in this skill

- `skills/forge/SKILL.md` — Main orchestrator definition: invariant rules, 8-step flow, session start behaviour, git flow diagram, docs structure, role mandate for DPA/loops

## See also

- `Skill(skill='forge-flow')` — Frontier sub-skill invoked by forge at session start (branch + goal bootstrap)
- `Skill(skill='caveman')` — Default communication mode (ultra) active every session
- `Skill(skill='wayfinder')` — Map loading/charting (step 2); invoked in chart or load mode
- `Skill(skill='dispatching-parallel-agents')` — Single home for parallel subagent swarms (map fog areas, deep-research, SDD, merge conflicts)
- `Skill(skill='grilling')` / `Skill(skill='prototype')` / `Skill(skill='deep-research')` / `Skill(skill='domain-modeling')` / `task` — Skills invoked per ticket's `wayfinder:<type>` label (step 3)
- `Skill(skill='planning-and-task-breakdown')` — Breaks cleared map into ordered tasks (step 4)
- `Skill(skill='subagent-driven-development')` — Owns worktrees, swarms, review, integration, squash-merge (step 5)
- `Skill(skill='using-git-worktrees')` — Worktree creation for SDD
- `Skill(skill='resolving-merge-conflicts')` — Hunk-by-hunk resolution; delegates multi-branch to SDD (steps 5, 9)
- `Skill(skill='forge-docs')` — Docs updates that travel with squash commit (step 5)
- `Skill(skill='creating-pull-requests')` — Opens draft PR with AI disclosure (step 6)
- `Skill(skill='ste100')` — PR description format (step 6)
- `Skill(skill='verification-before-completion')` — Full test suite verification on feat branch (step 7)
- `Skill(skill='pr-review')` — Runs `kimi -p` loop via `Skill(skill='loops')`, posts review in caveman-review format (step 8)
- `Skill(skill='caveman-review')` — Review comment format used by pr-review
- `Skill(skill='pr-resolve')` — Consumes pr-review output; one resolver per finding group (step 9)
- `Skill(skill='use-git-identity')` — Commits under correct identity for pr-resolve
- `Skill(skill='loops')` — Single home for all `kimi -p` iteration (used by pr-review, pr-resolve)

## Notes

- Only one file in this skill: `SKILL.md`. No scripts, templates, or companion files.
- Description frontmatter auto-triggers forge on natural language — agents do not need an explicit invocation.
- One ticket per session limit may constrain throughput for large maps; research tickets run in parallel via `Skill(skill='dispatching-parallel-agents')` as an exception.
