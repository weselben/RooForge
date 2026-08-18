# Determinism sampling — forge-docs

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/forge-docs.log` (gitignored).

## Sample

- **Task:** trace steps 1–6 for trigger "new file `docs/dev/agents/determinism-forge.md` created"; list exact update paths, the one-line README entry, mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:28:25Z, exit 0, 73 log lines (incl. model reasoning).
- **Outcome:** model identified the two affected files (`docs/dev/agents/README.md` to create, `docs/dev/README.md` to update), correctly skipped `docs/README.md` (no new sub-folder), and explicitly surfaced the "the sub-folder README didn't exist" gap — the trigger revealed that `docs/dev/agents/` had no index file at all.

## Observed meta-decisions

- Read `skills/forge-docs/SKILL.md` first.
- Cross-referenced the update-rules table against the trigger ("deep research report → `docs/dev/agents/<topic>.md` + `docs/dev/README.md`").
- Detected that `docs/dev/agents/README.md` did not exist (DRY RUN included an `ls -la` that returned an empty directory) and correctly inferred "create" rather than "update".
- Distinguished the **directory-pointer style** of the parent `docs/dev/README.md` from the per-file style of sub-READMEs — a convention call.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Identify trigger | none | full — fixed trigger list | **shell script** — hook/caller passes the trigger; no model needed. | input: trigger enum; output: {trigger, target_subfolder}. |
| 2 | Look up affected sub-folder per trigger table | none | full — fixed table | **shell script / lookup** — single-row table read. | input: trigger; output: target path. |
| 3 | Apply sub-README template (one-line entry, relative link, GitHub-browsable) | medium — "why it exists" phrase | full — structure and link format | **premade prompt template + Node wrapper** — template fills skeleton; wrapper enforces relative-link and one-sentence cap. | input: filename + one-line summary; output: formatted entry. |
| 4 | Update `docs/README.md` only when folder membership changes | none | full — fixed rule | **shell script** — git-diff on the docs tree; if no new sub-folder, skip. | input: changed paths; output: {update_global: bool}. |
| 5 | ADR cross-reference in `docs/dev/CONTEXT.md` | none when trigger is research; otherwise fixed | full when applicable | **shell script** — append term + cross-ref entry per ADR format. | input: ADR NNNN-slug; output: CONTEXT.md line. |
| 6 | "Same commit" rule (index updates travel with file changes) | none | full — fixed | **shell script** — pair the file write and README update in one commit. | n/a. |
| 7 | Per-trigger judgement (does a code change need a `system-design/` doc?) | medium — "ambiguity about how the system works" is fuzzy | none | **keep-as-model** — the *ask* is judgment; the *trigger→folder* table is mechanical. | input: change description; output: doc needs. |
| 8 | Decide whether `docs/dev/README.md` adds an inline entry or keeps the directory pointer | low — style call | mostly | **keep-as-model** — style consistency is judgment; a linter could enforce the existing pattern. | input: parent README; output: edit choice. |
| 9 | Discover a missing index file (sub-folder has no README yet) | none | full — fix is template application | **shell script** — `test -f` per affected sub-folder. | input: sub-folder; output: {exists: bool, create: bool}. |

## Notes

- Forge-docs is the **most rule-shaped** skills/curation-side skill: the trigger table, the templates, and the "same commit" rule are all deterministic. The judgment is in the *phrasing* of one-line summaries and the borderline call of when a code change merits a new `system-design/` doc.
- The sample exposed a real gap: `docs/dev/agents/` had no `README.md`. The trigger correctly fired the create path. This is a reminder that the skill's index-maintenance mandate depends on the sub-folder already following the convention.
- The strongest determinism win is a **`forge_mcp.docs_index_diff(changed_paths)` MCP tool** that emits the exact list of files to update and the one-line entry skeletons; the model would only author the prose summary.
- The "always update sub-README in same commit" rule is already a deterministic guard — easily scriptable as a pre-commit check.