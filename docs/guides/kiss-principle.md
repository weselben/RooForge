# kiss-principle

Keep It Simple, Stupid — coined by Kelly Johnson (Lockheed Skunk Works, 1960s). Systems work best when kept simple rather than made complicated. Every line of code is a liability.

## When to load

- A design or implementation feels over-engineered, clever, or bloated.
- Evaluating architecture or reviewing code for simplicity.
- The user mentions KISS, over-engineering, premature abstraction, or YAGNI.

## How it works

**Six core rules**:

1. Start with the naive solution — make it work, then evaluate if complexity is needed
2. One responsibility per component — function, class, module, agent
3. Avoid premature abstraction — wait for 3+ concrete instances of duplication
4. Minimize dependencies — each is a liability and failure point
5. Explicit over implicit — no magic, no hidden behavior, no clever one-liners
6. Composable > hierarchical — flat function composition beats deep inheritance

**KISS decision checklist**:

- [ ] Is this the simplest solution that correctly solves the problem?
- [ ] Would a junior developer understand this in under 2 minutes?
- [ ] Are we solving a real current problem or a hypothetical future one?
- [ ] Can anything be removed and still meet the requirement?
- [ ] Does this add a new dependency or moving part?
- [ ] Is the complexity proportional to the problem's scale?

**Anti-patterns**:

- Over-engineering / "just in case" features → implement only what's needed now
- Premature abstraction → copy-paste until 3+ duplications are clear
- Deep inheritance hierarchies → favor composition
- God objects → split into focused, single-responsibility units
- Microservices for small teams → start monolith, extract when boundaries are clear
- Custom frameworks → use proven libraries
- Complex agent orchestration → plain function composition, one agent = one tool

## Related principles

- **YAGNI** — You Aren't Gonna Need It (defer hypothetical features)
- **DRY** — eliminate duplication, but don't over-abstract to achieve it
- **Unix Philosophy** — do one thing well, compose small tools
- **Occam's Razor** — simplest explanation is usually correct

## Files in this skill

- `skills/kiss-principle/SKILL.md` — full rules, checklist, anti-patterns, related principles

## See also

- `Skill(skill='12-factor-app')` — applies to architecture review under KISS
- `Skill(skill='forge-docs')` — load before recording a KISS-derived ADR

## Notes

- No scripts, templates, or companion files.
- Source: https://en.wikipedia.org/wiki/KISS_principle.
