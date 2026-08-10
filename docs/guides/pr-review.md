# pr-review

Review a GitHub PR or local branch inside an isolated worktree — deterministic hard-rule validation (secret patterns, diff sanity) then a `kimi -p` review loop producing caveman-review findings. PR mode posts ONE review under the authenticated user's identity; local mode returns findings to a scratch file for the calling orchestrator's fix loop.

## When to load

- "review this PR", "review <repo>#<n>", "PR review", "review branch <name>"
- Forge step 7: after `verification-before-completion` passes, `pr-review` runs in PR mode
- Forge/issue Phase-5-style reviews in local mode for non-GitHub branches

## How it works

1. **WORKTREE** — `using-git-worktrees` Step 0. If already isolated on PR head, stay; otherwise `gh pr checkout <n>` (metadata only) and create `.worktrees/pr-<n>-review/` on a branch tracking PR head (SKILL.md:18-19).
2. **VALIDATE** — `scripts/validate.sh <diff-file>` where `<diff-file>` comes from `gh pr diff <n>`. Scans added lines only for secret patterns (private keys, API keys, bearer tokens, passwords, private IPv4) and diff sanity. Prints `PASS:`/`FAIL:` lines; exit 0 always (SKILL.md:19-20, `scripts/validate.sh:1-39`).
3. **REVIEW** — `scripts/review-loop.sh <pr-ref> <worktree> [max_iter=5]`. Renders `scripts/templates/review-loop.md` via `../loops/scripts/cavemanize.sh`, drives `../loops/scripts/run_loop.sh`. Reviewer loads `caveman-review` + `verification-before-completion` + `using-git-worktrees`; writes findings to `${TMPDIR:-/tmp}/pr-review-<n>.md` — scratch, never committed (SKILL.md:20-21, `scripts/review-loop.sh:1-38`, `scripts/templates/review-loop.md:1-22`).
4. **POST (PR mode only)** — Submit ONE review with inline comments:
   - Get head SHA: `HEAD_SHA=$(gh pr view <n> --json headRefOid --jq '.headRefOid')` (SKILL.md:22)
   - `gh api repos/{owner}/{repo}/pulls/<n>/reviews --method POST` with inline comments JSON (`{path, line, side: "RIGHT", body}`) plus top-level summary body (SKILL.md:22-24)
   - Author identity from `gh api user -q .login` — never bot/agent self-branding (SKILL.md:24)
   - Fallback: `gh pr review <n> --comment --body-file <scratch>` + per-finding `gh api .../comments` for inline visibility (SKILL.md:24-25)
   - Group findings by file; delete scratch file after (SKILL.md:25)
5. **HANDOFF** — Report review URL, counts by severity, next step (`pr-resolve` for 🔴/🟡). Clean up review worktree via `using-git-worktrees` (SKILL.md:25-26).

**Done when:** review URL returned (inline comments visible in PR Files tab), scratch file deleted, worktree removed (SKILL.md:26).

## Files in this skill

- `skills/pr-review/SKILL.md` — Main skill definition: two-phase pipeline, two modes, hard rules, boundaries
- `scripts/validate.sh` — Deterministic hard-rule pass: secret patterns + diff sanity on added lines only; prints `PASS:`/`FAIL:`; exits 0 always
- `scripts/review-loop.sh` — Drives `kimi -p` loop via `loops`; renders template, runs `run_loop.sh`; supports PR mode (`owner/repo#n`) and local mode (`branch/slug`)
- `scripts/templates/review-loop.md` — The `kimi -p ""` payload: mandatory skill loads, no-plan-mode, mode-aware diff reading, `DONE:`/`BLOCKED:` contract
- `templates/review-loop.md` — High-level review loop description: steps 1-4 (read diff, run validate, review diff, emit contract)

## See also

- `forge` — Orchestrator step 7 runs `pr-review` in PR mode; step 8 runs `pr-resolve` to consume findings
- `pr-resolve` — Consumes `pr-review` output; one resolver per finding group in its own worktree off PR head
- `caveman-review` — Finding format: `<file>:L<line>: 🔴|🟡|🔵|❓ <problem>. <fix>.`; all posted text goes through `ste100`
- `verification-before-completion` — Loaded by reviewer; verifies claimed state against actual output
- `using-git-worktrees` — Mandatory worktree isolation; reviewer never leaves the worktree
- `loops` — Single home for all `kimi -p` iteration (`cavemanize.sh`, `run_loop.sh`); used by `pr-review` and `pr-resolve`
- `ste100` — Public GitHub text formatting; applied to all findings in posted review

## Notes

- The `templates/review-loop.md` file appears to be a higher-level description (steps, constraints) while `scripts/templates/review-loop.md` is the actual `kimi -p` prompt payload — both exist with similar content but different detail levels
- `scripts/validate.sh` checks added lines only; deletion-only diffs yield "PASS: no added lines"
- Reviewer never modifies code, never approves/requests-changes (`--comment` only), never replaces CI
- Local mode diff uses `git diff <base>...HEAD` where `<base>` is the integration branch (dev/feat/fix, never main) per `scripts/templates/review-loop.md:2`
- `ste100` skill is referenced for public GitHub text but not explicitly loaded in templates — relies on implicit convention