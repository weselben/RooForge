# forge-eu-accessibility

EU accessibility compliance — BFSG (German transposition of EAA Directive 2019/882), BFSGV ordinance, and WCAG 2.1 Level AA via EN 301 549 V3.2.1. Framework-agnostic.

## When to load

- Building or auditing websites, web apps, or mobile apps for EU consumers.
- E-commerce, banking, passenger transport, telecommunications, or e-book services.
- The user mentions BFSG, EAA, EN 301 549, WCAG compliance, accessibility statements, or EU accessibility law.

## How it works

**Leading word: presumption of conformity.** Compliance with EN 301 549 V3.2.1 (which includes WCAG 2.1 Level AA) creates a presumption of conformity with BFSG/BFSGV.

**Scope check** — BFSG § 1 Abs. 2 (products: hardware, terminals, e-readers) vs § 1 Abs. 3 (services: comms, transport, banking, e-books, e-commerce). Microenterprises (< 10 persons, ≤ €2M turnover) are exempt from service requirements.

**Penalties** — up to €100,000 for serious violations (§ 37 BFSG); up to €10,000 for documentation/labeling issues. Market surveillance can prohibit service operation.

**Technical baseline** — WCAG 2.1 Level AA via EN 301 549 V3.2.1. Four principles: Perceivable, Operable, Understandable, Robust.

**Compliance checklist** — the full framework-agnostic checklist (A–F: perceivable, operable, understandable, robust, documentation, testing) lives in `references/compliance-checklist.md`. Load it when auditing or building.

**Key non-obvious rules**:
- No overlay plugins as sole solution — native accessibility is required.
- Accessibility statement required (BFSG Anlage 3), clearly noticeable.
- PDFs must be accessible (PDF/UA).

**Exceptions** — fundamental alteration (BFSG § 16) and disproportionate burden (BFSG § 17, Anlage 4 criteria, renewed every 5 years).

**Live verification** — always verify against current legal texts before making compliance claims. Use `WebSearch` / `FetchURL` on the official sources listed in SKILL.md.

## Files in this skill

- `skills/forge-eu-accessibility/SKILL.md` — TL;DR, applicability scope, legal framework, penalties, exceptions, live verification sources
- `skills/forge-eu-accessibility/references/compliance-checklist.md` — disclosed reference: the practical checklist sections A–F

## See also

- `frontend-design` — visual design companion; a11y is structural
- `forge-seo` — accessibility ranking factors overlap
- `forge-tailwindcss-conventions` — Tailwind implementation companion
- `forge-docs` — load before writing compliance docs or accessibility statements

## Notes

- The skill was rewritten for Kimi Code CLI; verification uses the harness's native `WebSearch` / `FetchURL` tools.
- Framework-agnostic by design — no React/Vue/Angular/Svelte specifics.
