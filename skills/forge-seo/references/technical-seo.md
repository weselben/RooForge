# Technical SEO Deep-Dive — Implementation Reference

## Overview

Technical SEO is the foundation: crawling → rendering → indexing → ranking. This reference covers XML sitemaps, `robots.txt`, canonical URLs, JSON-LD structured data, Open Graph/Twitter cards, Core Web Vitals optimization, and rendering strategy (SSG/SSR/ISR/CSR).

## Sitemaps

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2025-01-15</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

**Rules**:
- Max 50,000 URLs per sitemap file
- Max 50MB uncompressed per file
- Use sitemap index for large sites
- Submit via Google Search Console or `robots.txt`
- `lastmod` should be accurate — don't auto-update to today's date

**Dynamic Sitemap (Next.js App Router)**:
```typescript
// app/sitemap.ts
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const articles = await db.article.findMany({ select: { slug: true, updatedAt: true } });
  return articles.map(a => ({
    url: `https://example.com/articles/${a.slug}`,
    lastModified: a.updatedAt,
    changeFrequency: 'weekly',
    priority: 0.7,
  }));
}
```

## robots.txt

```
User-agent: *
Allow: /
Disallow: /api/
Disallow: /admin/

# Block specific crawlers
User-agent: GPTBot
Disallow: /

# Sitemap location
Sitemap: https://example.com/sitemap.xml
```

**Common mistakes**:
- Blocking CSS/JS (prevents rendering)
- Blocking images that should be indexed
- `Disallow: /` in production (blocks everything)
- Not testing with Google's robots.txt tester

## Canonical URLs

| Scenario | Canonical Should Point To |
|----------|---------------------------|
| http:// vs https:// | https:// version |
| www vs non-www | Chosen preferred version |
| URL parameters (?sort=price) | Base URL without parameters |
| Paginated content | Self-referencing or first page |
| Syndicated content | Original source |
| Trailing slash variations | Chosen preferred version |

```html
<link rel="canonical" href="https://example.com/products/widget" />
```

## Structured Data (JSON-LD)

**Essential types**:

| Type | Rich Result | Use Case |
|------|-------------|----------|
| Article | Article card with date/author | Blog posts, news |
| Product | Price, rating, availability | E-commerce |
| FAQPage | Expandable Q&A in SERP | FAQ sections |
| HowTo | Step-by-step with images | Tutorials |
| BreadcrumbList | Breadcrumb trail in SERP | Navigation |
| Organization | Knowledge panel | Company info |
| LocalBusiness | Map pack, hours | Physical locations |
| VideoObject | Video carousel | Video content |

**JSON-LD Example (Article)**:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Understanding React Server Components",
  "author": { "@type": "Person", "name": "Jane Developer" },
  "datePublished": "2025-01-10",
  "dateModified": "2025-01-12"
}
</script>
```

**Validation**: Google Rich Results Test, Schema.org Validator.

## Open Graph and Twitter Cards

```html
<!-- Open Graph -->
<meta property="og:title" content="Understanding React Server Components" />
<meta property="og:description" content="A deep dive into RSC architecture" />
<meta property="og:image" content="https://example.com/images/rsc-hero.jpg" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:url" content="https://example.com/blog/rsc" />
<meta property="og:type" content="article" />

<!-- Twitter Cards -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:site" content="@techblog" />
<meta name="twitter:title" content="Understanding React Server Components" />
<meta name="twitter:image" content="https://example.com/images/rsc-hero.jpg" />
```

| Platform | Minimum Size | Recommended | Aspect Ratio |
|----------|-------------|-------------|--------------|
| Open Graph | 200×200 | 1200×630 | 1.91:1 |
| Twitter summary_large_image | 300×157 | 1200×600 | 2:1 |

## Meta Tags Reference

```html
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Page Title — Site Name</title>
  <meta name="description" content="Concise page description (150-160 chars)" />
  <link rel="canonical" href="https://example.com/current-page" />
  <meta name="robots" content="index, follow" />
  <html lang="en">
  <link rel="alternate" hreflang="es" href="https://example.com/es/page" />
  <link rel="icon" href="/favicon.ico" sizes="32x32" />
</head>
```

## Core Web Vitals Optimization

