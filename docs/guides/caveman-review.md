# caveman-review

Ultra-compressed code review comments that cut noise from PR feedback while preserving actionable signal. Each comment is one line: location, problem, fix.

## When to load

- User says "review this PR", "code review", "review the diff", "/review", or invokes `/caveman-review`
- Auto-triggers when reviewing pull requests (forge step 7: `Skill(skill='pr-review')` runs in PR mode and posts review in caveman-review format)
- When you need terse, actionable review output without throat-clearing

## How it works

1. **Parse the diff** — identify file, line numbers, and changed code
2. **Apply format** — `L<line>: <problem>. <fix>.` or `<file>:L<line>: ...` for multi-file diffs (SKILL.md:14-15)
3. **Add severity prefix** when mixed findings:
   - `🔴 bug:` — broken behavior, will cause incident
   - `🟡 risk:` — works but fragile (race, missing null check, swallowed error)
   - `🔵 nit:` — style, naming, micro-optim. Author can ignore
   - `❓ q:` — genuine question, not a suggestion (SKILL.md:17-21)
4. **Drop noise** — no "I noticed that...", "You might want to consider...", hedging, or restating the diff (SKILL.md:23-28)
5. **Keep signal** — exact line numbers, symbol names in backticks, concrete fix, *why* if not obvious (SKILL.md:30-33)
6. **Auto-clarity exceptions** — drop terse mode for security findings (CVE-class), architectural disagreements, or onboarding contexts; write normal paragraph then resume terse (SKILL.md:35-37)
7. **Output** — comments ready to paste into PR; does not write fixes, approve, request-changes, or run linters (SKILL.md:39-40)

## Files in this skill

- `skills/caveman-review/SKILL.md` — Main skill definition: format rules, severity prefixes, examples, boundaries

## See also

- `Skill(skill='forge')` — Orchestrator that invokes caveman-review in step 7 (`Skill(skill='pr-review')` posts review in this format) and step 8 (`Skill(skill='pr-resolve')` consumes its output)
- `Skill(skill='caveman')` — Default communication mode (ultra) active every session; caveman-review follows same terseness conventions
- `Skill(skill='pr-review')` — Runs `kimi -p` loop via `Skill(skill='loops')`, posts ONE review under authenticated identity in caveman-review format
- `Skill(skill='pr-resolve')` — Consumes `Skill(skill='pr-review')` output; one resolver per finding group in its own worktree

## Notes

- No scripts or templates in this skill — only the SKILL.md file
- The skill references "caveman suite conventions" but no separate suite documentation exists in the repo
- Auto-trigger condition "invokes /caveman-review" implies a slash command; no command registration found in source