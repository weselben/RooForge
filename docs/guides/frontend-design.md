# frontend-design

Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one. Avoid templated defaults; take one justified aesthetic risk per design.

## When to load

- Building new UI or reshaping existing UI.
- The user mentions typography, palette, layout, visual identity, or aesthetic direction.
- A design reads as a templated default (cream serif, near-black + acid green, broadsheet rules).

## How it works

The skill frames the agent as the design lead at a small studio known for distinctive work. Five principles:

1. **Ground it in the subject** — pin down the product, audience, and page's single job before designing. Use the subject's own world (materials, instruments, artifacts, vernacular).
2. **Hero is a thesis** — open with the most characteristic thing, not "big number + small label + gradient accent".
3. **Typography carries personality** — pair display and body deliberately. Set a clear type scale with intentional weights, widths, spacing.
4. **Structure is information** — eyebrows, dividers, labels encode something true about content, not decorate it. Question numbered markers (01/02/03) — only use if the content actually is a sequence.
5. **Motion is deliberate** — page-load sequence, scroll-reveal, hover micro-interactions. Sometimes less is more; match complexity to vision.

**Process: brainstorm → explore → plan → critique → build → critique again.**

1. **Brainstorm** a compact token system: 4–6 hex colors, typefaces for 2+ roles, layout concept (one-sentence prose + ASCII wireframes), and a signature element — the one unique thing this page will be remembered by.
2. **Critique** the plan against the brief — would a similar prompt arrive at the same plan? If yes, revise.
3. **Build** to the revised plan, deriving every color and type decision from it. Plan CSS selector specificity in thinking before writing.
4. **Self-critique** while building — screenshot if the environment supports it. Channel's advice: remove one accessory before leaving the house.

**Three templated looks to avoid by default**: (1) cream + high-contrast serif + terracotta, (2) near-black + acid-green/vermilion, (3) broadsheet hairline rules + zero border-radius. They're legitimate when the brief calls for them; defaulting to them isn't.

## Restraint and self-critique

- Spend boldness in one place — signature element carries the design.
- Build to a quality floor: responsive to mobile, visible keyboard focus, reduced-motion respected.
- Critique your own work — pictures worth 1000 tokens.

## Writing in design

- Words appear to make a design easier to use — not decoration.
- Write from the end-user's side: name things by what they control, not how the system is built.
- Active voice: "Save changes", not "Submit".
- Failure is direction, not mood: errors say what happened and how to fix.
- Conversational register, plain verbs, sentence case.

## Files in this skill

- `skills/frontend-design/SKILL.md` — full skill text: ground-it-in-subject, design principles, process, restraint, writing guidance

## See also

- `forge-eu-accessibility` — mandatory companion for UI work (a11y is structural, not cosmetic)
- `kiss-principle` — applies when the design reads as over-engineered
- `forge-tailwindcss-conventions` — Tailwind-specific implementation companion
- `forge-docs` — load before writing system-design notes that cite frontend-design choices

## Notes

- Source: anthropics/skills, `https://raw.githubusercontent.com/anthropics/skills/main/skills/frontend-design/SKILL.md`.
- License: see `LICENSE.txt` in the upstream source repo.