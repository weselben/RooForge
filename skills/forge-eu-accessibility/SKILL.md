---
name: forge-eu-accessibility
description: "Load when building or auditing digital products for the EU market — accessibility work, WCAG compliance, accessibility statements — or when the user mentions BFSG, EAA, EN 301 549, or EU accessibility law."
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/forge-eu-accessibility/SKILL.md
---

# EU Accessibility Compliance — BFSG / EAA / WCAG

**Leading word: presumption of conformity.** Compliance with EN 301 549 V3.2.1 (which includes WCAG 2.1 Level AA) creates a presumption of conformity with BFSG/BFSGV. That presumption is the target of every checklist item.

Framework-agnostic — no React, Vue, Angular, or Svelte-specific guidance. Apply the principles to any stack.

## TL;DR

1. **Scope** — Does the product/service fall under BFSG § 1 Abs. 2 (products) or § 1 Abs. 3 (services)?
2. **Baseline** — WCAG 2.1 Level AA via EN 301 549 V3.2.1 is the binding technical standard.
3. **Documentation** — Prepare an accessibility statement (BFSG Anlage 3) and keep assessments for 5 years.
4. **Penalties** — Up to €100,000 for serious violations (§ 37 BFSG).
5. **Verification** — Use the harness's `WebSearch` / `FetchURL` tools to check live legal sources before making compliance claims.

## Applicability scope

### BFSG § 1 Abs. 2 — Products (placed on market after 28 June 2025)

1. Consumer general-purpose computer hardware systems and operating systems.
2. Self-service terminals (payment, ATMs, ticketing, check-in, interactive info).
3. Consumer terminal equipment for electronic communications services.
4. Consumer terminal equipment for audiovisual media services.
5. E-book readers.

### BFSG § 1 Abs. 3 — Services (provided to consumers after 28 June 2025)

1. Electronic communications services (excluding machine-to-machine).
2. Passenger transport services (air, bus, rail, waterborne): websites, mobile apps, e-tickets, real-time travel info, interactive terminals.
3. Consumer banking services.
4. E-books and dedicated software.
5. E-commerce services (websites and mobile apps for consumer contracts).

### Exclusions

- Pre-recorded time-based media and office file formats published before 28 June 2025.
- Online maps (if essential navigational info is provided in an accessible digital manner).
- Third-party content not funded, developed, or controlled by the economic operator.
- Archive content (not updated or edited after 28 June 2025).
- **Microenterprises** (fewer than 10 persons, annual turnover/balance sheet ≤ €2 million) providing services are exempt from service requirements. Product requirements still apply if they place products on the market.

## Legal framework

| Law | Role | Key Reference |
|-----|------|---------------|
| **BFSG** | German national transposition of EAA; adds enforcement, penalties, market surveillance | § 1 (scope), § 3 (accessibility), § 37 (penalties), § 14 (service provider obligations) |
| **EAA Directive 2019/882** | EU directive harmonizing accessibility requirements across the internal market | Article 2 (scope), Article 4 (requirements), Article 13 (service obligations), Article 14 (disproportionate burden), Article 30 (penalties) |
| **BFSGV** | German ordinance specifying concrete technical requirements implementing Annex I of Directive 2019/882 | § 12 (general service requirements), § 4–6 (product requirements), § 20–21 (functional performance criteria) |
| **EN 301 549 V3.2.1** | Harmonized European standard for ICT accessibility; incorporates WCAG 2.1 Level AA | Presumption of conformity under § 4 BFSG / Article 15 EAA |
| **BGB** | General civil law underpinning contractual and tort liability for accessibility barriers | § 241 (duty of consideration), § 275 (disproportionate burden analog), § 307 (content control of T&Cs), § 823 (tort liability) |

## Penalties — § 37 BFSG

- **Up to €100,000** for serious violations: placing non-compliant products on the market, providing non-compliant services, missing or incorrect CE marking.
- **Up to €10,000** for other violations (missing/incorrect documentation, information, labeling).

Market surveillance authorities may check services without cause, order corrective measures, and prohibit service operation if non-compliance persists (§ 28–31 BFSG).

## Technical baseline — WCAG 2.1 Level AA via EN 301 549 V3.2.1

BFSGV § 12 requires content to be **Perceivable**, **Operable**, **Understandable**, **Robust** (the four WCAG principles). The BFSGV functional performance criteria (§ 21) also require usage without vision, with limited vision, without color perception, without hearing, with limited hearing, without vocal capability, with limited manipulation/strength, with limited reach, minimizing photosensitive seizure risk, with limited cognition, and privacy protection.

## Practical compliance checklist

The full framework-agnostic checklist — perceivable, operable, understandable, robust, documentation/transparency, testing — lives in [`references/compliance-checklist.md`](references/compliance-checklist.md). **Load it when auditing or building**; every item maps to the WCAG 2.1 AA baseline.

Key non-obvious items:

- **No overlay plugins as sole solution** — third-party accessibility overlay widgets are **not sufficient** to meet BFSG requirements. Native accessibility in design and code is required.
- **Accessibility statement** — published in an accessible format, clearly noticeable (footer, alongside imprint and privacy policy), per BFSG Anlage 3.
- **Document accessibility** — PDFs provided as part of the service must be accessible (PDF/UA, tagged PDFs, alt text).

## Exceptions and exemptions

### Fundamental alteration (BFSG § 16 / EAA Article 14)

Requirements apply only to the extent that compliance does not require a fundamental alteration of the product or service's basic nature. The economic operator must assess and document this, keeping the assessment for 5 years.

### Disproportionate burden (BFSG § 17 / EAA Article 14)

Requirements apply only to the extent that compliance does not impose a disproportionate burden. Assessment criteria are in BFSG Anlage 4. Service providers must renew the assessment at least every 5 years, or when the service is altered or requested by authorities. Operators receiving public or private funding for accessibility improvements cannot rely on this exemption.

## Live legal source verification

**Always verify current legal texts before making compliance claims.** Laws and ordinances may be amended. Use the harness's `WebSearch` tool for queries and `FetchURL` to read the official sources below.

### Key official sources

- **BFSG (German):** https://www.gesetze-im-internet.de/bfsg/BJNR297010021.html
- **BFSGV (German):** https://www.gesetze-im-internet.de/bfsgv/BJNR092800022.html
- **EAA Directive 2019/882 (EUR-Lex English):** https://eur-lex.europa.eu/eli/dir/2019/882/oj/eng
- **EAA Directive 2019/882 (EUR-Lex German):** https://eur-lex.europa.eu/eli/dir/2019/882/oj/deu
- **Bundesfachstelle für Barrierefreiheit:** https://www.bundesfachstelle-barrierefreiheit.de/
- **WCAG 2.1:** https://www.w3.org/TR/WCAG21/
- **EN 301 549 V3.2.1 (PDF):** https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf
- **BGB § 241, § 275, § 307, § 823:** https://www.gesetze-im-internet.de/bgb/

### Example verification queries

- `BFSG § 37 Barrierefreiheitsstärkungsgesetz Bußgeld 2025`
- `EAA Directive 2019/882 Article 13 service provider obligations`
- `EN 301 549 V3.2.1 WCAG 2.1 Level AA`

## Conventions

- **Framework-agnostic** — no framework-specific implementation guidance.
- **No overlay plugins** — never recommend accessibility overlay widgets as a compliance solution.
- **Document everything** — accessibility statements, assessments, and conformity claims must be kept for the duration of the service plus 5 years for products.
- **Penalties are real** — non-compliance can result in service prohibition orders and fines up to €100,000.
