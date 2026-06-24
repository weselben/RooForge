---
name: kiss-principle
description: >
  Evaluate designs, code, and architecture against the KISS principle (Keep It Simple, Stupid).
  Apply simplicity guardrails to avoid over-engineering, accidental complexity, and premature abstraction.
  Use when designing systems, writing code, evaluating architectures, or when any solution feels
  overly complex, clever, or bloated. Source: Wikipedia.
source: https://en.wikipedia.org/wiki/KISS_principle
---

# KISS Principle

> **Keep It Simple, Stupid** — coined by Kelly Johnson (Lockheed Skunk Works, 1960s).
> Systems work best when kept simple rather than made complicated. Every line of code is a liability.

## Core Rules

1. **Start with the naive solution** — make it work, then evaluate if complexity is needed
2. **One responsibility per component** — agent, function, class, or module
3. **Avoid premature abstraction** — wait for 3+ concrete instances of duplication
4. **Minimize dependencies** — each is a liability and failure point
5. **Explicit over implicit** — no magic, no hidden behavior, no clever one-liners
6. **Composable > hierarchical** — flat function composition beats deep inheritance or state machines

## KISS Decision Checklist

- [ ] Is this the simplest solution that correctly solves the problem?
- [ ] Would a junior developer understand this in under 2 minutes?
- [ ] Are we solving a real current problem or a hypothetical future one?
- [ ] Can anything be removed and still meet the requirement?
- [ ] Does this add a new dependency or moving part?
- [ ] Is the complexity proportional to the problem's scale?

## Anti-Patterns (Non-KISS)

| Anti-Pattern | Fix |
|---|---|
| Over-engineering / "just in case" features | Implement only what's needed now |
| Premature abstraction | Copy-paste until 3+ duplications are clear |
| Deep inheritance hierarchies | Favor composition over inheritance |
| God objects | Split into focused, single-responsibility units |
| Microservices for small teams | Start monolith, extract when boundaries are clear |
| Custom frameworks | Use proven libraries |
| Complex agent orchestration | Plain function composition, one agent = one tool |

## Related Principles

- **YAGNI** — You Aren't Gonna Need It (defer hypothetical features)
- **DRY** — eliminate duplication, but don't over-abstract to achieve it
- **Unix Philosophy** — do one thing well, compose small tools
- **Occam's Razor** — simplest explanation is usually correct