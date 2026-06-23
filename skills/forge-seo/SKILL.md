---
name: forge-seo
description: >
  SEO skill hub with two reference deep-dives: UX/UI SEO (design decisions that
  impact rankings) and Technical SEO (sitemaps, structured data, meta tags,
  rendering strategy). Loaded by /ui-ux or /code when SEO work is detected.
  Models select the appropriate reference based on task context — no rigid
  sequence required.
---

# SEO — UX/UI & Technical Deep-Dive Hub

## Overview

This skill provides two reference files covering the two primary SEO domains.
Load this skill first, then read the relevant reference file(s) based on task
context. Do NOT read both unless the task genuinely spans both domains.

## Reference Files

Access via `read_file` using the paths below (the `skill` tool cannot read
subdirectories directly). These paths assume the skill is installed in the
standard Zoo Code global skills directory (`~/.roo/skills/`):

- `~/.roo/skills/forge-seo/references/uxui-seo.md` — UX/UI SEO: Core Web Vitals, mobile-first
design, accessibility ranking, structured data for rich results, engagement
metrics, E-E-A-T, keyword intent, AI search optimization, content optimization.
Use this for design, styling, component, layout, or accessibility tasks.

- `~/.roo/skills/forge-seo/references/technical-seo.md` — Technical SEO: XML sitemaps,
`robots.txt`, canonical URLs, JSON-LD structured data, Open Graph/Twitter cards,
meta tags, SSR/SSG/CSR rendering strategy, technical audit checklist. Use this
for implementation tasks involving meta tags, sitemaps, structured data,
rendering strategy, or crawlability.

## How to Choose

| Task Context | Read This Reference |
|-------------|---------------------|
| Design, layout, styling, components, visual hierarchy, accessibility, responsive behavior | `~/.roo/skills/forge-seo/references/uxui-seo.md` |
| Sitemap, robots.txt, canonical, meta tags, JSON-LD, Open Graph, rendering strategy, crawlability | `~/.roo/skills/forge-seo/references/technical-seo.md` |
| Both (e.g., full page implementation with SEO) | Both, in order: UX/UI first, then Technical |

## Rules

- **No rigid sequence** — load this skill, read the relevant reference, then vibe
which companion skills fit the task. Only `forge-eu-accessibility` is mandatory for
UI/UX work.
- **Do NOT read both references** unless the task explicitly spans both UX/UI
and technical SEO domains.
- **Use `run_slash_command` with command `web`** to verify live Google docs,
Schema.org, or legal sources before making compliance claims.
- **Reference paths use `~/.roo/skills/` prefix** — this is the standard Zoo Code
global skills directory. Always use `~/.roo/skills/forge-seo/references/<file>.md` when
calling `read_file`.
