---
name: pdf
description: >
  PDF download via curl-download MCP and text extraction via pdf-reader-mcp.
  Download PDFs from URLs, then read, search, or inspect them. Used by ask mode.
---

# /pdf — PDF Download + Read via curl-download and pdf-reader-mcp

Two-step workflow: use `curl_download` to fetch PDF → use `pdf-reader-mcp` tools to extract, search, or inspect.

## Download: `curl_download`

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `url` | `string` | ✅ | — | URL of the PDF to download. Must be HTTP(S) and end with `.pdf`. |

### Download Rules

- URL must be HTTP(S) and end with `.pdf`: `http://*.pdf` or `https://*.pdf`.
- Content-Type verified before download: accepted types are `application/pdf`, `application/x-pdf`, `application/octet-stream`.
- Downloaded file saved to `.memory/pdf-{timestamp}-{sanitized_basename}.pdf`.
- Basename sanitization: `sed 's/[^a-zA-Z0-9._-]/_/g'`.

### Error Handling

| Condition | Response | Code |
|-----------|----------|------|
| Invalid URL (not HTTP(S) or not `.pdf`) | JSON-RPC error | `-32602` |
| Non-PDF Content-Type | `isError: true` | — |
| Download failure | `isError: true` | — |

## Read/Extract: `read_pdf`

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `sources` | `array` | ✅ | — | Array of `{ path: string, url?: string }` objects. PDF path(s) to read. |
| `include_full_text` | `boolean` | ❌ | `false` | Extract full text from PDF. |
| `include_markdown` | `boolean` | ❌ | `false` | Extract PDF as Markdown. |
| `include_text_layer` | `boolean` | ❌ | `false` | Include text layer with run, line, word, character records. |
| `include_metadata` | `boolean` | ❌ | `false` | Include PDF metadata and info objects. |
| `include_outline` | `boolean` | ❌ | `false` | Include document outline/bookmark entries. |
| `include_annotations` | `boolean` | ❌ | `false` | Include page annotations (links, notes). |
| `include_tables` | `boolean` | ❌ | `false` | Detect and extract tables from PDF pages. |
| `include_images` | `boolean` | ❌ | `false` | Extract embedded images as base64. |
| `include_page_count` | `boolean` | ❌ | `false` | Include total number of pages. |
| `include_page_geometry` | `boolean` | ❌ | `false` | Include page viewport geometry. |
| `include_accessibility_report` | `boolean` | ❌ | `false` | Include accessibility report. |
| `include_trust_report` | `boolean` | ❌ | `false` | Include trust report for safety findings. |
| `include_layout_diagnostics` | `boolean` | ❌ | `false` | Include page layout profiles. |
| `include_semantic_hints` | `boolean` | ❌ | `false` | Include semantic hints on text elements. |
| `include_document_map` | `boolean` | ❌ | `false` | Include document map linking pages and elements. |
| `include_document_ast` | `boolean` | ❌ | `false` | Include semantic document AST. |
| `include_elements` | `boolean` | ❌ | `false` | Include structured document elements. |
| `include_chunks` | `boolean` | ❌ | `false` | Include citation-ready chunks. |
| `include_form_fields` | `boolean` | ❌ | `false` | Include PDF form field summaries. |
| `include_ocr_text_layer` | `boolean` | ❌ | `false` | Run OCR on sparse/scanned pages and include text layer. |
| `include_visual_enrichments` | `boolean` | ❌ | `false` | Fuse visual descriptions for tables, figures, charts. |
| `include_structure_tree` | `boolean` | ❌ | `false` | Include tagged PDF structure trees. |
| `include_safety_findings` | `boolean` | ❌ | `false` | Include safety findings (hidden/tiny/off-page text). |
| `include_html` | `boolean` | ❌ | `false` | Include simple HTML rendering of extracted pages. |
| `include_attachments` | `boolean` | ❌ | `false` | Include embedded attachment metadata. |
| `include_page_labels` | `boolean` | ❌ | `false` | Include PDF page labels. |
| `include_permissions` | `boolean` | ❌ | `false` | Include PDF permission and marking signals. |
| `maxLength` | `number` | ❌ | — | Max output characters to return (per page). |
| `sample_pages` | `number` | ❌ | `5` | Max pages to sample when auto-inspection enabled. |
| `max_visual_enrichments` | `number` | ❌ | — | Max visual regions per source. |
| `trust_report_redaction` | `string` | ❌ | `standard` | Redaction policy: `standard`, `strict`, `off`. |
| `auto` | `boolean` | ❌ | `true` | Auto-inspect each source and choose extraction options. |
| `auto_detail` | `string` | ❌ | `balanced` | Auto extraction depth: `fast`, `balanced`, `full`. |

