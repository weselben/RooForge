---
name: code
description: >
  Standard code skill autoload command for code mode. Loads optional skills when
  technical SEO work is detected. Run for non-UI/UX code work.
---

# /code — Standard Code Skill Collection

## When to Run

- No `[UXUI]` prefix in the Objective
- No keywords: design, styling, theme, visual, layout, component, accessibility, WCAG, responsive, animation, motion, hover, transition, color, typography, spacing, token, breakpoint, ARIA, contrast, screen reader, tailwind, className, seo, ux, ui
- Standard code tasks: API development, backend logic, database queries, algorithms, data processing, infrastructure, etc.

## Mandatory Skills

None -- core pipeline skills are auto-loaded by code mode. No additional skill loading required for standard code work.

## Available Skills

Load any additional skills from this list that fit the task context. Descriptions are generic -- each skill's own `SKILL.md` contains the full deep-dive:

| Skill | Load When |
|-------|-----------|
| `forge-seo` | SEO work detected (meta tags, sitemaps, structured data, performance, rendering) |

## What to Apply After Loading

- Follow loaded skill guidance directly.
- **No design or accessibility skills** -- do NOT load `frontend-design`, `forge-eu-accessibility`, `forge-tailwindcss-conventions`, or any UI/UX-specific skill in standard code mode.
- **SEO optional** -- only load `forge-seo` when the task explicitly involves SEO implementation.
- **Framework-agnostic** -- use language-native patterns unless framework-specific guidance is explicitly requested.

## Rules

- **Only load `forge-seo` when needed** -- do NOT load it for every code task. Check for SEO keywords first.
- **No UI/UX skills** -- do NOT load design, accessibility, or styling skills in standard code mode.
- **Reference files live in `~/.roo/skills/<skill>/references/`** -- substitute `<skill>` with the loaded skill name. Use `read_file` with the absolute path from the Zoo Code global skills directory.

## Important

Run `run_slash_command` with command `code` when standard code work is detected (no UI/UX). Load skills. Then implement directly following the loaded skill guidance.
