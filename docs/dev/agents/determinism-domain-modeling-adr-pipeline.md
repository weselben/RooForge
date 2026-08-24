# ADR+PR pipeline design — `forge-mcp` for `domain-modeling`

**Status:** Design — T2-F #90 (map #31)
**Owns:** automatic ADR recording + per-ADR PR pipeline on `forge-mcp` MCP server
**Grounded in:** `skills/domain-modeling/SKILL.md`, `skills/domain-modeling/ADR-FORMAT.md`, `skills/domain-modeling/CONTEXT-FORMAT.md`, `docs/dev/agents/determinism-domain-modeling.md`, `docs/dev/agents/determinism-seams-summary.md`, ADR 0004–0008, `skills/forge-docs/SKILL.md`, `skills/git-issue-tracker/SKILL.md`, `skills/using-git-worktrees/SKILL.md`, `skills/creating-pull-requests/SKILL.md`, `skills/caveman-commit/SKILL.md`, `skills/conventional-commits/SKILL.md`, `skills/finishing-a-development-branch/SKILL.md`, `mcp/pdf-curl-server.sh` (launcher convention).

## 1. Trigger — when is an ADR "ready to record"?

Three concrete options, then a pick.

### Option A — User-invoked only

User explicitly says "record that as an ADR". Model never offers; user must notice. The skill's "Offer ADRs sparingly" prose is ignored. **Pros:** zero false positives, user in full control. **Cons:** relies on the user catching the moment — exactly what `skills/domain-modeling/SKILL.md:60–64` says the skill exists to prevent. High cognitive load; the *active* discipline is lost.

### Option B — Three-criterion auto-detect, single confirmation gate

The rule from `skills/domain-modeling/SKILL.md:60–64` (Hard to reverse / Surprising without context / Result of a real trade-off, all three true) executes as a Node wrapper + premade prompt template — exactly the seam identified in `docs/dev/agents/determinism-domain-modeling.md` row 11: *"premade prompt template — ask the model to answer 3 yes/no questions; wrapper computes the AND."* When `AND = true`, the pipeline halts once for user confirmation. **Pros:** turns the skill's own rule into code; one explicit gate where the decision crystallises. **Cons:** still surfaces a prompt per event.

### Option C — Heuristic + silent threshold

Continuously score candidates against a weighted sum (three criteria + novelty + downstream impact). Trigger fires when score ≥ threshold; user reviews via digest. **Pros:** zero main-chat blocks. **Cons:** removes the moment of crystallisation that `skills/domain-modeling/SKILL.md:14` ("writing the glossary and decisions down the moment they crystallise") explicitly requires. Opaque; no single confirmation point. Needs UX the harness doesn't currently expose.

### Pick: Option B

Reasoning: the three-criterion test is already enumerated in the skill — we don't need to *invent* a rule, we need to *execute* an existing one. Per ADR 0005 #1 the wrapper goes to MCP; per the seam table row 11 the wrapper is a Node script + template. The single confirmation gate is the *moment of crystallisation* the skill demands. Option A leaves the rule to user attention; Option C hides the rule. Option B keeps the rule visible and executable.

## 2. Pipeline steps — "ADR idea exists" to "PR merged"

Twelve steps; each named, with owning tool, inputs, outputs. Branch is the map's `feat/<map-slug>` (never `main`, per `skills/finishing-a-development-branch/SKILL.md` hard rule).

