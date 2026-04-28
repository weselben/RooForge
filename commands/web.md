---
name: web
description: >
  Web intel tools via SearXNG MCP. Search the web and read URL content.
  Contains tool parameters + usage rules for both searxng_web_search and
  web_url_read. Used by ask mode.
---

# /web — Web Search + URL Reader

Two tools for web intel gathering. Use `searxng_web_search` to find → `web_url_read` to read.

## Search: `searxng_web_search`

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | `string` | ✅ | — | Search query. Be specific. |
| `pageno` | `number` | ❌ | `1` | Page number for pagination. |
| `time_range` | `"day"` \| `"month"` \| `"year"` | ❌ | — | Filter by recency. |
| `language` | `string` | ❌ | `"all"` | Language code (e.g. `en`, `de`). |
| `safesearch` | `0` \| `1` \| `2` | ❌ | `0` | 0=None, 1=Moderate, 2=Strict. |

### Search Rules

- Be specific: `"Express.js v4 routing API parameters"` not `"Express docs"`.
- Do NOT revisit same query on same page.
- Insufficient results → refine query or advance `pageno`.

## Read: `web_url_read`

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `url` | `string` | ✅ | — | URL to read. |
| `startChar` | `number` | ❌ | `0` | Starting character offset. |
| `maxLength` | `number` | ❌ | — | Max characters to return (min 20000). |
| `section` | `string` | ❌ | — | Extract under specific heading. |
| `paragraphRange` | `string` | ❌ | — | Paragraph ranges: `"1-5"`, `"3"`, `"10-"`. |
| `readHeadings` | `boolean` | ❌ | — | Return only headings, not full content. |

### Read Rules

- Do NOT revisit URL already read in this task — check context first.
- Use `readHeadings: true` first to scan structure → then `section` or `paragraphRange` to extract relevant parts.
- Use `maxLength` to limit output — avoid pulling entire pages when only section needed.
- URL fails → skip it, try next search result.

## Workflow

1. Search with `searxng_web_search` using specific query
2. Scan results → identify most relevant URLs
3. Read with `web_url_read` — start with `readHeadings` to scan, then extract relevant sections
4. If insufficient → refine query + repeat

## Important
Run `run_slash_command` ('web') once to load this context → use `searxng_web_search` + `web_url_read` directly.
