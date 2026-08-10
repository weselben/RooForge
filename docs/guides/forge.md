# forge

Forge owns the session-start flow — it runs a single path through **map → resolve → plan → work → verify → review → resolve**. Auto-loads on every session start alongside `forge-flow`, `caveman` (ultra), and `wayfinder`. Each step ends on a checkable criterion; the next step is the proof.

## When to load

- Auto-loads on **every session start** (mandated by the skill)
- When starting any new development session in a repo you own
- Trigger phrases: "forge", "start session", "new feature", "begin work"

## How it works

1. **Forge Flow first** — `forge-flow` creates the feat branch from `main`, sets the harness goal, hands off to forge (SKILL.md:20-21)
2. **Map** — Load existing wayfinder map (by URL/number) or invoke `wayfinder` **chart** mode (grilling + domain-modeling → map + tickets). Parallel fog resolution via `dispatching-parallel-agents` when multiple independent fog patches exist (SKILL.md:26-31)
3. **Resolve** — Work one ticket by invoking the skill named by its `wayfinder:<type>` label (`grilling`, `prototype`, `deep-research`, `domain-modeling`, `task`). After every grilling ticket closes, invoke `domain-modeling` to update `docs/dev/CONTEXT.md` and add ADRs to `docs/adr/`. One ticket per session (SKILL.md:34-39)
4. **Plan** — When frontier empty, invoke `planning-and-task-breakdown`, enter plan mode, write plan file, request user approval. **Do not exit plan mode yourself** (SKILL.md:42-45)
5. **Work** — Delegate to `subagent-driven-development` (SDD). SDD owns: worktree creation via `using-git-worktrees`, per-task subagent swarm via `dispatching-parallel-agents`, per-task review, fix loop, integration, squash-merge into feat branch as one Conventional Commit per subagent. On conflicts, load `resolving-merge-conflicts`. After squash-merge, load `forge-docs` (SKILL.md:48-54)
6. **PR** — Open draft PR using `creating-pull-requests` (draft mode, AI disclosure). Write PR description using `ste100`. Update after each squash commit lands (SKILL.md:57-60)
7. **Verify** — Load `verification-before-completion`. Run full test suite on merged feat branch. Check each subagent's claimed state against `git status` and suite result (SKILL.md:63-65)
8. **Review** — Run `pr-review` in PR mode (`owner/repo#n`). Runs in a worktree, drives `kimi -p` loop via `loops`, posts ONE review in `caveman-review` format (SKILL.md:68-70)
9. **Resolve findings** — `pr-resolve` consumes `pr-review` output. One resolver per finding group in its own worktree off PR head, commits under `use-git-identity`, pushes, replies in threads. Re-run `pr-review`. Loop ends when no 🔴/🟡 findings remain. On merge conflicts during push, load `resolving-merge-conflicts` (SKILL.md:73-77)

## Files in this skill

- `skills/forge/SKILL.md` — Main orchestrator definition: invariant rules, 9-step flow, session start behaviour, git flow diagram, docs structure, role mandate for DPA/loops

## See also

- `forge-flow` — Runs before step 1: creates feat branch from main, sets harness goal
- `caveman` — Default communication mode (ultra) active every session
- `wayfinder` — Map loading/charting (step 2); invoked in chart or load mode
- `dispatching-parallel-agents` — Single home for parallel subagent swarms (map fog areas, deep-research, SDD, merge conflicts)
- `grilling` / `prototype` / `deep-research` / `domain-modeling` / `task` — Skills invoked per ticket's `wayfinder:<type>` label (step 3)
- `planning-and-task-breakdown` — Breaks cleared map into ordered tasks (step 4)
- `subagent-driven-development` — Owns worktrees, swarms, review, integration, squash-merge (step 5)
- `using-git-worktrees` — Worktree creation for SDD
- `resolving-merge-conflicts` — Hunk-by-hunk resolution; delegates multi-branch to SDD (steps 5, 9)
- `forge-docs` — Docs updates that travel with squash commit (step 5)
- `creating-pull-requests` — Opens draft PR with AI disclosure (step 6)
- `ste100` — PR description format (step 6)
- `verification-before-completion` — Full test suite verification on feat branch (step 7)
- `pr-review` — Runs `kimi -p` loop via `loops`, posts review in caveman-review format (step 8)
- `caveman-review` — Review comment format used by pr-review
- `pr-resolve` — Consumes pr-review output; one resolver per finding group (step 9)
- `use-git-identity` — Commits under correct identity for pr-resolve
- `loops` — Single home for all `kimi -p` iteration (used by pr-review, pr-resolve)

## Notes

- Only one file in this skill: `SKILL.md`. No scripts, templates, or companion files.
- The skill references many other skills by name; some (e.g., `forge-flow`, `forge-docs`, `ste100`, `verification-before-completion`, `use-git-identity`, `grilling`, `prototype`, `task`) are not present in the current `skills/` directory — verify they exist or are aliases.
- "Auto-loads on session start" implies the harness loads it; no explicit trigger mechanism documented.
- One ticket per session limit (SKILL.md:39) may constrain throughput for large maps.