| # | Step | Owning tool / skill | Input | Output |
|---|------|---------------------|-------|--------|
| 1 | Detect trigger | `forge_mcp.adr_offer_test` + `skills/domain-modeling/SKILL.md:60–64` | `{claim, alternatives}` | `{offer, criteria[3], rationale}` |
| 2 | Author ADR body | `domain-modeling` + `skills/domain-modeling/ADR-FORMAT.md` (Node wrapper + template) | `{claim, alternatives, criteria}` | `{title, body}` meeting the format |
| 3 | Compute next ADR number | `forge_mcp.next_adr_number` + `skills/forge-docs/SKILL.md` numbering rule | `{repo_root}` | `{next: NNNN, existing: [NNNN,…]}` |
| 4 | Ensure isolation | `forge_mcp.worktree_ensure` + `skills/using-git-worktrees/SKILL.md:17–56` Step 0–1 | `{task_slug, base_branch}` | `{path, branch, created, reused}` |
| 5 | Write ADR file | `forge_mcp.record_adr` + `skills/domain-modeling/ADR-FORMAT.md` + lazy-create from `skills/domain-modeling/SKILL.md:22` | `{repo_root, number, slug, title, body, status}` | `{path, sha, lint_ok}` |
| 6 | Append glossary term | `forge_mcp.glossary_append_term` + `skills/domain-modeling/CONTEXT-FORMAT.md` + `skills/forge-docs/SKILL.md` ADR cross-ref rule | `{repo_root, term, definition, adr_ref}` | `{context_path, diff}` |
| 7 | Update sub-README | `forge_mcp.docs_index_diff` + `skills/forge-docs/SKILL.md` same-commit rule | `{repo_root, changed_paths}` | `{sub_readme_updates, global_readme_update, adr_cross_refs}` |
| 8 | Commit | `forge_mcp.worktree_commit` + `skills/caveman-commit` + `skills/conventional-commits` | `{worktree_path, message, scope: "domain-modeling"}` | `{sha, conventional_valid}` |
| 9 | Draft PR body | `forge_mcp.open_adr_pr` + `skills/creating-pull-requests/SKILL.md:24–37` size gate + disclosure | `{branch, title, body, base, draft}` | size gate `Small` (TL;DR only) by construction |
| 10 | Push + open PR | `forge_mcp.worktree_push` + `forge_mcp.open_adr_pr` + `skills/git-issue-tracker/SKILL.md` gh operations | `{worktree_path, branch}` + PR args | `{number, url, draft: true}` |
| 11 | User review gate | web UI (no skill) | PR URL | `{approved, changes_requested, rejected}` |
| 12 | Mark ready / merge | `forge_mcp.open_adr_pr(ready=true)` + `skills/finishing-a-development-branch/SKILL.md:53–55` | PR number | merged or held |

Step ordering: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12. Steps 6 and 7 are atomic with step 5 per the `skills/forge-docs/SKILL.md` same-commit rule (the index update travels with the file change). Step 9 always produces a `Small`-gate body; the seam row 11 in `docs/dev/agents/determinism-creating-pull-requests.md` is therefore selected once and never revisited.

## 3. One PR per ADR vs batch PR

**Pick: one PR per ADR by default.**

Reasoning, in priority order, tied to existing skills and ADRs:

- **Skill mandate.** `skills/domain-modeling/SKILL.md:25–27`: *"Do not batch ADRs or hold them until the branch is 'done'. Each decision is recorded at the moment it crystallises and committed immediately."* Per-ADR PRs honour "committed immediately" without an internal queue.
- **Immutability boundary.** `skills/domain-modeling/SKILL.md:22` says ADRs are mutable on the feat branch and immutable on `main`. One PR = one merge = one immutability event. Batch PRs blur this — reviewers cannot tell when a particular ADR became immutable.
- **Size-gate fit.** `skills/creating-pull-requests/SKILL.md:36` classifies `<50` lines as `Small` (TL;DR only). Each ADR is the format from `skills/domain-modeling/ADR-FORMAT.md`: *"An ADR can be a single paragraph."* Every per-ADR PR auto-classifies Small; no section budget calculation per call.
- **Review burden per event.** A reviewer reads one decision (hard to reverse / surprising / trade-off) per PR, not N. The seam row 12 in `docs/dev/agents/determinism-creating-pull-requests.md` keeps the *post-generation review checklist* as a linter per PR — small surface, fast loop.
- **Failure isolation.** A changes-requested PR blocks one ADR. Siblings are unaffected. A batch PR cascades.
- **Audit trail.** `skills/git-issue-tracker/SKILL.md:54` says the map's *Decisions-so-far* section should append a context pointer (gist + link) on resolve. One URL per ADR maps cleanly to one closure entry per ticket.
- **ADR 0005 alignment.** The seam row for `domain-modeling` in `docs/dev/agents/determinism-seams-summary.md` (rows 30–32) names the three tools here: MCP for `term_lookup`, template for format, and `Node+template` for the file write — no batching mechanism surfaces.

