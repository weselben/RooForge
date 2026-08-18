# wayfinder

Wayfinder charts a huge chunk of work — too large for one agent session — as a shared map of decision tickets on the repo's issue tracker, then resolves them one at a time until the route to the destination is clear. It treats planning as the primary output: each ticket resolves a decision (not a build slice), and the map is done when nothing remains to decide before execution begins.

## When to load

- A loose idea has arrived that is too big for one session and wrapped in fog — the path from here to the destination isn't visible yet.
- You need to break down a large effort into a sequence of decision tickets that can be worked independently across multiple sessions.
- You have an existing wayfinder map (issue URL or number) and need to pick up the next frontier ticket.
- Forge orchestrator invokes it automatically at session start: `Skill(skill='forge-flow')` runs first, then `Skill(skill='wayfinder')` is auto-loaded in chart mode (if no map exists) or work-through-map mode (if a map is provided or exists in the tracker).

## How it works

### Chart the map (first session for a new effort)

1. **Name the destination** — run `Skill(skill='grilling')` + `Skill(skill='domain-modeling')` to pin down what this map is finding its way to (a spec, decision, or change). The destination fixes scope. (SKILL.md:84–86)
2. **Map the frontier** — grill breadth-first across the whole space to surface open decisions and first takeable steps. If no fog surfaces, stop: the journey fits one session. (SKILL.md:87–89)
3. **Create the map issue** — label `wayfinder:map` with Destination, Notes, empty Decisions-so-far, and fog sketched into **Not yet specified**. (SKILL.md:90)
4. **Create tickets as child issues** — then wire blocking edges in a second pass (issues need IDs first). Unspecifiable items stay in **Not yet specified**. (SKILL.md:91)
5. **Fire research subagents** — for each `research` ticket, spin up a subagent running `Skill(skill='deep-research')` in parallel, capturing findings on a throwaway `research/<name>` branch with a context pointer from the ticket. (SKILL.md:92)
6. **Stop** — charting is one session's work; it resolves no tickets. (SKILL.md:93)

### Work through the map (subsequent sessions)

1. **Load the map** — the low-res view (not every ticket body). (SKILL.md:96)
2. **Choose a ticket** — user-named or first frontier ticket (open, unblocked, unclaimed). **Claim it** by assigning to yourself before any work. (SKILL.md:97)
3. **Resolve it** — zoom as needed: fetch related/closed ticket bodies on demand; invoke skills named in the map's `## Notes`. Default to `Skill(skill='grilling')` + `Skill(skill='domain-modeling')`. (SKILL.md:98)
4. **Record resolution** — post answer as a resolution comment, **close** the issue, append a context pointer to the map's Decisions-so-far. (SKILL.md:99)
5. **Add/graduate tickets** — create-then-wire newly surfaced tickets; graduate fog patches from **Not yet specified** into tickets. If a decision reveals a ticket sits beyond the destination, **rule it out of scope** (close ticket, add line to Out of scope). Update or invalidate other tickets if needed. (SKILL.md:100)
6. **Never resolve more than one ticket per session** — except research tickets, which run in parallel via subagents. (SKILL.md:82)

### Integration with Forge

Forge owns the session sequence: `map → resolve → plan → work → verify → review → resolve`. Wayfinder provides steps 1–2 (Map and Resolve):
- **Map**: load existing map or invoke wayfinder chart mode (grilling + domain-modeling → map + tickets). Forge may dispatch parallel agents for independent fog patches via `Skill(skill='dispatching-parallel-agents')`. (forge/SKILL.md:33–38)
- **Resolve**: invoke the skill named by the ticket's `wayfinder:<type>` label (`Skill(skill='grilling')`, `Skill(skill='prototype')`, `Skill(skill='deep-research')`, `Skill(skill='domain-modeling')`, `task`). After every grilling ticket closes, invoke `Skill(skill='domain-modeling')` to sweep for new terms (update `docs/dev/CONTEXT.md`) and decisions (add ADR to `docs/adr/`). (forge/SKILL.md:40–44)

## Files in this skill

- `skills/wayfinder/SKILL.md` — Main skill definition: map structure, ticket types (research, prototype, grilling, task, domain-modeling), fog of war, out-of-scope rules, and both invocation modes (chart / work-through-map).
- `skills/wayfinder/scripts/setup-repo-gh-cli.sh` — Idempotent script to create the six `wayfinder:*` labels (`map`, `research`, `Skill(skill='prototype')`, `Skill(skill='grilling')`, `task`, `Skill(skill='domain-modeling')`) on the GitHub repo using `gh label create`. Run once per repo before first use. (Lines 8–26)

## See also

- **forge** — Orchestrator that auto-loads wayfinder at session start and drives the map→resolve→plan→work→verify→review→resolve flow. Calls wayfinder in chart mode (no map) or work-through-map mode (map exists).
- **grilling** — Default HITL ticket type; always invoked with `Skill(skill='domain-modeling')` for grilling tickets.
- **domain-modeling** — Runs with every grilling ticket to capture new domain terms (CONTEXT.md) and decisions (ADRs).
- **deep-research** — Resolves `research` tickets via parallel subagents on throwaway branches.
- **prototype** — Resolves `Skill(skill='prototype')` tickets by making a cheap concrete artifact to react to.
- **dispatching-parallel-agents** — Used by forge to run parallel subagents for independent fog patches during map charting and for research tickets.
- **git-issue-tracker** — Provides GitHub API operations for wayfinding (creating map/tickets, wiring blocking edges, querying frontier).
- **planning-and-task-breakdown** — Invoked by forge after the map's frontier is empty to break the cleared map into ordered tasks.

## Notes

- The `Skill(skill='domain-modeling')` ticket type is a full label as of `f9e268f` — `setup-repo-gh-cli.sh` now creates all six `wayfinder:*` labels including `wayfinder:domain-modeling`.
- The script uses a single color (`0075ca`) for all labels; GitHub UI may not visually distinguish ticket types.
- "Refer by name" rule (SKILL.md:18–22) mandates using ticket titles (not bare IDs) in all narration and the map's Decisions-so-far — the ID/URL rides inside the name as a link.
- The skill assumes a GitHub-backed tracker (`gh` CLI). For non-GitHub trackers, it defaults to a local-markdown tracker but no implementation is provided in this skill.