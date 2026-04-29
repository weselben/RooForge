---
name: git
description: >
  Git operations. MCP-first with CLI fallback. Contains commit workflow,
  tool reference, conventional commit format, and CLI temp file pattern.
  Used by git mode.
---

# /git — Git Operations (MCP + CLI)

MCP-first for structured git ops. CLI fallback when MCP unavailable.

## Commit Workflow

1. `git_diff staged: true` — inspect staged changes. Mismatch with expected scope → return "Staging Mismatch" via `attempt_completion`.
2. `git_status` — verify working tree state.
3. `git_commit` — create commit with conventional message.

## MCP Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `git_add` | Stage files | `files`, `all`, `update` |
| `git_commit` | Create commit | `message`, `amend`, `filesToStage` |
| `git_diff` | View differences | `staged`, `stat`, `target`, `paths` |
| `git_status` | Working tree status | `includeUntracked` |
| `git_log` | Commit history | `maxCount`, `branch`, `filePath`, `oneline` |
| `git_branch` | Branch management | `operation`, `name`, `startPoint` |
| `git_push` | Push to remote | `remote`, `branch` |
| `git_tag` | Tag management | `mode`, `tagName`, `message` |

## CLI Fallback

When MCP tools fail or unavailable → use `execute_command` with git CLI.

### Temp File Pattern for Commits

Shell escaping of multi-line commit messages is fragile. Use temp file:

1. Write commit message to temp file:
   ```
   execute_command: printf '<commit_message>' > /tmp/forge-commit.txt
   ```
2. Commit using temp file:
   ```
   execute_command: git commit -F /tmp/forge-commit.txt
   ```
3. Delete temp file:
   ```
   execute_command: rm -f /tmp/forge-commit.txt
   ```

Always clean up temp file — even on failure.

### Common CLI Operations

| Operation | Command |
|-----------|---------|
| Stage files | `git add <files>` |
| Stage all modified | `git add -u` |
| View staged diff | `git diff --staged` |
| View status | `git status` |
| Commit from file | `git commit -F /tmp/forge-commit.txt` |
| View log | `git log --oneline -10` |
| Create branch | `git checkout -b <name>` |
| Push | `git push origin <branch>` |

## Conventional Commit Format

`<type>(<scope>): <subject>` — imperative mood, max 72 chars, no trailing period.

Body: WHAT changed + WHY. Footer: `BREAKING CHANGE:` if applicable.

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

## Branch Naming

`feat/<desc>`, `fix/<desc>`, `docs/<desc>`, `refactor/<desc>`, `chore/<desc>`. Lowercase, hyphen-separated. Never commit directly to `main` unless explicitly instructed.

## Rules

- MCP-first. MCP fails → CLI fallback.
- Never stage additional files silently.
- Always confirm which method succeeded (MCP or CLI).
- Always use temp file pattern for CLI commits — never `-m` with special characters.
- Always clean up `/tmp/forge-commit.txt` after commit.
- Never pipe user content into shell commands without sanitization.

## Important
Run `run_slash_command` ('git') at the start of each git task to load this context → use MCP git tools or CLI directly.
