---
name: forge-tailwindcss-conventions
description: >
  Tailwind CSS v4 coding conventions and best practices for JavaScript frameworks.
  Loaded by code mode when Tailwind work is detected via [UXUI] prefix or
  keywords like tailwind, utility-first, className, etc. Provides framework-
  agnostic guidance with framework-specific patterns for React, Vue, Svelte.
---

# Tailwind CSS Conventions

## Overview

Tailwind CSS v4 (released January 2025, current v4.3 as of May 2026) is a **CSS-first, zero-config framework**. Key changes from v3: no `tailwind.config.js` required, configuration lives in CSS via `@theme`, `@utility`, and `@source` directives. The Oxide engine delivers sub-10ms builds with automatic tree-shaking and <10KB output.

## When to Use This Skill

- Tailwind CSS work detected in task (keywords: tailwind, utility-first, className, CSS, styling, component, design)
- Component styling in React, Vue, Svelte, or vanilla JS projects
- Converting custom CSS to Tailwind utilities
- Optimizing Tailwind build performance

## Core Architecture (v4)

### No Config File Required
Import `@import "tailwindcss";` in your main CSS file. Configuration lives in CSS:

```css
@import "tailwindcss";

@theme {
  --color-brand: #0ea5e9;
  --font-sans: "Inter", sans-serif;
}

@utility clip-blob {
  clip-path: polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%);
}
```

### `@theme` Directive
Defines design tokens as CSS custom properties. `---color-purple-500` in `@theme` auto-generates `bg-purple-500`, `text-purple-500`, `border-purple-500`, etc. OKLCH by default for more vibrant, uniform colors.

### `@source` Directive
Controls which files Tailwind scans. `source(none)` disables auto-detection; add extra paths for libraries.

## Class Ordering Convention

Order classes consistently (layout → sizing → typography → color → effects → states → responsive → dark):

```jsx
<button className="flex items-center gap-2 px-4 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700 focus-visible:ring-2 focus-visible:ring-blue-400 dark:bg-blue-500 dark:hover:bg-blue-600">
```

**Order**:
1. Layout (`flex`, `grid`, `gap-*`, `items-center`)
2. Sizing (`w-*`, `h-*`, `px-*`, `py-*`)
3. Typography (`font-*`, `text-*`, `leading-*`)
4. Colors (`bg-*`, `text-*`, `border-*`)
5. Effects (`shadow-*`, `rounded-*`, `border`)
6. States (`hover:`, `focus:`, `active:`, `disabled:`)
7. Responsive (`md:`, `lg:`, `xl:`)
8. Dark mode (`dark:`)

**Tooling**: Prettier plugin (`prettier-plugin-tailwindcss`) auto-sorts. Considered mandatory.

## Framework-Specific Patterns

### React / Next.js
- **Extract components**: Button, Card, Nav — each is one component. Do NOT use `@apply` (v3 workaround).
- **Conditional variants**: Use `cva` (Class Variance Authority) or `cn` helper from `clsx` + `tailwind-merge`:
  ```jsx
  import { cn } from "@/lib/utils";
  <button className={cn("base-styles", isActive && "active-styles", className)}>
  ```
- **Never concatenate strings**: `'bg-' + color + '-500'` breaks the compiler. Pass complete strings or use `cva` map.
- **MUI coexistence**: Load `tailwind.css` after MUI baseline. Enable `cssVarEnabled: true` in MUI theme.
- **Next.js Metadata**: Use `generateMetadata` for Open Graph, Twitter cards, canonical URLs. Dynamic sitemaps via `app/sitemap.ts`.

