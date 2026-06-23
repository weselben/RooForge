---
name: ui-ux
description: >
  UI/UX skill autoload command for code mode. Loads the forge-seo skill hub and
  other design-related skills when UI/UX work is detected. Run before implementing
  any design, styling, component, or accessibility task.
---

# /ui-ux — UI/UX Skill Collection

## When to Run

- `[UXUI]` prefix in the Objective
- Keywords: design, styling, theme, visual, layout, component, accessibility, WCAG, responsive, animation, motion, hover, transition, color, typography, spacing, token, breakpoint, ARIA, contrast, screen reader, tailwind, className, seo, ux, ui

## Mandatory Skills

Load these **every time** — no exceptions:

| Skill | Purpose |
|-------|---------|
| `forge-seo` | SEO hub with two references. After loading, `read_file` the relevant reference from `~/.roo/skills/forge-seo/references/` |
| `forge-eu-accessibility` | EU legal compliance (BFSG, EAA, WCAG). **Always load last** to apply legal guardrails |

## Available Skills

Load any additional skills from this list that fit the task context. Descriptions are generic — each skill's own `SKILL.md` contains the full deep-dive:

| Skill | Load When |
|-------|-----------|
| `frontend-design` | Creative direction needed |
| `forge-tailwindcss-conventions` | Using Tailwind CSS |
| `deep-research` | External intel needed (live docs, legal sources, Google updates) |
| Any user-installed skill | Relevant to task |

## What to Apply After Loading

- **Framework-agnostic:** Use CSS, HTML, and vanilla JS as the baseline. Never provide framework-specific guidance unless explicitly asked.
- **Quality floor:** Every UI/UX output must include responsive behavior, visible keyboard focus, and `prefers-reduced-motion` respect.
- **Anti-generic enforcement:** Reject default "AI slop" aesthetics unless explicitly requested.
- **Accessibility compliance:** Apply WCAG 2.1 AA, BFSG, and EAA guardrails from `forge-eu-accessibility`.
- **SEO awareness:** Apply guidance from the relevant `forge-seo` reference based on task context.
- **MCP-first for research:** Use `run_slash_command` with command `web` to verify live sources before making compliance claims.

## Rules

- **Only `forge-eu-accessibility` is mandatory** for every `/ui-ux` invocation. Load it last.
- **No rigid skill sequence** — after loading `forge-seo`, select from available skills that fit the task.
- **Do NOT invoke this command** when the task does not involve UI/UX work.
- **Reference files live in `~/.roo/skills/forge-seo/references/`** — use `read_file` with the absolute path from the Zoo Code global skills directory.

## Important

Run `run_slash_command` with command `ui-ux` when UI/UX work is detected. Load skills. Then implement directly following the loaded skill guidance.