**LCP Optimization**:
- Preload LCP image: `<link rel="preload" as="image" href="/hero.jpg" fetchpriority="high" />`
- Use responsive images with `srcset`
- Optimize server response time (TTFB < 800ms)
- Minimize render-blocking JS/CSS
- Use CDN for static assets
- **Do NOT lazy-load the LCP element**

**INP Optimization**:
- Break up long tasks (>50ms): use `scheduler.yield()` or `setTimeout(0)` between chunks
- Use Web Workers for heavy computation
- Debounce/throttle event handlers
- Minimize DOM size (target <1500 nodes)
- Avoid forced synchronous layouts

**CLS Optimization**:
- Always include `width` and `height` on images, or use `aspect-ratio` in CSS
- Reserve space with `min-height` for ad slots and dynamic content
- Preload fonts with `font-display: swap`
- Use transform/opacity animations instead of layout-shifting properties

## SSR vs SSG vs CSR for SEO

| Rendering | SEO Impact | Use Case | Crawlability |
|-----------|------------|----------|--------------|
| **SSG** | Best | Content that rarely changes | Excellent — HTML ready at crawl time |
| **SSR** | Great | Dynamic content, personalization | Good — HTML generated per request |
| **ISR** | Great | Frequently updated content | Good — static with periodic updates |
| **CSR** | Risky | Dashboards, authenticated apps | Poor — depends on JS execution |

## Technical SEO Audit Checklist

**Crawling & Indexing**:
- robots.txt not blocking important pages
- XML sitemap submitted and up to date
- No orphan pages (all important pages linked internally)
- Canonical tags on all pages
- HTTP → HTTPS redirect in place
- 404 page returns proper 404 status code

**Performance**:
- LCP ≤ 2.5s on mobile
- INP ≤ 200ms
- CLS ≤ 0.1
- TTFB < 800ms
- Images optimized (WebP/AVIF, responsive, lazy-loaded)
- CSS/JS minified and compressed (gzip/brotli)

**Content & Structure**:
- Unique `<title>` per page (50-60 characters)
- Unique `<meta description>` per page (150-160 characters)
- Proper heading hierarchy (single H1, logical H2-H6)
- Structured data (JSON-LD) on applicable pages
- Open Graph and Twitter meta tags
- Alt text on all meaningful images

**Mobile**:
- Mobile-responsive design
- Touch targets ≥ 48px
- No horizontal scrolling
- Readable font sizes (≥ 16px body text)

**Security**:
- HTTPS everywhere
- HSTS header set
- No mixed content warnings

## Monitoring Tools

| Tool | Purpose | Cost |
|------|---------|------|
| Google Search Console | Index coverage, CWV, mobile usability, rich results | Free |
| PageSpeed Insights | Lab + field performance data | Free |
| Chrome DevTools Lighthouse | Lab performance audit | Free |
| Schema.org Validator | Validate structured data | Free |
| Rich Results Test | Test Google rich result eligibility | Free |

## Verification

Before completing technical SEO work, confirm:
- [ ] Sitemap is valid XML, submitted to Search Console
- [ ] robots.txt doesn't block CSS/JS or important pages
- [ ] Canonical URLs consolidate all duplicate variations
- [ ] JSON-LD structured data validates in Rich Results Test
- [ ] Open Graph and Twitter meta tags present with correct image sizes
- [ ] Meta title and description unique per page (50-60 / 150-160 chars)
- [ ] LCP element is preloaded, not lazy-loaded
- [ ] Images have explicit dimensions or `aspect-ratio`
- [ ] HTTPS everywhere, HSTS header set
- [ ] Rendering strategy is SSG/SSR for SEO-critical pages

## Reference Files (Latest Docs)

Verify against these sources when rules change (use `run_slash_command` with command `web`):
- Google Search Central — Sitemaps: https://developers.google.com/search/docs/crawling-indexing/sitemaps/overview
- Google Search Central — robots.txt: https://developers.google.com/search/docs/crawling-indexing/robots/robots_txt
- Google Search Central — Canonical URLs: https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls
- Google Search Central — Structured Data: https://developers.google.com/search/docs/appearance/structured-data/intro
- Schema.org: https://schema.org/docs/schemas.html
- web.dev — Core Web Vitals: https://web.dev/vitals/