### Read/Extract Rules

- Always pass downloaded PDF path as `sources` array with `path` field.
- Use `auto: true` (default) to let the server choose extraction options — good for first-pass analysis.
- Use explicit `include_*` flags when you need specific outputs (e.g., `include_markdown: true` for RAG, `include_full_text: true` for text extraction).
- Limit output with `maxLength` to avoid token overflow on large PDFs.
- `include_ocr_text_layer` is useful for scanned PDFs.

## Search: `search_pdf`

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | `string` | ✅ | — | Literal text query to search for in PDF text. |
| `sources` | `array` | ✅ | — | Array of `{ path: string, url?: string }` objects. |
| `case_sensitive` | `boolean` | ❌ | `false` | Case-sensitive literal matching. |
| `whole_word` | `boolean` | ❌ | `false` | Match only whole words using ASCII boundaries. |
| `max_matches_per_source` | `number` | ❌ | `50` | Max matches per source (capped at 500). |
| `max_pages` | `number` | ❌ | `100` | Max pages to search per source. |
| `context_chars` | `number` | ❌ | `120` | Context characters around each match. |
| `include_ocr_text_layer` | `boolean` | ❌ | `false` | Also search OCR text layer (renders pages). |

### Search Rules

- Use `search_pdf` after `read_pdf` to locate specific terms within a known PDF.
- `query` is literal text — not regex.
- Increase `context_chars` when you need more surrounding text per match.
- `include_ocr_text_layer` may be slow on large scanned PDFs.

## Inspect: `inspect_pdf`

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `sources` | `array` | ✅ | — | Array of `{ path: string, url?: string }` objects. |
| `include_metadata` | `boolean` | ❌ | `false` | Include PDF metadata. |
| `include_page_count` | `boolean` | ❌ | `false` | Include total page count. |
| `include_attachments` | `boolean` | ❌ | `false` | Include embedded attachment metadata. |
| `include_form_fields` | `boolean` | ❌ | `false` | Include AcroForm field summaries. |
| `include_permissions` | `boolean` | ❌ | `false` | Include permission and marking signals. |
| `include_page_labels` | `boolean` | ❌ | `false` | Include page labels. |
| `include_annotations` | `boolean` | ❌ | `false` | Include annotations. |
| `include_layout_diagnostics` | `boolean` | ❌ | `false` | Include layout diagnostics. |
| `include_safety_findings` | `boolean` | ❌ | `false` | Include safety findings. |
| `include_trust_report` | `boolean` | ❌ | `false` | Include trust report. |
| `include_accessibility_report` | `boolean` | ❌ | `false` | Include accessibility report. |
| `include_page_geometry` | `boolean` | ❌ | `false` | Include page geometry. |
| `maxLength` | `number` | ❌ | — | Max output characters. |
| `sample_pages` | `number` | ❌ | `5` | Max pages to sample for inspection. |

### Inspect Rules

- Use `inspect_pdf` for quick overview: page count, metadata, structure, safety findings.
- Good first step before deciding which `read_pdf` options to use.
- Fast — does not extract full text by default.

## Workflow

1. Validate URL — must be `http(s)://*.pdf`
2. Verify Content-Type — `curl -I` check for `application/pdf`, `application/x-pdf`, or `application/octet-stream`
3. Download — `curl -sfL --max-time 30` to `.memory/pdf-{timestamp}-{sanitized_basename}.pdf`
4. **Inspect** — `inspect_pdf` on downloaded file for metadata + page count
5. **Read/Search** — `read_pdf` for full extraction, or `search_pdf` for targeted term lookup
6. Return extracted content for analysis

## Important
Run `run_slash_command` ('pdf') once to load this context → use `curl_download` + `read_pdf` / `search_pdf` / `inspect_pdf` directly.
