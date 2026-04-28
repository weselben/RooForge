---
name: memory
description: >
  Phase-based memory persistence. One file per phase in .memory/,
  blocker files for blockers, general memory.md fallback. Direct edit
  by the current agent. All modes have .memory/ write permissions.
---

# /memory — Phase-Based Memory Persistence

## Memory File Structure

### Phase Files (one per phase)
```
.memory/phase-{N}-{short-name}.md
```
Example: `.memory/phase-1-mvp-foundation.md`

Each phase file accumulates ALL memory for that phase:
- Architecture decisions + rationale
- Technology selections + why alternatives rejected
- Task summaries (objective, scope, deps, verification)
- Key findings, errors, patterns discovered
- Constraints discovered during implementation

**Always append** to the existing phase file. Never create a second file for the same phase.

### Blocker Files (one per blocker)
```
.memory/blocker-{short-description}.md
```
Example: `.memory/blocker-auth-callback-infinite-loop.md`

Each blocker gets its own file documenting:
- What's blocked, why, what was tried, what's needed to unblock
- Related task/phase references

### Research Files (one per research run — ask mode)
```
.memory/research-{topic}-{YYYY-MM-DD}.md
```
Example: `.memory/research-nuxt4-tailwindcss-v4-2026-04-28.md`

Each research run creates its own file documenting findings, sources, and relevance. One file per research topic — indexed and searchable via `codebase_search`.

### General Memory (fallback)
```
.memory/memory.md
```

When no specific phase can be identified from the current context, append to `.memory/memory.md`. This is the catch-all for miscellaneous insights, cross-phase observations, and general project knowledge.

## Step 1: Identify Content Type

Determine where the memory belongs:

1. **Phase context** → identify the current phase number from context → append to `.memory/phase-{N}-{name}.md`
2. **Blocker** → create `.memory/blocker-{short-desc}.md`
3. **Research / web intel** (ask mode) → create `.memory/research-{topic}-{date}.md`
4. **No phase identifiable** → append to `.memory/memory.md`

## Step 2: Find or Create the Target File

Use `codebase_search` with query in `.memory/` to check if the target file already exists:

```
codebase_search: query "phase-{N}", path ".memory"
```

- **Exists** → read it, then use `apply_diff` to append new content at the end
- **Doesn't exist** → use `write_to_file` to create it with header + new content

## Step 3: Write the Content

### Phase File Format
```markdown
# Phase {N}: {Phase Name}

---

## {Topic} — {YYYY-MM-DD}

**Decisions:**
- [what was decided + why]

**Rationale:**
- [why alternatives rejected]

**Related Tasks:** [task refs]

---

[Next append goes here, separated by ---]
```

### General Memory Format
```markdown
# General Memory

---

## {Topic} — {YYYY-MM-DD}

**Context:** [what this relates to]

**Insight:** [what was learned]

**Impact:** [what this affects]

---

[Next append goes here, separated by ---]
```

### Research File Format
```markdown
# Research: {Topic}

**Date:** {YYYY-MM-DD}
**Trigger:** [what question or gap triggered this research]

## Findings
- [key finding 1]
- [key finding 2]

## Sources
- [URL or doc reference]
- [codebase area examined]

## Relevance
[how this relates to the current task/phase]

---
```

### Blocker File Format
```markdown
# Blocker: {Short Description}

**Status:** [ACTIVE | RESOLVED]
**Phase:** [phase ref]
**Task:** [task ref]
**Date:** {YYYY-MM-DD}

## What's Blocked
[description]

## Why
[root cause]

## What Was Tried
- [attempt 1]
- [attempt 2]

## What's Needed to Unblock
- [requirement]

---
```

## Step 4: Confirm

Verify the file was written correctly:
- File exists in `.memory/` with expected content
- No syntax errors
- Content appended (not overwritten) for phase and general files

Include confirmation in `/complete` output.

## Rules
- Do NOT create multiple files per phase — always append to the single phase file
- Do NOT overwrite existing phase or general files — append only
- Blockers are the ONLY exception to one-file-per-phase — each blocker gets its own file
- Research files (ask mode) → one file per research run, named by topic + date
- No phase identifiable from context → always fall back to `.memory/memory.md`
- Keep memory concise — reference indices, not documentation
