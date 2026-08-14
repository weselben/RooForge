---
name: forge-seo
description: "Load when the task involves SEO — meta tags, sitemaps, structured data, rendering strategy, Core Web Vitals, search ranking, or content optimization."
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/forge-seo/SKILL.md
---

# SEO — UX/UI & Technical Deep-Dive Hub

**Leading word: hub.** This skill is a router, not a reference: it points at the right deep-dive file and stays out of the way. Read only the reference the task needs.

## Reference files

- [`references/uxui-seo.md`](references/uxui-seo.md) — UX/UI SEO: Core Web Vitals, mobile-first design, accessibility ranking, structured data for rich results, engagement metrics, E-E-A-T, keyword intent, AI search optimization, content optimization. Use for design, styling, component, layout, or accessibility tasks.
- [`references/technical-seo.md`](references/technical-seo.md) — Technical SEO: XML sitemaps, `robots.txt`, canonical URLs, JSON-LD structured data, Open Graph/Twitter cards, meta tags, SSR/SSG/CSR rendering strategy, technical audit checklist. Use for implementation tasks involving meta tags, sitemaps, structured data, rendering strategy, or crawlability.

## How to choose

| Task context | Read this reference |
|-------------|---------------------|
| Design, layout, styling, components, visual hierarchy, accessibility, responsive behavior | `references/uxui-seo.md` |
| Sitemap, robots.txt, canonical, meta tags, JSON-LD, Open Graph, rendering strategy, crawlability | `references/technical-seo.md` |
| Both (e.g., full page implementation with SEO) | Both, in order: UX/UI first, then Technical |

## Rules

- **No rigid sequence** — load this skill, read the relevant reference, then decide which companion skills fit the task. Only `forge-eu-accessibility` is mandatory for UI/UX work.
- **Do NOT read both references** unless the task explicitly spans both UX/UI and technical SEO domains.
- **Verify live sources** — use the harness's `WebSearch` / `FetchURL` tools to check Google docs, Schema.org, or legal sources before making compliance claims.
- **Paths are relative to this SKILL.md** — the references live beside it under `references/`, wherever the skill is installed.
