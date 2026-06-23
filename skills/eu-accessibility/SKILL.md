---
name: eu-accessibility
description: >
  Framework-agnostic EU accessibility compliance skill. Covers BFSG (German
  Barrierefreiheitsstärkungsgesetz), EAA Directive 2019/882, BFSGV ordinance,
  and WCAG 2.1 Level AA via EN 301 549 V3.2.1. Provides legal scope checks,
  penalty awareness, and a practical framework-agnostic compliance checklist
  for web, mobile, and digital services. Instructs users to use /web for live
  legal source verification.
---

# EU Accessibility Compliance — BFSG / EAA / WCAG

## TL;DR

When building or auditing digital products/services for the EU market, verify:
1. **Scope** — Does the product/service fall under BFSG § 1 Abs. 2 (products) or § 1 Abs. 3 (services)?
2. **Baseline** — WCAG 2.1 Level AA via EN 301 549 V3.2.1 is the binding technical standard.
3. **Documentation** — Prepare an accessibility statement (BFSG Anlage 3) and keep assessments for 5 years.
4. **Penalties** — Up to €100,000 for serious violations (§ 37 BFSG).
5. **Verification** — Use `run_slash_command` with command `web` to check live legal sources before making compliance claims.

## When to Use This Skill

Load this skill when:
- Building or auditing websites, web apps, or mobile apps for EU consumers.
- Implementing e-commerce, banking, passenger transport, telecommunications, or e-book services.
- Reviewing UI/UX for accessibility compliance in a German or EU legal context.
- Writing accessibility statements, technical documentation, or conformity assessments.
- Determining whether a product or service falls within BFSG/EAA scope.

This skill is **framework-agnostic** — no React, Vue, Angular, or Svelte-specific guidance. Apply the principles to any stack.

## Applicability Scope

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

## Legal Framework Overview

| Law | Role | Key Reference |
|-----|------|---------------|
| **BFSG** | German national transposition of EAA; adds enforcement, penalties, market surveillance | § 1 (scope), § 3 (accessibility), § 37 (penalties), § 14 (service provider obligations) |
| **EAA Directive 2019/882** | EU directive harmonizing accessibility requirements across the internal market | Article 2 (scope), Article 4 (requirements), Article 13 (service obligations), Article 14 (disproportionate burden), Article 30 (penalties) |
| **BFSGV** | German ordinance specifying concrete technical requirements implementing Annex I of Directive 2019/882 | § 12 (general service requirements), § 4–6 (product requirements), § 20–21 (functional performance criteria) |
| **EN 301 549 V3.2.1** | Harmonized European standard for ICT accessibility; incorporates WCAG 2.1 Level AA | Presumption of conformity under § 4 BFSG / Article 15 EAA |
| **BGB** | General civil law underpinning contractual and tort liability for accessibility barriers | § 241 (duty of consideration), § 275 (disproportionate burden analog), § 307 (content control of T&Cs), § 823 (tort liability) |

## Penalties — § 37 BFSG

Administrative offenses (Ordnungswidrigkeiten) with fines:
- **Up to €100,000** for serious violations:
  - Placing non-compliant products on the market (§ 37 Abs. 1 Nr. 1).
  - Providing non-compliant services (§ 37 Abs. 1 Nr. 8).
  - Missing or incorrect CE marking (§ 37 Abs. 1 Nr. 9).
- **Up to €10,000** for other violations (missing/incorrect documentation, information, labeling under § 37 Abs. 1 Nr. 2–7, 10).

Market surveillance authorities may check services without cause, order corrective measures, and prohibit service operation if non-compliance persists (§ 28–31 BFSG).

## Technical Baseline — WCAG 2.1 Level AA via EN 301 549 V3.2.1

For websites, online applications, and mobile apps, BFSGV § 12 requires content to be:
- **Perceivable** — Information must be presentable in ways users can perceive.
- **Operable** — UI components and navigation must be operable.
- **Understandable** — Information and operation must be understandable.
- **Robust** — Content must work reliably with assistive technologies.

