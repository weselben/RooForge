---
name: ui-ux
description: >
  UI/UX skill autoload command for code mode. Loads the forge-seo skill hub and
  other design-related skills when UI/UX work is detected. Models select from
  available skills based on task context. Run before implementing any design,
  styling, component, or accessibility task.
---

# /ui-ux — UI/UX Skill Collection

## When to Run

- `[UXUI]` prefix in the Objective
- Keywords: design, styling, theme, visual, layout, component, accessibility, WCAG, responsive, animation, motion, hover, transition, color, typography, spacing, token, breakpoint, ARIA, contrast, screen reader, tailwind, className, seo, ux, ui

## Mandatory Skills

Load these **every time** — no exceptions:

| Skill | Purpose |
|-------|---------|
| `forge-seo` | SEO hub with two reference files (UX/UI SEO + Technical SEO). After loading, `read_file` the relevant reference from `~/.roo/skills/forge-seo/references/` |
| `forge-eu-accessibility` | EU legal compliance (BFSG, EAA, WCAG). **Always load last** to apply legal guardrails on top of design direction |

## Available Skills

No rigid sequence. Choose what fits the task context from this catalog:

| Skill | Load When | Purpose |
|-------|-----------|---------|
| `frontend-design` | Creative direction needed | Design philosophy, typography, color, composition, anti-generic guardrails |
| `forge-tailwindcss-conventions` | Using Tailwind CSS | Tailwind v4 CSS-first conventions, class ordering, React/Vue/Nuxt 4/Svelte patterns |
| `deep-research` | External intel needed | Delegate to ask mode for live docs, Google updates, legal sources |
| Any user-installed skill | Relevant to task | Any other skill in `~/.roo/skills/` that fits the context |

## What to Apply After Loading

- **Framework-agnostic:** Use CSS, HTML, and vanilla JS as the baseline. Never provide React, Vue, Angular, or Svelte-specific guidance unless explicitly asked.
- **Quality floor:** Every UI/UX output must include responsive behavior, visible keyboard focus, and `prefers-reduced-motion` respect even when not explicitly requested.
- **Anti-generic enforcement:** Reject default "AI slop" aesthetics (Inter + Roboto + purple gradients + card grids) unless the user explicitly requests them.
- **Accessibility compliance:** Apply WCAG 2.1 AA, BFSG, and EAA guardrails from forge-eu-accessibility skill.
- **SEO awareness:** Apply guidance from the relevant `forge-seo` reference file (UX/UI or Technical) based on task context.
- **MCP-first for research:** Use `run_slash_command` with command `web` to verify live legal sources (BFSG, EAA) and Google SEO docs before making compliance claims.

## Rules

- **Only `forge-eu-accessibility` is mandatory** for every `/ui-ux` invocation. Load it last.
- **No rigid skill sequence** — after loading `forge-seo`, select from available skills that fit the task.
- **Do NOT invoke this command** when the task does not involve UI/UX work (design, styling, accessibility, visual, or SEO-related).
- **Reference files live in `~/.roo/skills/forge-seo/references/`** — use `read_file` with the absolute path from the Zoo Code global skills directory to access them.

## Important

Run `run_slash_command` with command `ui-ux` when UI/UX work is detected. Load skills. Then implement directly following the loaded skill guidance.
