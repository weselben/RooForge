# Determinism sampling — caveman-review

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/caveman-review.log` (gitignored).

## Sample

- **Task:** review a 3-line PR hunk that dereferences `users.find().email` without a null guard; produce findings in the skill's format, then split mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:27:42Z, exit 0, 23 log lines (incl. model reasoning).
- **Outcome:** model produced two findings — one `🔴 bug` on L12 (undefined after `.find()`), one `🟡 risk` on L13 (couples to the L12 failure) — and explicitly justified the severity split.

## Observed meta-decisions

- Read `skills/caveman-review/SKILL.md` first, then drafted findings template-locked: `L<line>: <severity> problem. fix.`
- Severity classification was **explicit and reasoned**: "will throw" → `🔴 bug`, "couples to L12 but not fatal on its own" → `🟡 risk`. The skill's severity definitions drove this directly.
- Quoted exact symbols (`user`, `.email`) in backticks without deliberation — preservation rule.
- Chose to add a *coupled* finding on L13 rather than restating L12 — a judgment call on what counts as a separate concern.
- Kept throat-clearing absent, kept the "why" minimal ("Guard or early-return").
- Did **not** modify files (respected the DRY RUN contract).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Obtain the diff (hunk by line) | none | full — `git diff` / PR API | **shell script**: `gh pr diff --PR <N>` or `git diff <base>..HEAD`. | input: PR number / ref range; output: unified diff. |
| 2 | Apply the format template (`L<line>: <severity> problem. fix.`) | none | full — fixed template | **linter/post-processor** — given a finding, validate format and re-emit the canonical shape. | input: raw finding; output: formatted line or reject. |
| 3 | Severity taxonomy (🔴 bug / 🟡 risk / 🔵 nit / ❓ q) | low — definitions exist in the skill | largely — definitions are explicit | **keep-as-model**, but a heuristic classifier could bucket obvious cases (null deref → bug, magic number → nit) for triage. | input: finding; output: severity enum (with override for model). |
| 4 | Spot the bug / hazard in the code | high — semantic understanding | none | **keep-as-model** — ADR 0005 classifies defect identification as judgment. A static analyzer (`forge-mcp.sast_scan`) could pre-flag known classes, leaving novel reasoning to the model. | input: code snippet; output: candidate defects with confidence. |
| 5 | Decide whether L13 is a coupled risk vs restating L12 | medium — what counts as a separate concern | none | **keep-as-model** — concern-grouping is judgment; ADR 0005 flags this explicitly. | input: defect list; output: grouped-deduped findings. |
| 6 | Write the concrete fix (not "consider refactoring") | high — needs to understand intent | none | **keep-as-model** — fix proposal is authorship. | input: defect; output: fix phrasing. |
| 7 | Drop throat-clearing, drop restating-the-line | none | full — fixed drop list | **post-processor / linter** — strip patterns like "I noticed that…", "You might want to…". | input: draft comment; output: tightened comment. |
| 8 | Auto-Clarity drop (security CVE, architectural disagreement, onboarding) | medium — when to drop terse | trigger list is enumerated | **keep-as-model** for the decision; the *format* of the expanded section is a template. | input: finding + context flags; output: expanded paragraph or terse line. |

## Notes

- The 3-line sample is small but illustrative: the model executed the format and taxonomy mechanically, then concentrated all judgment in steps 4–6 (defect spotting, coupling decision, fix phrasing). This is the textbook split.
- The biggest unrealised determinism win is a **coupling/dedup pass** (step 5): a script could group findings by file/function and merge obvious duplicates. The model currently does this in prose but is constraint-free on what counts as a "separate concern".
- A **static-analysis pre-flag** (step 4) on `forge-mcp` would shift the model from "find all bugs" to "rank and phrase these candidates" — close to the dispatching-parallel-agents pattern already used in `pr-review`.
- Auto-Clarity triggers (step 8) are uniquely enumerated and event-driven; a script could inspect the PR labels (`security`, `onboarding`) and auto-suppress terse mode for matching sections.
