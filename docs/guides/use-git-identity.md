# use-git-identity

Sets the git author/committer identity (name: `weselben`, email: `bengottwaldi04@gmail.com`) before any commit, amend, or rebase. Applies repo-local config on first commit in a repo; uses `-c` flags for one-off operations.

## When to load

- Before any `git commit`, `git commit --amend`, or interactive rebase
- When `Skill(skill='pr-resolve')` dispatches resolver subagents (each loads this skill before its first commit)
- When `Skill(skill='forge-init')` checks repo ownership
- When a commit fails with "author identity unknown" — indicates this skill was skipped

## How it works

1. **First commit in a fresh repo** — set repo-local identity (never `--global` unless explicitly asked):
   ```bash
   git config user.name "weselben"
   git config user.email "bengottwaldi04@gmail.com"
   ```
   (From `skills/use-git-identity/SKILL.md:10-12`)

2. **One-off commit without touching config** — use `-c` flags:
   ```bash
   git -c user.name="weselben" -c user.email="bengottwaldi04@gmail.com" commit ...
   ```
   (From `skills/use-git-identity/SKILL.md:15-17`)

3. **Fix authorship of an existing commit** (amend with reset-author):
   ```bash
   git config user.name "weselben"
   git config user.email "bengottwaldi04@gmail.com"
   git commit --amend --reset-author --no-edit
   ```
   (From `skills/use-git-identity/SKILL.md:20-23`)

4. **Rewrite pushed history** — force-push with lease, confirm with user first:
   ```bash
   git push --force-with-lease
   ```
   (From `skills/use-git-identity/SKILL.md:25-26`)

## Files in this skill

- `skills/use-git-identity/SKILL.md` — Canonical skill definition: identity values, apply/amend/force-push commands, and boundaries

## See also

- `Skill(skill='pr-resolve')` — Dispatches resolver subagents; each loads `Skill(skill='use-git-identity')` before its first commit (`skills/pr-resolve/SKILL.md:17`, `skills/pr-resolve/templates/resolve-loop.md:10`)
- `Skill(skill='forge-init')` — Loads `Skill(skill='use-git-identity')` to verify repo ownership matches configured identity (`skills/forge-init/SKILL.md:20`)
- `Skill(skill='forge')` — Orchestrator; step 8 (Resolve findings) notes commits happen "under `Skill(skill='use-git-identity')`" (`skills/forge/SKILL.md:85`)
- `Skill(skill='conventional-commits')` — Often loaded alongside; governs commit message format once identity is set
- `Skill(skill='caveman-commit')` — Often loaded alongside; governs commit body style

## Notes

- Only one file exists in the skill directory (`SKILL.md`); no scripts or templates.
- The skill references "this machine" identity hardcoded as `weselben` / `bengottwaldi04@gmail.com` — not parameterized.
- Boundary rule: a failed `git commit` from missing identity means the skill was skipped (SKILL.md:30-31).