# forge-tailwindcss-conventions

Tailwind CSS v4 coding conventions for JavaScript frameworks. Framework-agnostic core with framework-specific patterns disclosed to a reference file.

## When to load

- The task involves Tailwind CSS — styling components, utility classes, `className` work.
- Converting custom CSS to Tailwind utilities.
- Tailwind build or configuration issues.
- Optimizing Tailwind build performance.

## How it works

**Leading word: utility-first.** Check if a utility class exists before writing custom CSS. Custom CSS is the last resort.

Tailwind v4 (released January 2025) is CSS-first and zero-config: no `tailwind.config.js`; configuration lives in CSS via `@theme`, `@utility`, `@source`. **Verify the project's Tailwind version first** — v3 used `tailwind.config.js`.

**Core architecture (v4)**:

```css
@import "tailwindcss";

@theme {
  --color-brand: #0ea5e9;
}
```

- `@theme` defines design tokens as CSS custom properties; `--color-purple-500` auto-generates `bg-purple-500`, `text-purple-500`, etc.
- `@source` controls which files Tailwind scans.

**Class ordering convention** (layout → sizing → typography → color → effects → states → responsive → dark):

```jsx
<button className="flex items-center gap-2 px-4 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700 focus-visible:ring-2 dark:bg-blue-500">
```

`prettier-plugin-tailwindcss` auto-sorts — mandatory tooling.

**Framework-specific patterns** — React/Next (`cva`, `cn` helper, MUI coexistence), Vue/Nuxt 4 (module version, HMR, SSR hydration), Svelte — live in `references/frameworks.md`. Load it when the project uses one of those.

## Critical anti-patterns

- String concatenation (`'bg-' + color + '-500'`) → compiler purges; use complete strings or `cva` map
- `@apply` in CSS → v3 workaround; extract real components
- `!important` everywhere → specificity arms race
- Inline styles for dynamic values → use CSS variables via `@theme`
- Missing `width`/`height` on images → CLS layout shifts

## Files in this skill

- `skills/forge-tailwindcss-conventions/SKILL.md` — core: overview, v4 architecture, ordering, tooling, anti-patterns, framework-agnostic rules, verification checklist
- `skills/forge-tailwindcss-conventions/references/frameworks.md` — disclosed reference: React/Next, Vue/Nuxt 4, Svelte patterns

## See also

- `frontend-design` — load when the work is visual design, not just Tailwind implementation
- `forge-eu-accessibility` — mandatory companion for UI work
- `forge-docs` — load before writing system-design notes that cite Tailwind conventions

## Notes

- The skill was rewritten for Kimi Code CLI; the trigger lives in the description frontmatter only.
