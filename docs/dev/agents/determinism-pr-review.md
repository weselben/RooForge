# Determinism sampling — pr-review

Sampling pass per ADR 0004. Raw stdout at `.tmp-determinism/logs/pr-review.log` (gitignored).

## Sample

- **Task:** local-mode review of one-line diff `+export function foo(){ return 1; }`.
- **Run:** `kimi -p` on 2026-08-18T01:30:06Z, exit 0, 48 lines.
- **Outcome:** correctly identified VALIDATE as shell-deterministic, REVIEW as model-in-loop, POST as skipped in local mode, HANDOFF as shell-only return. Produced the exact `gh api .../reviews --method POST` call shape with `comments[]` inline payload.

## Observed meta-decisions

- Noted that **local mode skips POST entirely** — that's a judgment-light branch on `target` arg.
- Produced the caveman-review format with severity prefixes, matching the skill.
- Did **not** modify files.

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | WORKTREE — `using-git-worktrees` step 0 + create `.worktrees/pr-<n>-review/` | none in local mode (reuse); trivial in PR mode (`gh pr view --json headRefName,headRefOid`) | full | **Node wrapper** around `git worktree add`, called by the review-loop orchestrator. | input: `pr_number`, `head_sha`; output: `worktree_path`; gate: `git worktree list` shows entry. |
| 2 | VALIDATE — `scripts/validate.sh <diff-file>` | none — regex hard rules | full | **shell script as-is** (already a script). | stdin: diff path; stdout: `PASS:`/`FAIL:` lines; exit 0 always. |
| 3 | REVIEW — `scripts/review-loop.sh` → `loops` → `kimi -p` | high — what counts as a finding | loop plumbing | **Node wrapper + premade template** (`templates/review-loop.md`), per ADR 0005 #2. | input: diff path, pr_ref; output: scratch findings file; gate: `DONE:` or `BLOCKED:` from loop. |
| 4 | Parse findings into caveman-review format | none — format is fixed | full | covered by template; reviewer subagent emits the format. | one-liner per finding: `path:line 🔴/🟡/🔵/❓ problem — fix`. |
| 5 | POST — `gh api repos/.../pulls/<n>/reviews --method POST` with inline `comments[]` | none — typed API call | full | **MCP `forge_mcp.post_review(repo, pr_number, head_sha, body, comments[])`** — typed inputs, fallback to top-level + per-comment `gh api .../comments`. | input: typed; output: `{review_id}`; gate: review visible in PR timeline. |
| 6 | Identity check — `gh api user -q .login` | none | full | **MCP `forge_mcp.identify_user()`** — typed return. | output: `{login}`; gate: post body author == login. |
| 7 | HANDOFF — return URL, counts, next step; delete scratch | none | full | **shell** — deterministic. | output: structured handoff object; gate: scratch file gone. |

## Notes

- The two **shell-deterministic** phases (VALIDATE, worktree setup) are already scripts.
- The **model-in-loop** phase is a textbook Node-wrapper + premade template case (ADR 0005 #2).
- The **POST** step is a clear MCP candidate — it's a typed tracker operation that wraps a non-trivial `gh api` shape with an inline-comments payload.
- Local mode short-circuits the model loop entirely (no findings, just return) — that branch should be a Node flag, not a model decision.