**Opt-in batch mode** is provided by `forge_mcp.adr_pipeline_batch_open` for the user who explicitly asks ("batch these N ADRs into one PR"). The batch PR is `Medium` (50–200 lines), uses the files table from `skills/creating-pull-requests/SKILL.md:43–47`, and marks *start here* on the ADR with the broadest context impact.

## 4. Auto-push vs awaiting user review before push

**Pick: push-to-remote + open-as-draft; user reviews then marks ready.**

The push happens; the *ready* gate is owned by the user. Two reasons:

- `skills/creating-pull-requests/SKILL.md:11–12` is a *Critical rule*: *"Always create PRs with `--draft`. User marks ready."* The pipeline cannot mark ready itself.
- Per-ADR PRs land on `feat/<map-slug>` — not a per-ADR branch. Push is to a branch the user already owns and reviews on the map.

Where the user sees the diff:

- **Primary surface: web URL.** `forge_mcp.open_adr_pr` returns the PR URL. The CLI prints the URL; the user reviews in GitHub's web UI. This is the canonical surface and matches the seam row 5 in `docs/dev/agents/determinism-creating-pull-requests.md` (`--body-file` as fixed string).
- **Secondary surface: terminal diff.** `forge_mcp.worktree_diff(branch, base)` returns unified diff text for piping to `less` or copy-paste. Useful offline, in CI, or for pre-PR review.

The push is undoable: `git push origin --delete <feat-branch>` plus `gh pr close <number>` reverses a draft. Hard-coded: `forge_mcp.open_adr_pr` always passes `draft=true`; the model's only choice is *what title/body*, not *what mode*.

## 5. Silent background mode — what blocks, what doesn't

The pipeline is mostly non-blocking. The main chat is **never** put on a wait prompt during the run unless an exception halts it.

**Blocking (synchronous, brief):**

- Step 1 — three-criterion test: model must decide.
- Steps 5–8 — file writes + commit: synchronous; tens of milliseconds in the worktree.
- Step 10 — `git push` + `gh pr create` over network: seconds.
- One user prompt at step 1 confirmation (Option B), at most.

**Non-blocking (background queueable):**

- Step 3 — `next_adr_number` is a pure directory scan.
- Step 4 — `worktree_ensure` returns immediately when isolation already exists (the `skills/using-git-worktrees/SKILL.md:17–28` Step 0 path).
- Step 7 — `docs_index_diff` is pure read.
- Step 9 — body authoring; runs detached if the orchestrator supports it.

**User-facing interface (three surfaces, all non-modal):**

```
[forge-mcp] ADR pipeline started: <slug>. 6 steps queued. ETA <15s>.
[forge-mcp] step 5/8: ADR written, glossary updated.
[forge-mcp] step 10/12: push + PR open.
[forge-mcp] ADR PR opened (draft): https://github.com/<owner>/<repo>/pull/<N> — review and mark ready when satisfied.
```

Single chat notification per pipeline run; one-line progress badges per completed step; completion notification with URL. No wait prompt unless an exception halts the pipeline. Ad-hoc status checks via `forge_mcp.adr_pipeline_status(map_slug)` return `{pending, open_prs, merged}`.

This matches ADR 0005 #1 — *tracker/infra* operations on MCP, with the model-driven authorship staying in the model's lane. The pipeline is the "infra" half.

