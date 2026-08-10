# caveman-commit

Ultra-compressed commit message generator. Produces Conventional Commits format messages with a terse imperative subject (≤50 chars, hard cap 72) and a body only when the *why* isn't obvious from the diff — for breaking changes, security fixes, data migrations, reverts, or non-obvious reasoning. Strips fluff: no first-person, no AI attribution, no emoji, no restating what the diff already shows.

## When to load

- User says: "write a commit", "commit message", "generate commit", "/commit", or invokes `/caveman-commit`
- Auto-triggers when staging changes (skill description)
- Forge mandates `caveman` (ultra) as default for all responses; commit messages follow their own skill format (forge/SKILL.md:5-6, 147)

## How it works

1. **Analyze the diff** — identify type (`feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`), optional scope, and the core change
2. **Write subject** — `<type>(<scope>): <imperative summary>` (imperative mood: "add", "fix", "remove"; no trailing period; ≤50 chars preferred, 72 max) — SKILL.md:10-15
3. **Decide on body** — skip if subject is self-explanatory; add body only for: non-obvious *why*, breaking changes, migration notes, linked issues — SKILL.md:17-20
4. **Format body** — wrap at 72 chars, use `-` bullets, reference issues at end (`Closes #42`, `Refs #17`) — SKILL.md:19-20
5. **Output** — return as a code block ready to paste; does not run `git commit`, stage files, or amend — SKILL.md:48-49

## Files in this skill

- `skills/caveman-commit/SKILL.md` — Main skill definition: rules, examples, boundaries, auto-clarity rules

## See also

- `caveman` — Default communication mode (ultra) mandated by forge; caveman-commit uses the same terseness philosophy for commit messages specifically
- `forge` — Orchestrator that mandates caveman(ultra) and enforces Conventional Commits for every squash commit (e.g., `feat(api): add user profile endpoint`) — forge/SKILL.md:5, 147
- `conventional-commits` — Specification reference for commit types, SemVer mapping, breaking-change syntax (`!`), and trailer conventions

## Notes

- No scripts, templates, or companion files exist in the skill directory beyond `SKILL.md`
- The skill explicitly forbids AI attribution trailers unless the user's own rules require `Assisted-by` — SKILL.md:24-25
- "stop caveman-commit" or "normal mode" reverts to verbose commit style — SKILL.md:49