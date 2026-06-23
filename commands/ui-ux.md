---
name: ui-ux
description: >
  UI/UX skill autoload command for code mode. Loads design and accessibility
  skills when code mode detects UI/UX work. Run before implementing any
  design, styling, component, or accessibility task.
---

# /ui-ux — UI/UX Design & Accessibility Skill Loader

**Mandatory skill autoload sequence** (load in order — do NOT skip):

1. Load any design-related skills first (e.g., via `skill` tool) to set creative direction
2. `skill` tool with name `eu-accessibility` → EU legal compliance (BFSG, EAA, WCAG), framework-agnostic checklist. When loaded should automatically be seen as **MANDATORY**

Always load `eu-accessibility` as the last skill to apply legal and technical guardrails on top of the design direction. This is non-negotiable.

## Triggering This Command

Run this command when UI/UX work is detected in your task:
- `[UXUI]` prefix in the Objective
- Keywords: design, styling, theme, visual, layout, component, accessibility, WCAG, responsive, animation, motion, hover, transition, color, typography, spacing, token, breakpoint, ARIA, contrast, screen reader

## What to Apply After Loading

- **Framework-agnostic:** Use CSS, HTML, and vanilla JS as the baseline. Never provide React, Vue, Angular, or Svelte-specific guidance unless explicitly asked.
- **Quality floor:** Every UI/UX output must include responsive behavior, visible keyboard focus, and `prefers-reduced-motion` respect even when not explicitly requested.
- **Anti-generic enforcement:** Reject default "AI slop" aesthetics (Inter + Roboto + purple gradients + card grids) unless the user explicitly requests them.
- **Accessibility compliance:** Apply WCAG 2.1 AA, BFSG, and EAA guardrails from eu-accessibility skill.
- **MCP-first for research:** Use `run_slash_command` with command `web` to verify live legal sources (BFSG, EAA) before making compliance claims.

## Rules

- **Skill order matters:** After loading any design-related skills, always load `eu-accessibility` as the last skill to apply legal and technical guardrails to the design direction.
- **Never skip accessibility:** `eu-accessibility` is mandatory for every `/ui-ux` invocation. No exceptions.
- **Do NOT load design or accessibility skills when the task does not involve UI/UX work:** Only invoke this command when the task actually involves design, styling, accessibility, or visual work.

## Important

Run `run_slash_command` with command `ui-ux` when UI/UX work is detected. Load skills. Then implement directly following the loaded skill guidance.
