<div align="center">

# 🔌 MCP Servers

**Model Context Protocol servers for the Kimi Code CLI**

[![SearXNG](https://img.shields.io/badge/SearXNG-Web%20Search-blue)](#searxng)
[![Curl Download](https://img.shields.io/badge/Curl%20Download-PDF%20Fetch-green)](#curl-download-mcp)
[![PDF Reader](https://img.shields.io/badge/PDF%20Reader-Text%20Extraction-purple)](#pdf-reader-mcp)
[![Git MCP](https://img.shields.io/badge/Git%20MCP-Structured%20Git-orange)](#git-mcp-server)

*Privacy-respecting search · PDF download · PDF text extraction · Structured git access · MCP-first*

</div>

---

## Overview

The Kimi Code CLI uses MCP servers defined in `mcp.json`. Add the entire block below to `~/.kimi-code/mcp.json` (user level) or `.kimi-code/mcp.json` (project level), or run `/mcp-config` in the TUI. Project entries override user entries on name clash; run `/mcp` to view connection status.

```json
{
  "mcpServers": {
    "searxng": {
      "command": "npx",
      "args": ["-y", "mcp-searxng"],
      "env": {
        "SEARXNG_URL": "http://localhost:8088/"
      },
      "enabledTools": ["web_url_read", "searxng_web_search"]
    },
    "curl-download": {
      "command": "sh",
      "args": ["-c", "exec ~/.kimi-code/mcp/pdf-curl-server.sh"],
      "enabledTools": ["curl_download"]
    },
    "pdf-reader-mcp": {
      "command": "npx",
      "args": ["-y", "@sylphx/pdf-reader-mcp"],
      "enabledTools": ["read_pdf", "search_pdf", "inspect_pdf", "ocr_pages", "analyze_regions", "extract_regions", "render_page"]
    },
    "git-mcp-server": {
      "command": "npx",
      "args": ["-y", "@cyanheads/git-mcp-server"],
      "env": {
        "GIT_SIGN_COMMITS": "false"
      },
      "enabledTools": [
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
      "-File", "C:\\Users\\<your-username>\\.kimi-code\\mcp\\pdf-curl-server.ps1"
    ],
    "enabledTools": ["curl_download"]
  }
```
*Replace <your-username> with your Windows username.*

> Requires the [`pdf-curl-server.ps1`](mcp/pdf-curl-server.ps1) script to be copied to `~/.kimi-code/mcp/`.

---

## SearXNG

**Used by:** Research workflows (e.g. the deep-research skill) when the harness has no built-in web search / PDF tooling
**Purpose:** Web search & URL reading for intelligence gathering

The agent uses [SearXNG](https://github.com/searxng/searxng) — a privacy-respecting meta-search engine — for real-time web access. Two tools are exposed:

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

**Step 2:** The MCP config block above connects the CLI to your SearXNG instance. Update `SEARXNG_URL` if your instance runs on a different port or host.

**Step 3:** Restart Kimi Code CLI (new session), run `/mcp` to confirm the server connected, then invoke the tool (e.g. `mcp__searxng__searxng_web_search`) in a session.

<details>
<summary>📖 What do <code>enabledTools</code> / <code>disabledTools</code> do?</summary>

MCP server entries accept two optional allow/block lists:

- `enabledTools` — if set, only the listed tools are exposed to the harness. Tools not in the list are hidden.
- `disabledTools` — if set, the listed tools are hidden while every other tool is exposed.

These lists control which tools the server exposes to the agent; tools not listed are not visible. The lists above are recommended for `searxng_web_search` and `web_url_read` because research flows rely on frequent search/read cycles.
</details>

### When to use

- Real-time web search during research flows that need information beyond the model's training cutoff.
- Reading the full body of a URL referenced in a search result.

---

## Curl Download MCP

**Used by:** Research workflows (e.g. the deep-research skill) when the harness has no built-in web search / PDF tooling
**Purpose:** Download PDFs from URLs via POSIX shell + curl

The agent uses the repo-owned `curl-download` MCP server for downloading PDFs from URLs. No `npx` or npm dependency — the server runs directly via `sh` with a POSIX shell script.

| Tool | Purpose | Key Parameters |
|------|---------|--------------|
| `curl_download` | Download PDF from URL (output dir: `PDF_CURL_OUTPUT_DIR` env, default current directory) | `url` (string, required) |

### Setup

**Step 1:** Create the MCP directory and make the server script executable:

```bash
mkdir -p ~/.kimi-code/mcp
chmod +x mcp/pdf-curl-server.sh
cp mcp/pdf-curl-server.sh ~/.kimi-code/mcp/
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

**Step 3:** The MCP config block above connects the CLI to the curl-download server. Restart Kimi Code CLI (new session), run `/mcp` to confirm the server connected, then invoke `mcp__curl-download__curl_download` in a session.

### When to use

- Pulling a PDF from a URL so `pdf-reader-mcp` can extract its text.
- Saving a remote document locally for offline reference without leaving the TUI.

---

## PDF Reader MCP

**Used by:** Research workflows (e.g. the deep-research skill) when the harness has no built-in web search / PDF tooling
**Purpose:** Extract and parse text from downloaded PDFs

The agent uses [`@sylphx/pdf-reader-mcp`](https://www.npmjs.com/package/@sylphx/pdf-reader-mcp) for reading and extracting structured text from PDF files after they have been downloaded by the `curl-download` server.

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

The MCP config block above connects the CLI to the PDF reader server. No additional setup required — `npx` handles the installation automatically. Restart Kimi Code CLI (new session) and run `/mcp` to confirm the server connected before invoking any of its tools.

### When to use

- Pulling quotes or citations from a PDF that `curl-download` has already saved locally.
- Inspecting the structure of a PDF before deciding which pages or regions to extract.

---

## Git MCP Server

**Used by:** Git-heavy flows when typed git tools are preferred over the CLI
**Purpose:** Structured git operations with MCP-first, CLI fallback

The agent uses [`@cyanheads/git-mcp-server`](https://github.com/cyanheads/git-mcp-server) for typed, validated git operations. When MCP fails or a tool doesn't exist, CLI is the fallback.

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
| `git_rebase` | Rebase commits onto another base |
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

> `git_push` is listed in `disabledTools` and intentionally not in `enabledTools`. Local commits are encouraged; push is a destructive remote operation that should be explicitly confirmed by the user.

### Setup

The MCP config block above connects the CLI to the git-mcp-server. `GIT_SIGN_COMMITS` defaults to `false` — set to `true` if you want GPG-signed commits.

**Verify:** Restart Kimi Code CLI (new session), run `/mcp` to confirm the server connected, then invoke `mcp__git-mcp-server__git_status` in a session.

<details>
<summary>📖 Why is <code>git_push</code> disabled?</summary>

The orchestration flow commits locally but does not auto-push. Push is a destructive, public-facing operation. The agent stages and commits all changes, then instructs the user to push manually. To enable, add `"git_push"` to `enabledTools` and remove it from `disabledTools`.
</details>

### When to use

- Long-running flows that need validated, typed git operations rather than raw shell commands.
- Branch and worktree juggling (create, switch, list) without the agent having to assemble CLI invocations.
- Generating a changelog or session wrap-up from recent history.

---

<div align="center">

*[⬆ Back to README](README.md)*

</div>
