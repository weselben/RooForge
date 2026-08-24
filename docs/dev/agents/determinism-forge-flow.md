# Determinism sampling — forge-flow

Sampling pass per ADR 0004. Raw stdout at `.tmp-determinism/logs/forge-flow.log` (gitignored).

## Sample

- **Task:** simulate forge-flow steps 1–5 for first turn "add idempotency keys to payment endpoint", no map.
- **Run:** `kimi -p` on 2026-08-18T01:28:25Z, exit 0, 52 lines.
- **Outcome:** model derived `feat/idempotency-keys`, produced a verbatim STE100 `CreateGoal` objective with explicit map placeholder, marked step 2 slug-derivation as judgment, marked template/handoff as mechanical.

## Observed meta-decisions

- Read the skill body, walked steps 1–5 in order.
- Derived the slug from a free-text prompt — flagged this as **judgment** (no formula in the SKILL.md; example-guided only).
- Produced the goal text **verbatim** against the SKILL.md template — purely mechanical once the map title is known.
- Did **not** execute any commands (DRY RUN respected); noted that reuse-vs-create depends on `git branch -a` / `gh pr list` results it did not run.

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Detect map (URL / tracker / none) | none — three-case table | full | **MCP `forge_mcp.detect_map(repo)`** | input: `repo`; output: `{status, value?}` (see `determinism-forge.md` row #2). |
| 2 | Derive `feat/<slug>` from user's first turn or map title | high — free-text → slug has no formula | example-guided only | **Node wrapper + premade prompt template** (`skills/forge-flow/templates/slugify.md` + `scripts/derive-slug.js`); template renders the map title or first turn, outputs kebab-case slug with `-feat` suffix. Or simpler: shell + `tr`/`sed` against a stop-word list, since the rules are example-shaped. | input: text; output: slug string; test contract: matches the SKILL.md example list verbatim. |
| 3 | Reuse-vs-create lookup (`git branch`, `gh pr list`, map body `## Feat branch`) | none — three ordered lookups, first hit wins | full | **MCP `forge_mcp.find_feat_branch(repo, slug)`** — typed query, returns branch or null. | input: `repo`, `slug`; output: `{branch: string\|null, source: "map-body"\|"local-branch"\|"remote-pr"\|"none"}`. |
| 4 | Cut branch from `main` | none — `git checkout main && git pull && git checkout -b feat/<slug>` | full | **shell script** `skills/forge-flow/scripts/cut-feat.sh` (idempotent: existing branch → `git checkout`; new → create). | input: `slug`; output: branch name; exit 0 on success, exit 1 if `main` not ff-pullable. |
| 5 | Write `CreateGoal` objective (STE100 template) | medium — map-title phrasing only | full template, mandatory phrase `load forge skill (mandatory while goal is active)`, map URL placeholder | **Node wrapper + premade template** (`skills/forge-flow/templates/goal-objective.md`); the wrapper does the literal substitution and emits the objective. | input: `map_title`, `map_url_or_number`; output: string; contract: contains the mandatory phrase, contains URL or `PLACEHOLDER` token. |
| 6 | Hand off to forge step 1 | none — fixed message | full | **keep-as-text** — one-line emission, no value in scripting. | output: literal string "Continue with forge step 1 — load or chart the wayfinder map." |

## Notes

- The only genuinely judgment step is the **slug derivation**; the rest is lookup + template fill.
- Steps 1 and 3 are tracker/infra operations → MCP per ADR 0005 #1.
- Step 5 (goal text) is "model-in-loop" but the content is template-bound → Node wrapper per ADR 0005 #2.
- Surprising observation: the SKILL.md already encodes a lookup-table contract in step 2 (slug example list). That suggests the lookup itself is a determinism candidate — the example list is the test corpus.