## 6. Tool surface — `forge-mcp` typed signatures

Per ADR 0006 ("the exact tool surface is **not fixed here**; proposed from T1 findings; only approved entries are built"), these are the proposed signatures for the T2-F review. Names follow the `forge_mcp.*` convention; types are MCP JSON-Schema-friendly.

```text
forge_mcp.adr_offer_test(args: {
  claim: string,
  alternatives: string[],
}): {
  offer: bool,                                       // AND of three criteria
  criteria: { hard_to_reverse: bool, surprising: bool, trade_off: bool },
  rationale: string,                                 // one sentence per criterion
}

forge_mcp.next_adr_number(args: {
  repo_root: string,
}): {
  next: int,                                         // highest existing NNNN + 1
  existing: int[],                                   // for diagnostics
}

forge_mcp.worktree_ensure(args: {
  task_slug: string,
  base_branch: string,                               // feat/<map-slug>; never main
  location?: string,                                 // defaults to .worktrees/
}): {
  path: string,
  branch: string,
  created: bool,                                     // false ⇒ reused
  reused: bool,
}

forge_mcp.record_adr(args: {
  repo_root: string,
  number: int,
  slug: string,                                      // kebab-case
  title: string,
  body: string,                                      // Markdown per ADR-FORMAT.md
  status?: "proposed" | "accepted" | "deprecated" | "superseded",
}): {
  path: string,                                      // docs/adr/NNNN-slug.md
  sha: string,                                       // git blob hash
  lint_ok: bool,                                     // format + content constraints
  dir_created: bool,                                 // true ⇒ lazy-create of docs/adr/ fired
}

forge_mcp.glossary_append_term(args: {
  repo_root: string,
  term: string,
  definition: string,                                // one sentence per CONTEXT-FORMAT.md
  adr_ref: int,
}): {
  context_path: string,                              // docs/dev/CONTEXT.md
  diff: string,                                      // unified diff
}

forge_mcp.docs_index_diff(args: {
  repo_root: string,
  changed_paths: string[],                           // e.g. ["docs/adr/0009-foo.md"]
}): {
  sub_readme_updates: { path: string, entry: string }[],
  global_readme_update: bool,
  adr_cross_refs: { context_path: string, term: string }[],
}

forge_mcp.worktree_commit(args: {
  worktree_path: string,
  message: string,
  scope: string,                                     // "domain-modeling" or "docs"
}): {
  sha: string,
  conventional_valid: bool,
}

forge_mcp.worktree_push(args: {
  worktree_path: string,
  branch: string,
}): { remote: string, sha: string, push_ok: bool }

forge_mcp.open_adr_pr(args: {
  repo_root: string,
  branch: string,                                    // feat/<map-slug>
  title: string,                                     // "docs(adr): record <slug>"
  body: string,                                      // TL;DR + AI disclosure (Small gate)
  base: string,                                      // "main"
  draft: bool,                                       // always true per critical rule
}): {
  number: int,
  url: string,
  draft: bool,
  size_gate: "small" | "medium" | "large",
}

forge_mcp.worktree_diff(args: {
  branch: string,
  base: string,
}): { diff: string, stat: string, files_changed: int }

forge_mcp.adr_pipeline_status(args: {
  map_slug: string,
}): {
  pending: { slug: string, step: int }[],
  open_prs: { number: int, url: string, slug: string }[],
  merged: { slug: string, number: int, merged_at: string }[],
}

forge_mcp.adr_pipeline_batch_open(args: {            // OPT-IN — user explicitly requested
  map_slug: string,
  slugs: string[],
}): { number: int, url: string, draft: bool, file_count: int }
```

Server registration follows the existing `mcp/pdf-curl-server.sh:1–183` convention — JSON-RPC over stdio with a launcher script and one `.ps1` mirror. The tool list returned by `tools/list` is the union of the names above; tools that fail to earn their keep at T3 review are dropped before T6 build, per ADR 0006.

