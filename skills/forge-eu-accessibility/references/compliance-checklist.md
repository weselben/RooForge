# Practical Compliance Checklist — Framework-Agnostic

Disclosed reference for `forge-eu-accessibility`. Load when auditing or building for EU accessibility compliance. Every item maps to WCAG 2.1 Level AA via EN 301 549 V3.2.1.

## A. Perceivable

- [ ] **Text alternatives:** All non-text content (images, icons, charts) has equivalent text alternatives (alt text, aria-label, or visible captions).
- [ ] **Multimedia captions:** Pre-recorded audio has captions; pre-recorded video has captions and audio description or text alternative.
- [ ] **Color independence:** Information is never conveyed by color alone; always supplemented with text, patterns, or icons.
- [ ] **Contrast:** Text and images of text have at least 4.5:1 contrast (3:1 for large text 18pt+ or 14pt+ bold). UI components and graphical objects have at least 3:1 against adjacent colors.
- [ ] **Text resizing:** Text resizes to 200% without loss of content or functionality; no horizontal scrolling at 1280px viewport width after reflow.
- [ ] **Text spacing:** No loss of content when user overrides spacing (line height 1.5, paragraph spacing 2x, letter spacing 0.12x, word spacing 0.16x).
- [ ] **Content on hover/focus:** Additional content appearing on hover or focus is dismissible, hoverable, and persistent.
- [ ] **Non-text contrast:** Active UI components, graphical objects, and focus indicators have sufficient contrast.

## B. Operable

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

## C. Understandable

- [ ] **Language:** Default language of each page is programmatically determined; language changes within the page are marked.
- [ ] **Predictable:** Navigation and identification are consistent across pages (same components identified consistently, navigation in same relative order).
- [ ] **Error identification:** Input errors are automatically detected and described to the user in text.
- [ ] **Error suggestion:** Suggestions for correction are provided when known.
- [ ] **Error prevention:** For legal, financial, or data actions, users can review, correct, and confirm before final submission.
- [ ] **Labels and instructions:** Form inputs have visible labels and sufficient instructions.
- [ ] **Reading level:** Content is written as clearly and simply as possible. For banking services, not exceeding CEFR B2 per BFSGV § 17 Abs. 2.

## D. Robust

- [ ] **Valid markup:** Markup is valid according to specification (no unmatched tags, duplicate attributes, unique IDs).
- [ ] **Name, role, value:** For all UI components, name and role are programmatically determinable; states, properties, and values can be set by the user; changes are notified to assistive technologies.
- [ ] **Status messages:** Status messages are presented to assistive technologies without receiving focus (live regions or appropriate ARIA roles).
- [ ] **Assistive technology compatibility:** Interface works with screen readers, screen magnifiers, voice control, and switch devices. Test with at least one screen reader (NVDA, JAWS, VoiceOver).

## E. Documentation and Transparency (BFSG-specific)

- [ ] **Accessibility statement:** Published in an accessible format, explaining how the service meets requirements, with a description of the service, how requirements are met, and contact details of the responsible market surveillance authority (BFSG Anlage 3).
- [ ] **Accessibility statement location:** Clearly noticeable (e.g., in footer, alongside imprint and privacy policy, or in general terms and conditions).
- [ ] **Support services:** Help desks, call centers, and technical support provide accessibility and assistive-technology compatibility information in accessible communication modes.
- [ ] **No overlay plugins as sole solution:** Third-party accessibility overlay plugins or widgets are **not sufficient** to meet BFSG requirements. Native accessibility in design and code is required.
- [ ] **Document accessibility:** PDFs and documents provided as part of the service must be accessible (PDF/UA standard, tagged PDFs, alternative text for images).

## F. Testing and Verification

- [ ] **Automated testing:** Run automated tools (e.g., axe, Lighthouse, WAVE) and address all reported issues.
- [ ] **Manual testing:** Conduct keyboard-only navigation, screen reader testing, and zoom testing (200%).
- [ ] **User testing:** Include people with disabilities in usability testing where possible.
- [ ] **Conformance claim:** Document conformance level (WCAG 2.1 Level AA) and maintain an accessibility statement.
