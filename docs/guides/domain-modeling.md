# domain-modeling

Active discipline for building and sharpening the project's domain model as you design — challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise. Distinct from merely reading `CONTEXT.md` for vocabulary (a one-line habit any skill can do); this skill is for *changing* the model, not just consuming it.

## When to load

- The user wants to pin down domain terminology or pick a ubiquitous language.
- The user wants to record an architectural decision.
- Another skill (notably `Skill(skill='forge')` and `Skill(skill='wayfinder')`) needs the domain model maintained.
- `Skill(skill='forge')` orchestration calls it in two spots (see `skills/forge/SKILL.md`):
  - **Step 1 — Map:** `Skill(skill='wayfinder')` chart mode uses `Skill(skill='domain-modeling')` together with `Skill(skill='grilling')` to produce the map + tickets.
  - **Step 2 — Resolve:** "After every grilling ticket closes, invoke `Skill(skill='domain-modeling')` to sweep for new terms (update `docs/dev/CONTEXT.md`) and decisions worth recording (add ADR to `docs/adr/`). Don't wait for the user — the model crystallises the moment a decision lands."

## How it works

1. **Detect the context layout.** Read `docs/dev/CONTEXT-MAP.md` if it exists; otherwise treat the repo as a single context with one `docs/dev/CONTEXT.md`. Create files lazily — only when you have something to write (`skills/domain-modeling/SKILL.md:15-23`).
2. **Challenge the glossary inline.** When the user uses a term that conflicts with `CONTEXT.md`, call it out immediately: "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?" (`SKILL.md:33`).
3. **Sharpen fuzzy language.** When the user uses vague or overloaded terms, propose a precise canonical term, e.g. "You're saying 'account' — do you mean the Customer or the User?" (`SKILL.md:37`).
4. **Discuss concrete scenarios.** Stress-test relationships with specific edge cases that force the user to be precise about concept boundaries (`SKILL.md:41`).
5. **Cross-reference with code.** When the user states how something works, check whether the code agrees; surface contradictions rather than glossing them (`SKILL.md:45`).
6. **Update `CONTEXT.md` inline.** When a term is resolved, write it into `docs/dev/CONTEXT.md` right there — don't batch. Use the format in `CONTEXT-FORMAT.md`. Keep `CONTEXT.md` devoid of implementation details; it is a glossary and nothing else (`SKILL.md:49-55`).
7. **Offer ADRs sparingly.** Only when all three criteria hold: hard to reverse, surprising without context, and the result of a real trade-off. If any of the three is missing, skip the ADR (`SKILL.md:59-67`). Use the format in `ADR-FORMAT.md`.
8. **Commit ADRs to the feat branch immediately.** ADRs are mutable on a feat branch and become immutable once merged to `main`. If a decision later changes, write a new ADR with a superseding status linking back to the original (`SKILL.md:25-31`). Do not batch ADRs or hold them until the branch is "done".

## Files in this skill

- `skills/domain-modeling/SKILL.md` — the skill itself: when to load, behaviour during a session, the three ADR criteria, the ADR merge-mutability rule.
- `skills/domain-modeling/CONTEXT-FORMAT.md` — structure and rules for `docs/dev/CONTEXT.md` (and `CONTEXT-MAP.md` for multi-context repos): opinionated terms, `_Avoid_` lists, single vs multi-context layout.
- `skills/domain-modeling/ADR-FORMAT.md` — minimal ADR template, sequential numbering (`0001-slug.md`), lazy directory creation, when to skip an ADR, what qualifies.

## See also

- `skills/forge/SKILL.md` — orchestrator that calls `Skill(skill='domain-modeling')` after every grilling ticket (step 2) and uses it in chart mode (step 1) to build the map + tickets.
- `skills/wayfinder/` — owns the map; its **chart** mode pairs `Skill(skill='grilling')` with `Skill(skill='domain-modeling')` to produce the initial map and frontier tickets.
- `skills/grilling/` — surfaces the decisions and terms that `Skill(skill='domain-modeling')` then records; its closed tickets are the trigger for the `Skill(skill='forge')` step-2 sweep.
- `skills/planning-and-task-breakdown` — runs after the map's frontier is empty; the glossary and ADRs from `Skill(skill='domain-modeling')` feed its inputs.
- `docs/dev/CONTEXT.md` (per project) — the glossary this skill maintains; format spec lives in `CONTEXT-FORMAT.md`.
- `docs/adr/` (per project) — the ADR directory this skill populates; format spec lives in `ADR-FORMAT.md`.

## Notes

- The skill's `source` frontmatter points at `https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md` (`SKILL.md:3`) — not verified live; treat as provenance, not a checked link.
- `skills/domain-modeling/` contains only the three `.md` files above; there are no scripts or templates to invoke directly. The "templates" are the format specimens embedded in `CONTEXT-FORMAT.md` and `ADR-FORMAT.md`.
- `forge/SKILL.md` line numbers reference `Skill(skill='domain-modeling')` from step 1 (chart mode) and step 2 (post-grilling sweep); step 4 (work) does not re-invoke it — ADRs are committed to the feat branch as they are written, not bundled into the work subagent swarms.
