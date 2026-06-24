---
name: code
description: >
  Standard code skill autoload command for code mode. Loads KISS principle
  mandatory + optional skills when relevant. Run for non-UI/UX code work.
---

# /code — Standard Code Skill Collection

## When to Run

- No `[UXUI]` prefix in the Objective
- No keywords: design, styling, theme, visual, layout, component, accessibility, WCAG, responsive, animation, motion, hover, transition, color, typography, spacing, token, breakpoint, ARIA, contrast, screen reader, tailwind, className, seo, ux, ui
- Standard code tasks: API development, backend logic, database queries, algorithms, data processing, infrastructure, etc.

## Mandatory Skills

| Skill | Purpose |
|-------|---------|
| `kiss-principle` | Simplicity guardrail — evaluate solutions against KISS, avoid over-engineering. **Always load first** after caveman |

## Available Skills

Load any additional skills from this list that fit the task context. Descriptions are generic -- each skill's own `SKILL.md` contains the full deep-dive. **Prefer loading more skills over fewer** — depth beats breadth only when you have the right depth:

| Skill | Load When |
|-------|-----------|
| `forge-seo` | SEO work detected (meta tags, sitemaps, structured data, performance, rendering) |
| `12-factor-app` | SaaS, cloud-native, microservices, containerized, or serverless workloads. Evaluates codebase, dependencies, config, processes, observability, and deployment model against 12-Factor + modern extensions |

## What to Apply After Loading

- Follow loaded skill guidance directly.
- **Only load `forge-seo` when needed** -- check for SEO keywords first.
- **Framework-agnostic** -- use language-native patterns unless framework-specific guidance is explicitly requested.

## Rules

- **Only load `forge-seo` when needed** -- check for SEO keywords first.
- **No UI/UX skills** -- do NOT load design, accessibility, or styling skills in standard code mode.
- **Prefer more skills over fewer** — if a task touches on cloud architecture, load `12-factor-app`; if it touches on simplicity concerns, lean on `kiss-principle`. Re-evaluate `<available_skills>` after every task clarification.
- **Reference files live in `~/.roo/skills/<skill>/references/`** -- substitute `<skill>` with the loaded skill name. Use `read_file` with the absolute path from the Zoo Code global skills directory.

## Important

Run `run_slash_command` with command `code` when standard code work is detected (no UI/UX). Load skills. Then implement directly following the loaded skill guidance.