These are the four WCAG principles. Compliance with EN 301 549 V3.2.1 (which includes WCAG 2.1 Level AA) creates a **presumption of conformity** with BFSG/BFSGV. The BFSGV functional performance criteria (§ 21) also require usage without vision, with limited vision, without color perception, without hearing, with limited hearing, without vocal capability, with limited manipulation/strength, with limited reach, minimizing photosensitive seizure risk, with limited cognition, and privacy protection.

## Practical Compliance Checklist (Framework-Agnostic)

### A. Perceivable
- [ ] **Text alternatives:** All non-text content (images, icons, charts) has equivalent text alternatives (alt text, aria-label, or visible captions).
- [ ] **Multimedia captions:** Pre-recorded audio has captions; pre-recorded video has captions and audio description or text alternative.
- [ ] **Color independence:** Information is never conveyed by color alone; always supplemented with text, patterns, or icons.
- [ ] **Contrast:** Text and images of text have at least 4.5:1 contrast (3:1 for large text 18pt+ or 14pt+ bold). UI components and graphical objects have at least 3:1 against adjacent colors.
- [ ] **Text resizing:** Text resizes to 200% without loss of content or functionality; no horizontal scrolling at 1280px viewport width after reflow.
- [ ] **Text spacing:** No loss of content when user overrides spacing (line height 1.5, paragraph spacing 2x, letter spacing 0.12x, word spacing 0.16x).
- [ ] **Content on hover/focus:** Additional content appearing on hover or focus is dismissible, hoverable, and persistent.
- [ ] **Non-text contrast:** Active UI components, graphical objects, and focus indicators have sufficient contrast.

### B. Operable
- [ ] **Keyboard accessibility:** All functionality is operable via keyboard without specific timing for individual keystrokes.
- [ ] **No keyboard traps:** Keyboard focus can move into and out of every component using only the keyboard.
- [ ] **Timing adjustable:** Users are warned of time limits and can extend, adjust, or turn them off (extendable up to 10x default).
- [ ] **Flashing content:** Content does not flash more than 3 times per second (seizure threshold).
- [ ] **Navigation:** Pages have descriptive titles; navigation mechanisms are consistent across pages; multiple ways to find pages exist (search, sitemap, navigation); focus order is logical.
- [ ] **Focus visible:** Keyboard focus indicator is visible with sufficient contrast (minimum 3:1 against background and adjacent colors).
- [ ] **Pointer cancellation:** For single-pointer actions, at least one of: down-event not used, abort/undo available, up-reversal, or essential.
- [ ] **Label in name:** Visible labels match or are contained within the accessible name (so voice control users can refer to what they see).
- [ ] **Motion actuation:** Functionality using device motion can also be operated via UI components, and motion response can be disabled.
- [ ] **Target size:** Interactive targets are at least 24x24 CSS pixels (WCAG 2.2 best practice; adopt even under 2.1).

### C. Understandable
- [ ] **Language:** Default language of each page is programmatically determined; language changes within the page are marked.
- [ ] **Predictable:** Navigation and identification are consistent across pages (same components identified consistently, navigation in same relative order).
- [ ] **Error identification:** Input errors are automatically detected and described to the user in text.
- [ ] **Error suggestion:** Suggestions for correction are provided when known.
- [ ] **Error prevention:** For legal, financial, or data actions, users can review, correct, and confirm before final submission.
- [ ] **Labels and instructions:** Form inputs have visible labels and sufficient instructions.
- [ ] **Reading level:** Content is written as clearly and simply as possible. For banking services, not exceeding CEFR B2 per BFSGV § 17 Abs. 2.

### D. Robust
- [ ] **Valid markup:** Markup is valid according to specification (no unmatched tags, duplicate attributes, unique IDs).
- [ ] **Name, role, value:** For all UI components, name and role are programmatically determinable; states, properties, and values can be set by the user; changes are notified to assistive technologies.
- [ ] **Status messages:** Status messages are presented to assistive technologies without receiving focus (live regions or appropriate ARIA roles).
- [ ] **Assistive technology compatibility:** Interface works with screen readers, screen magnifiers, voice control, and switch devices. Test with at least one screen reader (NVDA, JAWS, VoiceOver).

