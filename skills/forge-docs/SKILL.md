---
name: forge-docs
description: Maintain the docs directory — structure, update rules, index files, ADR mandate. Load before code changes, before researching the codebase, before closing a chunk of work, and when writing an ADR.
source: local://authored
---

# Forge Docs

Owns the docs directory. Single source for structure, update rules, index maintenance, and the ADR mandate. Loaded by `forge` (step 4) and `deep-research`.

## Directory structure

```
docs/
├── adr/                  # Architecture Decision Records (NNNN-*.md)
├── dev/                  # Internal dev artefacts
│   ├── CONTEXT.md        # Glossary — the index for ADRs
│   ├── CONTEXT-MAP.md    # Only if multi-context
│   └── agents/           # Deep research reports
├── guides/               # How-to guides for engineers
├── system-design/        # Architecture & system design docs
└── public/               # External-facing docs
```

`docs/adr/` is a flat list. No sub-folders. No `docs/adr/README.md` — the glossary in `docs/dev/CONTEXT.md` IS the ADR index.

## Sub-README index rules

Every `docs/<subfolder>/` has a `README.md` that is the index for that sub-folder. The global `docs/README.md` is the index for the docs tree itself.

**On every file create or update in a sub-folder:**
1. Update the sub-folder's `README.md` in the same commit.
2. Update the global `docs/README.md` if the folder membership changed (new sub-folder added).

**Sub-README templates** (one sentence per entry, relative links, GitHub-browsable):

```markdown
# <Subfolder Name>

<one-line purpose>

- [Title](file.md) — one-line why it exists.
- [Title](file.md) — one-line why it exists.
```

**Global `docs/README.md` template** (collapsible, one entry per sub-folder, links to sub-READMEs):

```markdown
# Docs Index

## adr
<details><summary>Architecture Decision Records</summary>

See [`docs/dev/CONTEXT.md`](../dev/CONTEXT.md) for the glossary and ADR cross-references.

</details>

## dev
<details><summary>Internal dev artefacts</summary>

- [`CONTEXT.md`](dev/CONTEXT.md) — domain glossary.
- [`agents/`](dev/agents/) — deep research reports.

</details>

## guides
<details><summary>How-to guides</summary>

- [Title](guides/file.md) — one-line why it exists.

</details>

## system-design
<details><summary>Architecture & system design</summary>

- [Title](system-design/file.md) — one-line scope.

</details>

## public
<details><summary>External-facing docs</summary>

- [Title](public/file.md) — one-line audience.

</details>
```

**Always:**
- Use relative links (`../dev/CONTEXT.md`, `[Title](file.md)`) — never absolute paths.
- One sentence per entry. No prose blocks.
- Markdown renders collapsible in GitHub.

## Update rules — when each sub-folder moves

| Trigger | Sub-folder to update |
|---------|---------------------|
| Code change introduces a new behavior, contract, or architectural shape | `docs/system-design/` (create or update) |
| A user or agent question exposed a missing how-to | `docs/guides/` (create or update) |
| A new tool, module, or fully new piece of the project | ADR in `docs/adr/` (see ADR section) |
| A glossary term crystallised or sharpened | `docs/dev/CONTEXT.md` |
| A big chunk of work completed (PR merged, feature shipped) | `docs/public/` |
| A deep research report was written | `docs/dev/agents/<topic>.md` + `docs/dev/README.md` |
| Any file created or updated anywhere in `docs/` | That sub-folder's `README.md` |
| A new sub-folder added to `docs/` | `docs/README.md` |

**On any code change:** ask — does this introduce ambiguity about how the system works? If yes, update or create a reference file in `docs/system-design/` or `docs/guides/`. If no, the code is its own documentation.

## ADR mandate

When you introduce a new tool, module, or any fully new piece of the project — write an ADR. If one does not exist for it, create one.

An ADR records a hard-to-reverse, surprising, trade-off decision. New things are exactly that.

**Format:** `docs/adr/NNNN-slug.md`. Numbering is sequential, zero-padded to 4 digits. The glossary (`docs/dev/CONTEXT.md`) cross-references each ADR.

**After writing an ADR:**
- Update `docs/dev/CONTEXT.md` with the new term + cross-reference.
- No `docs/adr/README.md` exists — the glossary is the index.

## Steps when invoked

1. Identify what triggered the load (code change, research write, chunk close, ADR).
2. Identify the sub-folder(s) that need updates per the table.
3. For each affected sub-folder, create or update the file using the template format.
4. Update the sub-folder's `README.md` in the same commit.
5. Update `docs/README.md` only if the folder membership changed.
6. Done when every affected sub-folder's `README.md` reflects the current file list.

## Rules

- **Single source of truth.** Update rules, templates, and the ADR mandate live here only. No other skill duplicates them.
- **Relative links always.** GitHub-browsable. Never absolute paths.
- **One sentence per index entry.** No prose blocks in sub-READMEs or `docs/README.md`.
- **Glossary cross-references ADRs.** ADRs themselves have no `README.md`.
- **Index updates travel with file changes.** Same commit, every time.

## Boundaries

Forge Docs does not:
- Run code, write code, or review code (those are forge, SDD, pr-review)
- Maintain the glossary's terms (`domain-modeling` does that)
- Decide what an ADR should say (the engineer + `domain-modeling` decide)
- Maintain the issue tracker or the wayfinder map

It only ensures the docs directory, its index files, and the ADR mandate stay current after each write.