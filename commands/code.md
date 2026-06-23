---
name: code
description: >
  Standard code skill autoload command for code mode. Loads core pipeline skills
  and optionally the forge-seo hub when technical SEO work is detected. Models
  select from available skills based on task context. Run for non-UI/UX code
  work.
---

# /code — Standard Code Skill Collection

## When to Run

- No `[UXUI]` prefix in the Objective
- No keywords: design, styling, theme, visual, layout, component, accessibility, WCAG, responsive, animation, motion, hover, transition, color, typography, spacing, token, breakpoint, ARIA, contrast, screen reader, tailwind, className, seo, ux, ui
- Standard code tasks: API development, backend logic, database queries, algorithms, data processing, infrastructure, etc.

## Mandatory Skills

Load these **every time** — no exceptions:

| Skill | Purpose |
|-------|---------|
| `forge` | Pipeline orientation, role boundaries, command registry, available commands. **Load first** |
| `caveman` | Token-efficient communication. Auto-loaded by forge, but explicit load ensures consistency |
| `conventional-commits` | Conventional Commits v1.0.0 format reference. Load when creating commit messages |
| `forge-subtask-breakdown` | XS/S atomic decomposition, UI/UX prefix injection, Blueprint loading. Load when planning implementation |

## Available Skills

No rigid sequence. Choose what fits the task context:

| Skill | Load When | Purpose |
|-------|-----------|---------|
| `forge-seo` | SEO work detected (meta tags, sitemaps, structured data, performance, rendering) | SEO hub with two references. After loading, `read_file` the relevant reference from `~/.roo/skills/forge-seo/references/` |
| `deep-research` | External intel needed | Delegate to ask mode for docs, APIs, library docs, research |
| Any user-installed skill | Relevant to task | Any other skill in `~/.roo/skills/` that fits the context |

## What to Apply After Loading

- Follow loaded skill guidance directly.
- **No design or accessibility skills** — do NOT load `frontend-design`, `forge-eu-accessibility`, `forge-tailwindcss-conventions`, or any UI/UX-specific skill in standard code mode.
- **SEO optional** — only load `forge-seo` when the task explicitly involves SEO implementation (meta tags, sitemaps, structured data, rendering strategy, performance).
- **Framework-agnostic** — use language-native patterns unless framework-specific guidance is explicitly requested.

## Rules

- **Only load `forge-seo` when needed** — do NOT load it for every code task. Check for SEO keywords first.
- **No UI/UX skills** — do NOT load design, accessibility, or styling skills in standard code mode.
- **Reference files live in `~/.roo/skills/forge-seo/references/`** — use `read_file` with the absolute path from the Zoo Code global skills directory to access them.

## Important

Run `run_slash_command` with command `code` when standard code work is detected (no UI/UX). Load skills. Then implement directly following the loaded skill guidance.
