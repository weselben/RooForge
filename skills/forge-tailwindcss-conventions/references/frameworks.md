# Framework-Specific Patterns

Disclosed reference for `Skill(skill='forge-tailwindcss-conventions')`. Load this when the project uses React/Next.js, Vue/Nuxt, or Svelte.

## React / Next.js

- **Extract components**: Button, Card, Nav — each is one component. Do NOT use `@apply` (v3 workaround).
- **Conditional variants**: Use `cva` (Class Variance Authority) or `cn` helper from `clsx` + `tailwind-merge`:

  ```jsx
  import { cn } from "@/lib/utils";
  <button className={cn("base-styles", isActive && "active-styles", className)}>
  ```

- **Never concatenate strings**: `'bg-' + color + '-500'` breaks the compiler. Pass complete strings or use `cva` map.
- **MUI coexistence**: Load `tailwind.css` after MUI baseline. Enable `cssVarEnabled: true` in MUI theme.
- **Next.js Metadata**: Use `generateMetadata` for Open Graph, Twitter cards, canonical URLs. Dynamic sitemaps via `app/sitemap.ts`.

## Vue / Nuxt 4

- **Component extraction**: Same pattern — extract into `.vue` components. Pass variant props instead of creating new files for each style.
- **Nuxt 4 specific**: Use `@nuxtjs/tailwindcss` module. Configuration in `nuxt.config.ts` under `tailwindcss` key. v4 CSS-first approach works with Nuxt 4's Nitro engine — add `@import "tailwindcss"` in `assets/css/tailwind.css`.
- **Nuxt 3 approach is STALE**: The old Nuxt 3 pattern (`tailwind.config.js`, v3 engine with `@tailwindcss/postcss`) is deprecated. Do not use `tailwind.config.js` in Nuxt 4 projects. Migrate to v4 CSS-first configuration.
- **Nuxt 4 pain points**:
  - Module resolution: Ensure `@nuxtjs/tailwindcss` is v6.13+ for v4 support. Earlier versions use v3 engine.
  - HMR issues: If styles don't update, restart dev server or clear `.nuxt/` cache.
  - Component auto-import: Tailwind classes in auto-imported components need explicit `@source` or manual scanning configuration.
  - SSR hydration: Ensure `dark:` class is set before hydration to avoid flash. Use `useHead` or `htmlAttrs` in `nuxt.config.ts`.
- **Dark mode**: Toggle `.dark` class on `<html>` — flips all tokens instantly without component re-renders. In Nuxt 4, use `useColorMode()` from `@vueuse/nuxt` for seamless integration.

## Svelte

- Extract into `.svelte` components. Pass variant props instead of creating new files for each style.
- Dark mode: toggle `.dark` class on `<html>` — flips all tokens instantly without component re-renders.
