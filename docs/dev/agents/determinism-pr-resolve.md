# Determinism sampling — pr-resolve

Sampling pass per ADR 0004. Raw stdout at `.tmp-determinism/logs/pr-resolve.log` (gitignored).

## Sample

- **Task:** resolve one finding `🔴 bug: src/user.ts L5: user can be null after .find(). Add guard before .email.`
- **Run:** `kimi -p` on 2026-08-18T01:30:06Z, exit 0, 43 lines.
- **Outcome:** correctly identified COLLECT/DISPATCH/INTEGRATE/PUSH+REPLY as mostly mechanical, the fix content as judgment, and the thread-reply call shape with comment-id from the COLLECT query. Produced the right caveman-commit subject.

## Observed meta-decisions

- Triaged the single finding as resolve (🔴), grouped as one group (trivial — only one finding).
- Generated the exact `gh api repos/.../pulls/comments/<comment-id>/replies` body shape with `<sha>` placeholder.
- Wrote `fix(user): guard null user before .email access` — Conventional Commits + scope.
- Did **not** modify files.

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | WORKTREE — `.worktrees/pr-<n>-resolve/` | none | full | **Node wrapper** around `git worktree add`. | input: `pr_number`; output: `worktree_path`. |
| 2 | COLLECT — `gh api repos/.../pulls/<n>/comments --paginate` + filter `in_reply_to_id == null and .position != null` | none — fixed query shape and filter | full | **MCP `forge_mcp.collect_review_comments(repo, pr_number, unresolved_only=true)`** — typed return with `{id, path, line, body, user}[]`. | input: `repo`, `pr_number`; output: comments[]; gate: only top-level inline unresolved. |
| 3 | Triage — severity → resolve/skip/answer | low — 🔴 always resolve; 🔵 resolve-if-trivial else skip; ❓ answer | mostly mechanical | **MCP `forge_mcp.triage_comments(repo, pr_number)`** returns the bucketed lists using the rule table. | input: `repo`, `pr_number`; output: `{resolve[], skip[], answer[]}`; gate: each comment in exactly one bucket. |
| 4 | Group by file/concern | medium — at scale this matters; trivial on one finding | trivial at small N | **MCP `forge_mcp.group_findings(comments[])`** — deterministic grouping (file → concern). | input: comments[]; output: groups[]; gate: every comment in exactly one group. |
| 5 | DISPATCH — `scripts/resolve-loop.sh` → swarm of resolvers | none at dispatch; the fix content is judgment | full dispatch shape | **Node wrapper + premade template** (`templates/resolve-loop.md`), per ADR 0005 #2. Swarm is parallel within a single `AgentSwarm` call. | input: groups[]; output: per-group resolver report; cap 10. |
| 6 | INTEGRATE — `git merge --no-ff` per group + run suite | none — `verification-before-completion` runs the suite | full | **Node wrapper** around `merge --no-ff` and the verification gate. | input: branches[]; output: merged sha; gate: suite green. |
| 7 | PUSH — to PR head only | none | full | **shell** — `git push origin <pr-head-branch>`. | exit 0 on push. |
| 8 | Reply — `gh api .../pulls/comments/<id>/replies -f body="Resolved in <sha> — <one-line>"` | one-line "what changed" wording (ste100) | full call shape | **MCP `forge_mcp.reply_to_review_thread(repo, comment_id, sha, one_line_what_changed)`** — typed. | input: typed; output: `{reply_id}`; gate: one reply per inline comment. |
| 9 | Summary — one top-level review body with counts | severity bucketing is mechanical; format fixed | full | **MCP `forge_mcp.post_review_summary(repo, pr_number, body)`** | input: typed; output: `{review_id}`; gate: summary visible. |
| 10 | CLEANUP — `git worktree remove` + `git branch -d` | none | full | **shell** — already a script. | exit 0 if worktree/branch gone. |

## Notes

- Two **strong MCP candidates**: `collect_review_comments` (typed query that paginates a complex `gh api` call) and `reply_to_review_thread` (typed thread reply with `<sha>` substitution).
- The **dispatch loop** itself is `loops`-driven → ADR 0007 Node migration covers it.
- Grouping is a judgment-light heuristic that scales; pinning it to "by file → by concern" with deterministic ordering (path, then line) makes it shell-replayable.
- The fix content (where to add the guard, early-return vs optional chaining) stays model — that's the resolver subagent's job.