### Vue / Nuxt 4
- **Component extraction**: Same pattern — extract into `.vue` components. Pass variant props instead of creating new files for each style.
- **Nuxt 4 specific**: Use `@nuxtjs/tailwindcss` module. Configuration in `nuxt.config.ts` under `tailwindcss` key. v4 CSS-first approach works with Nuxt 4's Nitro engine — add `@import "tailwindcss"` in `assets/css/tailwind.css`.
- **Nuxt 3 approach is STALE**: The old Nuxt 3 pattern (`tailwind.config.js`, v3 engine with `@tailwindcss/postcss`) is deprecated. Do not use `tailwind.config.js` in Nuxt 4 projects. Migrate to v4 CSS-first configuration.
- **Nuxt 4 pain points**:
  - Module resolution: Ensure `@nuxtjs/tailwindcss` is v6.13+ for v4 support. Earlier versions use v3 engine.
  - HMR issues: If styles don't update, restart dev server or clear `.nuxt/` cache.
  - Component auto-import: Tailwind classes in auto-imported components need explicit `@source` or manual scanning configuration.
  - SSR hydration: Ensure `dark:` class is set before hydration to avoid flash. Use `useHead` or `htmlAttrs` in `nuxt.config.ts`.
- **Dark mode**: Toggle `.dark` class on `<html>` — flips all tokens instantly without component re-renders. In Nuxt 4, use `useColorMode()` from `@vueuse/nuxt` for seamless integration.

### Svelte
- Extract into `.svelte` components. Pass variant props instead of creating new files for each style.
- Dark mode: toggle `.dark` class on `<html>` — flips all tokens instantly without component re-renders.

## Tooling Setup (Mandatory)

| Tool | Purpose | Why |
|------|---------|-----|
| Tailwind IntelliSense | Autocomplete, hover tooltips, red underlines for misspelled utilities | Mandatory — prevents errors |
| Prettier Plugin (`prettier-plugin-tailwindcss`) | Auto-sorts class order | Consistent ordering across team |
| ESLint Plugin (`eslint-plugin-tailwindcss`) | Catches common errors | Static analysis |
| `cn` helper (`clsx` + `tailwind-merge`) | Resolves conflicting classes (`px-2` vs `px-4`) | Conditional composition |

## Critical Anti-Patterns

| Anti-Pattern | Why It Fails | Fix |
|-------------|-------------|-----|
| `'bg-' + color + '-500'` | Compiler cannot see literal class → purges it | Pass complete strings or use `cva` map |
| `@apply` in CSS | v3 workaround; real components are better | Extract React/Vue/Svelte components |
| `!important` everywhere | Raises specificity arms race | Only for third-party inline styles, with TODO to remove |
| Inline styles for dynamic values | Breaks Tailwind's design system | Use CSS variables via `@theme` |
| Missing `width`/`height` on images | Causes CLS layout shifts | Always set dimensions or `aspect-ratio` |
| Not using `cn` helper | Conflicting classes merge unpredictably | Use `cn` from `clsx` + `tailwind-merge` |

## Framework-Agnostic Guidelines

1. **Utility-first**: Check if a utility class exists before writing custom CSS. Custom CSS = last resort.
2. **Keep styles next to markup**: Tailwind's biggest advantage. Don't move styles to separate files unless absolutely necessary.
3. **Think in small pieces**: Button, Card, Nav — each is one component. Small focused components are easier to test, fix, and understand.
4. **Handle variations with props**: Primary/secondary buttons = same component, different props. Same for card sizes.
5. **Mobile-first responsive**: Base styles without prefix, override with `md:`, `lg:`, etc.
6. **Design tokens via `@theme`**: Define colors, fonts, spacing in CSS, not in JS. Single source of truth.
7. **Check Tailwind version**: v4 is CSS-first; v3 used `tailwind.config.js`. Verify which version the project uses before applying conventions.

## Verification

Before completing Tailwind work, confirm:
- [ ] Classes follow the ordering convention (or are Prettier-sorted)
- [ ] No string concatenation for class names
- [ ] Components are extracted, not `@apply` in CSS
- [ ] `cn` helper used for conditional classes
- [ ] Images have explicit dimensions or `aspect-ratio`
- [ ] Design tokens defined via `@theme` (v4) or config (v3)
- [ ] No custom CSS unless no utility exists
- [ ] Dark mode uses `dark:` variant, not separate stylesheets