### E. Documentation and Transparency (BFSG-specific)
- [ ] **Accessibility statement:** Published in an accessible format, explaining how the service meets requirements, with a description of the service, how requirements are met, and contact details of the responsible market surveillance authority (BFSG Anlage 3).
- [ ] **Accessibility statement location:** Clearly noticeable (e.g., in footer, alongside imprint and privacy policy, or in general terms and conditions).
- [ ] **Support services:** Help desks, call centers, and technical support provide accessibility and assistive-technology compatibility information in accessible communication modes.
- [ ] **No overlay plugins as sole solution:** Third-party accessibility overlay plugins or widgets are **not sufficient** to meet BFSG requirements. Native accessibility in design and code is required.
- [ ] **Document accessibility:** PDFs and documents provided as part of the service must be accessible (PDF/UA standard, tagged PDFs, alternative text for images).

### F. Testing and Verification
- [ ] **Automated testing:** Run automated tools (e.g., axe, Lighthouse, WAVE) and address all reported issues.
- [ ] **Manual testing:** Conduct keyboard-only navigation, screen reader testing, and zoom testing (200%).
- [ ] **User testing:** Include people with disabilities in usability testing where possible.
- [ ] **Conformance claim:** Document conformance level (WCAG 2.1 Level AA) and maintain an accessibility statement.

## Exceptions and Exemptions

### Fundamental Alteration (BFSG § 16 / EAA Article 14)
Accessibility requirements apply only to the extent that compliance does not require a fundamental alteration of the product or service's basic nature. The economic operator must assess and document this, keeping the assessment for 5 years.

### Disproportionate Burden (BFSG § 17 / EAA Article 14)
Requirements apply only to the extent that compliance does not impose a disproportionate burden. Assessment criteria are in BFSG Anlage 4 (ratio of net compliance costs to total costs/turnover, estimated benefits for persons with disabilities). Service providers must renew the assessment at least every 5 years, or when the service is altered or when requested by authorities. Operators receiving public or private funding for accessibility improvements cannot rely on this exemption.

## Live Legal Source Verification

**Always verify current legal texts before making compliance claims.** Laws and ordinances may be amended. Use `run_slash_command` with command `web` to retrieve the latest official sources.

### Key Official Sources
- **BFSG (German):** https://www.gesetze-im-internet.de/bfsg/BJNR297010021.html
- **BFSGV (German):** https://www.gesetze-im-internet.de/bfsgv/BJNR092800022.html
- **EAA Directive 2019/882 (EUR-Lex English):** https://eur-lex.europa.eu/eli/dir/2019/882/oj/eng
- **EAA Directive 2019/882 (EUR-Lex German):** https://eur-lex.europa.eu/eli/dir/2019/882/oj/deu
- **Bundesfachstelle für Barrierefreiheit:** https://www.bundesfachstelle-barrierefreiheit.de/
- **WCAG 2.1:** https://www.w3.org/TR/WCAG21/
- **EN 301 549 V3.2.1 (PDF):** https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf
- **BGB § 241, § 275, § 307, § 823:** https://www.gesetze-im-internet.de/bgb/

### How to Verify
Use `run_slash_command` with command `web` and provide a query like:
- `"BFSG § 37 Barrierefreiheitsstärkungsgesetz Bußgeld 2025"`
- `"EAA Directive 2019/882 Article 13 service provider obligations"`
- `"EN 301 549 V3.2.1 WCAG 2.1 Level AA"`

## Conventions

- **Framework-agnostic:** No framework-specific implementation guidance. Apply principles to HTML, CSS, JavaScript, or any UI framework.
- **No overlay plugins:** Never recommend accessibility overlay widgets as a compliance solution.
- **Document everything:** Accessibility statements, assessments, and conformity claims must be kept for the duration of the service plus 5 years for products.
- **Penalties are real:** Non-compliance can result in service prohibition orders and fines up to €100,000.