## 7. Failure modes and per-step recovery

| Step | Failure | Recovery | Hard rule preserved |
|------|---------|----------|---------------------|
| 1 | Three-criterion test inconclusive | Halt; model asks user once for the borderline criterion. | `skills/domain-modeling/SKILL.md:60–64` — never skip the test. |
| 2 | ADR body fails format lint | Return body with violations; model rewrites; retry. | `skills/domain-modeling/ADR-FORMAT.md` — single paragraph or optional sections. |
| 3 | `docs/adr/` does not exist | `record_adr` creates the directory (lazy-create, `skills/domain-modeling/SKILL.md:22`). | — |
| 4 | Worktree permission error | Suggest in-place work per `skills/using-git-worktrees/SKILL.md:53–55` fallback. | `skills/using-git-worktrees/SKILL.md:43` — never branch off main when dispatching. |
| 4 | Existing branch conflict | Halt; offer to switch to existing branch or pick a new slug. | `skills/git-issue-tracker/SKILL.md:60–73` branch-association rules. |
| 5 | Slug / number collision | Bump number; surface collision to model. | `skills/domain-modeling/ADR-FORMAT.md` numbering. |
| 6 | Glossary update conflicts (concurrent edit) | Read CONTEXT.md; retry merge with diff3; on conflict, halt and surface to user. | `skills/forge-docs/SKILL.md` single-source-of-truth. |
| 7 | Sub-README update fails | Abort commit; fix index; retry steps 5–8 as one unit. | `skills/forge-docs/SKILL.md` same-commit rule. |
| 8 | Pre-commit hook rejects (e.g. `commit-msg` linter) | Return hook output; model rewrites message; retry. | ADR 0005 #2 — `caveman-commit` + `conventional-commits` linter is the shared win. |
| 9 | Body fails post-gen checklist (banned opener, noun-stack cap) | Lint violations returned; rewrite; retry. | `skills/creating-pull-requests/SKILL.md:189–198` checklist. |
| 10 | Push fails (no upstream / auth) | Halt; return un-pushed branch state; suggest `gh auth login`. | — |
| 10 | PR open fails | Branch is local-only; offer to retry after `gh auth status`. | — |
| 11 | User marks *changes-requested* | Enqueue follow-up commit on the same PR branch; re-run steps 5–10. | One-PR-per-ADR boundary preserved. |
| 12 | Merge fails (conflict on main) | Halt; load `skills/resolving-merge-conflicts/SKILL.md`. | `skills/finishing-a-development-branch/SKILL.md:9` — *NEVER merge to main*. |

In every halt case the worktree state is left untouched and a single chat message surfaces the failure. The pipeline never auto-recovers from a step that needs a model judgment call (steps 1, 6, 9).

## 8. Interaction with existing skills — delegation map

Each step delegates to the skill whose procedure it wraps. No step duplicates logic.

