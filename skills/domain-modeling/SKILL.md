---
name: domain-modeling
description: Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology or a ubiquitous language, record an architectural decision, or when another skill needs to maintain the domain model.
source: "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/domain-modeling/SKILL.md"
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the *active* discipline — challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise. (Merely *reading* `CONTEXT.md` for vocabulary is not this skill — that's a one-line habit any skill can do. This skill is for when you're changing the model, not just consuming it.)

## File structure

All domain-model artifacts live under `docs/dev/` (global docs structure is owned by `Skill(skill='forge-docs')`):

```
/
├── docs/
│   ├── adr/                          ← Architecture Decision Records (see forge-docs)
│   └── dev/
│       ├── CONTEXT.md                ← domain glossary (single context)
│       └── CONTEXT-MAP.md            ← multi-context map (only if multiple contexts)
└── src/
```

**Single context (most repos):** One `CONTEXT.md` at `docs/dev/CONTEXT.md`.

**Multiple contexts:** A `CONTEXT-MAP.md` at `docs/dev/CONTEXT-MAP.md` lists the contexts and where they live. Each context has its own `CONTEXT.md` under its own directory.

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists at `docs/dev/CONTEXT.md`, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed. The global docs structure and index conventions are defined by `Skill(skill='forge-docs')` — follow its templates and update rules.

## ADR mandate — commit actively to feat branches

ADRs are **living documents** until the branch merges. Commit them to the feat branch as you create them — they are mutable there. Once the feat branch merges to `main`, ADRs become **immutable**: do not amend, rewrite, or alter them after merge. If a decision changes, create a new ADR with a superseding status and link back to the original.

Do not batch ADRs or hold them until the branch is "done". Each decision is recorded at the moment it crystallises and committed immediately. The `Skill(skill='forge-docs')` skill enforces the global ADR conventions (flat `docs/adr/`, glossary cross-references, no `docs/adr/README.md`); follow its rules.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` at `docs/dev/CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` should be totally devoid of implementation details. Do not treat `CONTEXT.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).