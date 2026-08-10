# conventional-commits

A reference and formatting guide that makes every commit message follow the Conventional Commits v1.0.0 specification — `<type>[optional scope]: <description>` with optional body and footers — so the history is explicit, machine-parseable, and dovetailed with SemVer: `fix` bumps PATCH, `feat` bumps MINOR, and `!` or a `BREAKING CHANGE:` footer bumps MAJOR.

## When to load

- Writing **any** commit message (frontmatter: "Load when writing any commit message", `skills/conventional-commits/SKILL.md:3`)
- Forge squash-merges task worktrees into the feat branch as "one natural Conventional Commit per subagent" (`skills/forge/SKILL.md:67`), so load it before authoring those squash commits
- Deciding whether a commit should trigger a release — the skill's "Accidental release guard" rule: no `feat`/`fix` means no release; wanting a release makes `feat`/`fix` mandatory
- Marking breaking changes: choose between `!` after type/scope or an uppercase `BREAKING CHANGE:` footer

## How it works

1. **Pick the type** from the type table (`skills/conventional-commits/SKILL.md:14-26`): `feat` (MINOR) or `fix` (PATCH) for releasable changes; `build`, `ci`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `revert` for non-releasing metadata.
2. **Check SemVer impact** against the second table (`SKILL.md:30-45`). Rule of thumb (`SKILL.md:47`): only `feat` and `fix` bump versions; `feat!`/`fix!` and `BREAKING CHANGE:` are the only paths to MAJOR.
3. **Format the message** per the grammar (`SKILL.md:9-14`): `<type>[optional scope]: <description>`, blank line, optional body, blank line, optional footer(s).
4. **Apply the seven rules** (`SKILL.md:52-59`): colon+space after the prefix; description immediately after; body and footers separated by blank lines; breaking changes MUST use `!` in the prefix or an uppercase `BREAKING CHANGE:` footer.
5. **Sanity-check against the examples** (`SKILL.md:63-82`), e.g. `feat(api)!: rename /v1/orders to /v1/checkout` or a `revert:` with a `Refs:` footer.

The skill is a single self-contained `SKILL.md`; there are no scripts or templates to invoke.

## Files in this skill

- `skills/conventional-commits/SKILL.md` — the entire skill: format grammar, type tables, SemVer mapping, seven formatting rules, and worked examples.

## See also

- `forge` — orchestrator whose Work step requires every squash-merge to land as one natural Conventional Commit (e.g. `feat(api): add user profile endpoint`, not `ticket-1`).

## Notes

- The frontmatter `source:` field points to `https://github.com/weselben/RooForge/tree/main/skills/conventional-commits` — an upstream origin, not a local path; it is not used by any step in the skill.
- The skill defines no trigger keywords beyond "any commit message"; it relies on the harness/forge to load it at commit time rather than matching phrases.
