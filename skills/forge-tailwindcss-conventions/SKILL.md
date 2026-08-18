---
name: forge-tailwindcss-conventions
description: "Load when the task involves Tailwind CSS — styling components, utility classes, className work, converting custom CSS to utilities, or Tailwind build/config issues. Covers v4 (CSS-first) and flags v3 differences."
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/forge-tailwindcss-conventions/SKILL.md
---

# Tailwind CSS Conventions

**Leading word: utility-first.** Check if a utility class exists before writing custom CSS. Custom CSS is the last resort.

Tailwind CSS v4 (released January 2025) is a **CSS-first, zero-config framework**. Key changes from v3: no `tailwind.config.js` required; configuration lives in CSS via `@theme`, `@utility`, and `@source` directives. The Oxide engine delivers sub-10ms builds with automatic tree-shaking and <10KB output. **Verify which version the project uses before applying conventions** — v3 used `tailwind.config.js`.

## Core architecture (v4)

Import `@import "tailwindcss";` in the main CSS file. Configuration lives in CSS:

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

- **`@theme`** — defines design tokens as CSS custom properties. `--color-purple-500` in `@theme` auto-generates `bg-purple-500`, `text-purple-500`, `border-purple-500`, etc. OKLCH by default.
- **`@source`** — controls which files Tailwind scans. `source(none)` disables auto-detection; add extra paths for libraries.

## Class ordering convention

Order classes consistently (layout → sizing → typography → color → effects → states → responsive → dark):

```jsx
<button className="flex items-center gap-2 px-4 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700 focus-visible:ring-2 focus-visible:ring-blue-400 dark:bg-blue-500 dark:hover:bg-blue-600">
```

1. Layout (`flex`, `grid`, `gap-*`, `items-center`)
2. Sizing (`w-*`, `h-*`, `px-*`, `py-*`)
3. Typography (`font-*`, `text-*`, `leading-*`)
4. Effects (`shadow-*`, `rounded-*`, `border`)
5. Colors (`bg-*`, `text-*`, `border-*`)
6. States (`hover:`, `focus:`, `active:`, `disabled:`)
7. Responsive (`md:`, `lg:`, `xl:`)
8. Dark mode (`dark:`)

**Tooling:** Prettier plugin (`prettier-plugin-tailwindcss`) auto-sorts. Mandatory.

## Framework-specific patterns

For React/Next.js (`cva`, `cn` helper, MUI coexistence, metadata), Vue/Nuxt 4 (module version, HMR, SSR hydration), and Svelte patterns, read [`references/frameworks.md`](references/frameworks.md). Load it when the project uses one of those frameworks.

## Tooling setup (mandatory)

| Tool | Purpose |
|------|---------|
| Tailwind IntelliSense | Autocomplete, hover tooltips, red underlines for misspelled utilities |
| Prettier Plugin (`prettier-plugin-tailwindcss`) | Auto-sorts class order |
| ESLint Plugin (`eslint-plugin-tailwindcss`) | Catches common errors |
| `cn` helper (`clsx` + `tailwind-merge`) | Resolves conflicting classes (`px-2` vs `px-4`) |

## Critical anti-patterns

| Anti-Pattern | Why It Fails | Fix |
|-------------|-------------|-----|
| `'bg-' + color + '-500'` | Compiler cannot see literal class → purges it | Pass complete strings or use `cva` map |
| `@apply` in CSS | v3 workaround; real components are better | Extract React/Vue/Svelte components |
| `!important` everywhere | Specificity arms race | Only for third-party inline styles, with TODO to remove |
| Inline styles for dynamic values | Breaks Tailwind's design system | Use CSS variables via `@theme` |
| Missing `width`/`height` on images | Causes CLS layout shifts | Always set dimensions or `aspect-ratio` |
| Not using `cn` helper | Conflicting classes merge unpredictably | Use `cn` from `clsx` + `tailwind-merge` |

## Framework-agnostic guidelines

1. **Utility-first** — check if a utility exists before writing custom CSS.
2. **Keep styles next to markup** — Tailwind's biggest advantage.
3. **Think in small pieces** — Button, Card, Nav: each is one component.
4. **Handle variations with props** — primary/secondary buttons = same component, different props.
5. **Mobile-first responsive** — base styles without prefix, override with `md:`, `lg:`.
6. **Design tokens via `@theme`** — colors, fonts, spacing in CSS, not JS. Single source of truth.
7. **Never concatenate class strings** — `'bg-' + color + '-500'` breaks the compiler.

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
