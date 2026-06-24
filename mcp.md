<div align="center">

# 🔌 MCP Servers

**Model Context Protocol servers for the Forge pipeline**

[![SearXNG](https://img.shields.io/badge/SearXNG-Ask%20Mode-blue)](#searxng)
[![Curl Download](https://img.shields.io/badge/Curl%20Download-Ask%20Mode-green)](#curl-download-mcp)
[![PDF Reader](https://img.shields.io/badge/PDF%20Reader-Ask%20Mode-purple)](#pdf-reader-mcp)
[![Git MCP](https://img.shields.io/badge/Git%20MCP-Git%20Mode-orange)](#git-mcp-server)

*Privacy-respecting search · PDF download · PDF text extraction · Structured git access · MCP-first*

</div>

---

## Overview

The Forge pipeline requires three MCP servers for full functionality. Add the entire block below to your Zoo Code MCP settings using the MCP settings view (**Edit Global MCP**). If editing manually, use the global `mcp_settings.json` file for your Zoo Code extension ID (`ZooCodeOrganization.zoo-code`).

```json
{
  "mcpServers": {
    "searxng": {
      "command": "npx",
      "args": ["-y", "mcp-searxng"],
      "env": {
        "SEARXNG_URL": "http://localhost:8088/"
      },
      "alwaysAllow": ["web_url_read", "searxng_web_search"]
    },
    "curl-download": {
      "command": "sh",
      "args": ["-c", "exec ~/.roo/mcp/pdf-curl-server.sh"],
      "alwaysAllow": ["curl_download"]
    },
    "pdf-reader-mcp": {
      "command": "npx",
      "args": ["-y", "@sylphx/pdf-reader-mcp"],
      "alwaysAllow": ["read_pdf", "search_pdf", "inspect_pdf", "ocr_pages", "analyze_regions", "extract_regions", "render_page"]
    },
    "git-mcp-server": {
      "command": "npx",
      "args": ["-y", "@cyanheads/git-mcp-server"],
      "env": {
        "GIT_SIGN_COMMITS": "false"
      },
      "alwaysAllow": [
        "git_add",
        "git_blame",
        "git_branch",
        "git_changelog_analyze",
        "git_checkout",
        "git_cherry_pick",
        "git_clean",
        "git_clear_working_dir",
        "git_clone",
        "git_commit",
        "git_diff",
        "git_fetch",
        "git_init",
        "git_log",
        "git_merge",
        "git_pull",
        "git_rebase",
        "git_reflog",
        "git_remote",
        "git_reset",
        "git_set_working_dir",
        "git_show",
        "git_stash",
        "git_status",
        "git_tag",
        "git_worktree",
        "git_wrapup_instructions"
      ],
      "disabledTools": ["git_push"]
    }
  }
}
```

### Windows Alternative

On Windows, replace the `curl-download` entry in the config above with the PowerShell version:

```json
    "curl-download": {
      "command": "powershell",
      "args": [
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "C:\\Users\\%username%\\.roo\\mcp\\pdf-curl-server.ps1"
      ],
      "alwaysAllow": ["curl_download"]
    }
```

> Requires the [`pdf-curl-server.ps1`](mcp/pdf-curl-server.ps1) script to be copied to `~/.roo/mcp/`.

---

## SearXNG

**Required by:** Ask mode
**Purpose:** Web search & URL reading for intelligence gathering

Ask mode uses [SearXNG](https://github.com/searxng/searxng) — a privacy-respecting meta-search engine — for real-time web access. Two tools are exposed:

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `searxng_web_search` | Search the web via SearXNG | `query`, `pageno`, `time_range`, `language`, `safesearch` |
| `web_url_read` | Read full content from a URL | `url`, `startChar`, `maxLength`, `section`, `paragraphRange`, `readHeadings` |

### Setup

**Step 1:** Deploy SearXNG locally via Docker:

```bash
docker run -d \
  --name searxng \
  -p 8088:8088 \
  -e SEARXNG_BASE_URL=http://localhost:8088/ \
  -v searxng-data:/etc/searxng \
  searxng/searxng:latest
```

**Step 2:** The MCP config block above connects Zoo Code to your SearXNG instance. Update `SEARXNG_URL` if your instance runs on a different port or host.

**Step 3:** Restart Zoo Code → switch to Ask mode → ask a question requiring web search → confirm `searxng_web_search` appears.

<details>
<summary>📖 What does <code>alwaysAllow</code> do?</summary>

By default, Zoo Code asks for confirmation before each MCP tool call. Adding tool names to `alwaysAllow` skips confirmation. Recommended for `searxng_web_search` and `web_url_read` since Ask mode relies on frequent search/read cycles.
</details>

---

## Curl Download MCP

**Required by:** Ask mode
**Purpose:** Download PDFs from URLs via POSIX shell + curl

Ask mode uses the repo-owned `curl-download` MCP server for downloading PDFs from URLs. No `npx` or npm dependency — the server runs directly via `sh` with a POSIX shell script.

| Tool | Purpose | Key Parameters |
|------|---------|--------------|
| `curl_download` | Download PDF from URL to `.memory/` | `url` (string, required) |

### Setup

**Step 1:** Create the MCP directory and make the server script executable:

```bash
mkdir -p ~/.roo/mcp
chmod +x mcp/pdf-curl-server.sh
cp mcp/pdf-curl-server.sh ~/.roo/mcp/
```

**Step 2:** Ensure dependencies are installed. The script requires `curl` and either `jq` or `python3`:

```bash
# Check curl
curl --version

# Check jq (preferred)
jq --version

# Or check python3 (fallback)
python3 --version
```

**Step 3:** The MCP config block above connects Zoo Code to the curl-download server. Restart Zoo Code → switch to Ask mode → run `curl_download` → confirm PDF is downloaded to `.memory/`.

---

## PDF Reader MCP

**Required by:** Ask mode
**Purpose:** Extract and parse text from downloaded PDFs

Ask mode uses [`@sylphx/pdf-reader-mcp`](https://www.npmjs.com/package/@sylphx/pdf-reader-mcp) for reading and extracting structured text from PDF files after they have been downloaded by the `curl-download` server.

| Tool | Purpose | Key Parameters |
|------|---------|--------------|
| `read_pdf` | Extract full text or Markdown from a PDF | `sources`, `include_full_text`, `include_markdown`, `maxLength` |
| `search_pdf` | Search for specific terms within a PDF | `query`, `sources`, `case_sensitive`, `max_matches_per_source` |
| `inspect_pdf` | Get metadata and structure overview | `sources` |
| `ocr_pages` | OCR text from scanned/image pages | `sources`, `pages`, `language`, `include_ocr_text_layer` |
| `analyze_regions` | Analyze document layout regions | `sources`, `pages`, `region_types`, `include_image` |
| `extract_regions` | Extract specific regions from pages | `sources`, `pages`, `regions`, `include_image` |
| `render_page` | Render page as image or preview | `sources`, `pages`, `format`, `dpi`, `include_image` |

### Setup

The MCP config block above connects Zoo Code to the PDF reader server. No additional setup required — `npx` handles the installation automatically.

---

## Git MCP Server

**Required by:** Git mode
**Purpose:** Structured git operations with MCP-first, CLI fallback

Git mode uses [`@cyanheads/git-mcp-server`](https://github.com/cyanheads/git-mcp-server) for typed, validated git operations. When MCP fails or a tool doesn't exist, CLI is the fallback.

| Tool | Purpose |
|------|---------|
| `git_add` | Stage files for commit |
| `git_blame` | Line-by-line authorship info |
| `git_branch` | List, create, delete, rename branches |
| `git_changelog_analyze` | Changelog analysis with git history context |
| `git_checkout` | Switch branches or restore files |
| `git_cherry_pick` | Apply specific commits to current branch |
| `git_clean` | Remove untracked files |
| `git_clear_working_dir` | Clear session working directory |
| `git_clone` | Clone a remote repository |
| `git_commit` | Create commit with staged changes |
| `git_diff` | View differences between commits/branches/tree |
| `git_fetch` | Download objects/refs from remote |
| `git_init` | Initialize a new git repository |
| `git_log` | View commit history with filtering |
| `git_merge` | Merge branches together |
| `git_pull` | Fetch and integrate remote changes |
| `git_rebase` | Rebase commits onto another branch |
| `git_reflog` | View reference logs for recovery |
| `git_remote` | Manage remote repositories |
| `git_reset` | Reset HEAD to specified state |
| `git_set_working_dir` | Set session working directory |
| `git_show` | Show details of git objects |
| `git_stash` | Save, restore, or remove stashes |
| `git_status` | Show working tree status |
| `git_tag` | List, create, or delete tags |
| `git_worktree` | Manage multiple working trees |
| `git_wrapup_instructions` | Git wrap-up protocol for session acceptance |

### Disabled Tools

| Tool | Reason |
|------|--------|
| `git_push` | Safety: prevents accidental pushes. Push manually via CLI when ready. |

> `git_push` is in `disabledTools` and intentionally excluded from `alwaysAllow`. The pipeline commits locally — push is a destructive remote operation that should be explicitly confirmed by the user.

### Setup

The MCP config block above connects Zoo Code to the git-mcp-server. `GIT_SIGN_COMMITS` defaults to `false` — set to `true` if you want GPG-signed commits.

**Verify:** Restart Zoo Code → switch to Git mode → run `git_status` → confirm structured response.

<details>
<summary>📖 Why is <code>git_push</code> disabled?</summary>

The orchestration pipeline commits locally but does not auto-push. Push is destructive, public-facing operation. Git mode stages and commits all changes, then instructs the user to push manually. To enable, add `"git_push"` to `alwaysAllow` and remove from `disabledTools`.
</details>

---

## Impact on the Pipeline

| Mode | SearXNG | Curl Download MCP | PDF Reader MCP | Git MCP |
|------|---------|-------------------|----------------|---------|
| **Orchestrator** | Indirect (via Ask) | — | — | Indirect (via Git) |
| **Ask** | **Direct** | **Direct** | **Direct** | — |
| **Architect** | Indirect (via Ask) | — | — | — |
| **Subtask Orchestrator** | Indirect (via Ask) | — | — | Indirect (via Git) |
| **Code** | — | — | — | — |
| **Git** | — | — | — | **Direct** |

---

<div align="center">

*[⬆ Back to README](README.md)*

</div>
