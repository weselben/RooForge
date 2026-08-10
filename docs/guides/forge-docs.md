# forge-docs

Owns the `docs/` directory of a repo: its fixed structure, per-subfolder update rules, README index maintenance, and the ADR (Architecture Decision Record) mandate. It is the single source of truth for these rules — no other skill duplicates them. It runs after work chunks (e.g. squash merges in `forge` step 4) so docs travel with the code change, and whenever research reports or ADRs are written.

## When to load

From the skill's frontmatter description (`skills/forge-docs/SKILL.md:2-3`):

- Before code changes
- Before researching the codebase
- Before closing a chunk of work (e.g. after a squash merge — `forge` loads it at step 4, "Docs updates travel with the squash commit", `skills/forge/SKILL.md:84`)
- When writing an ADR
- Also loaded by `deep-research` (per `SKILL.md:5`)

## How it works

The skill defines a fixed `docs/` structure — `adr/` (flat, no README), `dev/` (with `CONTEXT.md` glossary, optional `CONTEXT-MAP.md`, `agents/` research reports), `guides/`, `system-design/`, `public/` (`skills/forge-docs/SKILL.md:9-19`) — and follows these steps when invoked (`SKILL.md:104-112`):

1. Identify what triggered the load (code change, research write, chunk close, ADR).
2. Identify the sub-folder(s) that need updates per the trigger table (`SKILL.md:64-73`) — e.g. new behavior → `docs/system-design/`; missing how-to → `docs/guides/`; new tool/module → ADR in `docs/adr/`; merged chunk → `docs/public/`; research report → `docs/dev/agents/<topic>.md` plus `docs/dev/README.md`.
3. For each affected sub-folder, create or update the file using the template format.
4. Update that sub-folder's `README.md` index in the same commit (one sentence per entry, relative links, GitHub-browsable).
5. Update the global `docs/README.md` only if folder membership changed (new sub-folder added).
6. Done when every affected sub-folder's `README.md` reflects the current file list.

Additional mandates:

- **ADR format:** `docs/adr/NNNN-slug.md`, sequential numbering zero-padded to 4 digits; each ADR is cross-referenced from the glossary `docs/dev/CONTEXT.md`, which serves as the ADR index — no `docs/adr/README.md` may exist (`SKILL.md:89-101`).
- **Index templates:** sub-README and collapsible global `docs/README.md` templates are given inline at `SKILL.md:31-57`.
- **On any code change:** if the change introduces ambiguity about how the system works, update `docs/system-design/` or `docs/guides/`; otherwise "the code is its own documentation" (`SKILL.md:75`).

## Files in this skill

- `skills/forge-docs/SKILL.md` — the entire skill (145 lines): frontmatter, directory structure, index templates, trigger/update table, ADR mandate, invocation steps, rules, and boundaries. No scripts, templates, or companion files exist in the directory.

## See also

- `forge` — loads `forge-docs` after every squash merge in step 4 so docs updates travel with the squash commit (`skills/forge/SKILL.md:84`).
- `deep-research` — named in `forge-docs`'s frontmatter as a loader (`SKILL.md:5`); its reports land in `docs/dev/agents/<topic>.md`.
- `domain-modeling` — maintains the glossary terms in `docs/dev/CONTEXT.md` and decides ADR content; `forge-docs` explicitly delegates that work to it (`SKILL.md:131-133`).
- `subagent-driven-development` / `pr-review` — explicitly out of scope; cited as boundary examples of code-writing/reviewing skills (`SKILL.md:128-129`).

## Notes

- The skill's frontmatter description says "Load before code changes" (`SKILL.md:3`), while the invocation steps and `forge`'s usage load it *after* a change lands. Both readings are compatible (docs assessment precedes, write-up follows), but the source does not reconcile them explicitly.
