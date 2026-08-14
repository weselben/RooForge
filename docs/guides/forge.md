# forge

`forge` is the always-loaded session orchestrator. It owns the single path **map → resolve → plan → work → verify → review → resolve** (8 steps). Each step ends on a checkable criterion; the next step is the proof. `forge` invokes `forge-flow` once at session start to bootstrap the feat branch and the long-living contract goal, then runs steps 1–8 itself.

## When to load

- **Always** — load first, before responding to any user prompt, unless the user states otherwise in the prompt itself.
- Auto-triggers on session-start messages like "let's continue on the auth refactor", "work on the next ticket", "open the map for the payment effort", "what's next", "start a new effort: <idea>".
- Mandatory while any goal or map is active.

## How it works

1. **Forge Flow bootstraps** — `forge` invokes `forge-flow` (a frontier sub-skill) once at session start: detect map, name feat branch from `main`, write long-living contract goal, hand off.
2. **Map** — Load existing wayfinder map (by URL/number) or invoke `wayfinder` **chart** mode (grilling + domain-modeling → map + tickets). Parallel fog resolution via `dispatching-parallel-agents` when multiple independent fog patches exist.
3. **Resolve** — Work one ticket by invoking the skill named by its `wayfinder:<type>` label (`grilling`, `prototype`, `deep-research`, `domain-modeling`, `task`). After every grilling ticket closes, invoke `domain-modeling` to update `docs/dev/CONTEXT.md` and add ADRs to `docs/adr/`. One ticket per session.
4. **Plan** — When frontier empty, invoke `planning-and-task-breakdown`, enter plan mode, write plan file, request user approval. **Do not exit plan mode yourself.**
5. **Work** — Delegate to `subagent-driven-development` (SDD). SDD owns: worktree creation via `using-git-worktrees`, per-task subagent swarm via `dispatching-parallel-agents`, per-task review, fix loop, integration, squash-merging into the feat branch as one Conventional Commit per subagent via `git merge --squash` + `git commit`. On conflicts, load `resolving-merge-conflicts`. After squash-merge, load `forge-docs`.
6. **PR** — Open draft PR using `creating-pull-requests` (draft mode, AI disclosure). Write PR description using `ste100`. Update after each squash commit lands.
7. **Verify** — Load `verification-before-completion`. Run full test suite on merged feat branch. Check each subagent's claimed state against `git status` and suite result.
8. **Review** — Run `pr-review` in PR mode (`owner/repo#n`). Runs in a worktree, drives `kimi -p` loop via `loops`, posts ONE review in `caveman-review` format.
9. **Resolve findings** — `pr-resolve` consumes `pr-review` output. One resolver per finding group in its own worktree off PR head, commits under `use-git-identity`, pushes, replies in threads. Re-run `pr-review`. Loop ends when no 🔴/🟡 findings remain. On merge conflicts during push, load `resolving-merge-conflicts`.

## Files in this skill

- `skills/forge/SKILL.md` — Main orchestrator definition: invariant rules, 8-step flow, session start behaviour, git flow diagram, docs structure, role mandate for DPA/loops

## See also

- `forge-flow` — Frontier sub-skill invoked by forge at session start (branch + goal bootstrap)
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
- Description frontmatter auto-triggers forge on natural language — agents do not need an explicit invocation.
- One ticket per session limit may constrain throughput for large maps; research tickets run in parallel via `dispatching-parallel-agents` as an exception.
