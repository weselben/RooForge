# forge-seo

SEO hub skill with two reference deep-dives: UX/UI SEO (design decisions that impact rankings) and Technical SEO (sitemaps, structured data, meta tags, rendering strategy). Router-style: read only the reference the task needs.

## When to load

- The task involves SEO — meta tags, sitemaps, structured data, rendering strategy.
- Core Web Vitals, mobile-first design, accessibility ranking, engagement metrics.
- Search ranking, E-E-A-T, keyword intent, AI search optimization, content optimization.

## How it works

**Leading word: hub.** The skill is a router, not a reference — it points at the right deep-dive file and stays out of the way.

**Two reference files** (both live beside SKILL.md under `references/`):

| Task context | Reference |
|-------------|-----------|
| Design, layout, styling, components, accessibility, responsive behavior | `references/uxui-seo.md` (Core Web Vitals, mobile-first, E-E-A-T, keyword intent, content optimization) |
| Sitemaps, robots.txt, canonical, JSON-LD, Open Graph, rendering strategy, crawlability | `references/technical-seo.md` (technical audit checklist) |
| Both (full page implementation with SEO) | Both, in order: UX/UI first, then Technical |

**Rules**:

- No rigid sequence — read the relevant reference, then decide which companion skills fit. Only `Skill(skill='forge-eu-accessibility')` is mandatory for UI/UX work.
- Do NOT read both references unless the task spans both domains.
- Verify live sources — use `WebSearch` / `FetchURL` on Google docs, Schema.org, or legal sources before making compliance claims.
- Paths are relative to SKILL.md — the references live under `references/` wherever the skill is installed.

## Files in this skill

- `skills/forge-seo/SKILL.md` — hub router: two reference pointers, how-to-choose table, rules
- `skills/forge-seo/references/uxui-seo.md` — UX/UI SEO deep-dive (235 lines)
- `skills/forge-seo/references/technical-seo.md` — Technical SEO deep-dive (251 lines)

## See also

- `Skill(skill='forge-eu-accessibility')` — mandatory companion for UI/UX work (accessibility ranking overlaps)
- `Skill(skill='frontend-design')` — visual design companion; design decisions impact SEO
- `Skill(skill='forge-tailwindcss-conventions')` — Tailwind implementation companion (Core Web Vitals, CLS)
- `Skill(skill='forge-docs')` — load before writing system-design notes that cite SEO choices

## Notes

- The skill was rewritten for Kimi Code CLI; it uses the harness's `WebSearch` / `FetchURL` tools and relative paths.
- The two reference files are unchanged except for the verification-tool substitution.
