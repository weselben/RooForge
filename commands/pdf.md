---
name: pdf
description: >
  PDF download via curl MCP. Download PDFs from URLs with URL validation
  and Content-Type verification. Used by ask mode for PDF acquisition.
---

# /pdf — PDF Download via Curl MCP

Single tool for downloading PDFs from URLs. Use `curl_download` to fetch → receive local path for downstream extraction.

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

## Workflow

1. Validate URL — must be `http(s)://*.pdf`
2. Verify Content-Type — `curl -I` check for `application/pdf`, `application/x-pdf`, or `application/octet-stream`
3. Download — `curl -sfL --max-time 30` to `.memory/pdf-{timestamp}-{sanitized_basename}.pdf`
4. Return local path for downstream extraction (e.g., PDF reader MCP)

## Important
Run `run_slash_command` ('pdf') once to load this context → use `curl_download` directly.