| Step | Delegates to | Surface reused |
|------|--------------|----------------|
| 1 | `skills/domain-modeling/SKILL.md:60–64` three-criterion rule | wrapped as Node wrapper + template (seam row 11 in `docs/dev/agents/determinism-domain-modeling.md`) |
| 2 | `skills/domain-modeling/ADR-FORMAT.md` | Node wrapper renders the template (seam row 3 in `docs/dev/agents/determinism-domain-modeling.md`) |
| 3 | `skills/forge-docs/SKILL.md` numbering + lazy-create | shell script (seam rows 1, 4 in `docs/dev/agents/determinism-domain-modeling.md`) |
| 4 | `skills/using-git-worktrees/SKILL.md:17–56` | shell/MCP `forge_mcp.worktree_create` (matrix row "using-git-worktrees" in `docs/dev/agents/determinism-seams-summary.md`) |
| 5 | `skills/domain-modeling/ADR-FORMAT.md`, `skills/forge-docs/SKILL.md` ADR mandate | linter for format |
| 6 | `skills/domain-modeling/CONTEXT-FORMAT.md`, `skills/forge-docs/SKILL.md` ADR cross-ref | shell + linter (seam rows 2, 5) |
| 7 | `skills/forge-docs/SKILL.md` sub-README template + same-commit rule | MCP `forge_mcp.docs_index_diff` (seam row "forge-docs") |
| 8 | `skills/caveman-commit/`, `skills/conventional-commits/` | linter (seam rows "caveman-commit", "conventional-commits") |
| 9 | `skills/creating-pull-requests/SKILL.md:24–37` size gate + disclosure | shell + premade template (seam row "creating-pull-requests") |
| 10 | `skills/git-issue-tracker/SKILL.md` gh conventions | MCP wrappers for gh ops (matrix row "git-issue-tracker") |
| 12 | `skills/finishing-a-development-branch/SKILL.md:53–55` | shell/MCP (matrix row "finishing-a-development-branch") |

This is the **Tracker/infra → MCP** slice of ADR 0005 #1 applied end-to-end. Each `forge_mcp.*` tool is a typed wrapper, not a re-derivation. The seam tables in `docs/dev/agents/determinism-seams-summary.md` show this pattern already declared for `wayfinder`, `git-issue-tracker`, `pr-review`, `pr-resolve`, `forge` — the ADR pipeline extends the same family without new mechanisms.

## 9. Why per-ADR PR is the recommended default

The seven-point justification from §3 is the design contract; restated as one paragraph for the issue comment:

> Per-ADR PR is the default because the skill's prose (`SKILL.md:25–27`) forbids batching, the ADR immutability rule (`SKILL.md:22`) gives each PR its own merge event, the size gate (`creating-pull-requests/SKILL.md:36`) auto-classifies single-ADR PRs as Small (TL;DR only), review burden stays minimal, failures stay isolated, the map's *Decisions-so-far* section (`git-issue-tracker/SKILL.md:54`) cites one URL per ticket, and the T1 mechanism matrix assigns no batching shape — every existing mechanism in `docs/dev/agents/determinism-seams-summary.md` for the `domain-modeling` skill is one-shot. Batch mode is opt-in via `forge_mcp.adr_pipeline_batch_open` for the rare user who asks.

## Notes

- Per-ADR PR means **one Conventional Commit per ADR**, scope `docs(adr)` or `domain-modeling`, on the existing `feat/<map-slug>` branch — never a per-ADR branch. Squash-merge happens once per ADR at map-merge time.
- The pipeline inherits ADR 0006's "deferred tool surface" discipline: only the tools above that survive T2-F HITL review ship with the build (per ADR 0006 risk note). If the user vetoes `open_adr_pr` in favour of bare `gh pr create`, the body-generator becomes part of `creating-pull-requests` and the tool is dropped.
- The pipeline never operates on `main`; even the immutability check happens after `feat/<map-slug>` merges, which is `finishing-a-development-branch` territory.
- The "moment of crystallisation" framing (`SKILL.md:14`) is preserved: the user sees exactly one confirmation prompt per ADR (Option B), and one notification per pipeline completion. The pipeline is otherwise silent.

## Related

- Map issue: #31 (`docs/dev/agents/determinism-seams-summary.md`)
- Tickets: #32 (T1 sampling), #33 (T2 surface), #37 (T6 build), #90 (T2-F)
- ADRs: 0004 (sampling criterion), 0005 (mechanism policy), 0006 (forge-mcp), 0008 (openai-compat endpoint — deferred, unaffected)
- Skills: `domain-modeling`, `domain-modeling/ADR-FORMAT.md`, `domain-modeling/CONTEXT-FORMAT.md`, `forge-docs`, `using-git-worktrees`, `creating-pull-requests`, `caveman-commit`, `conventional-commits`, `git-issue-tracker`, `finishing-a-development-branch`