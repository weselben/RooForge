# creating-pull-requests

Writes size-gated pull request descriptions that manage reviewer attention: orient the reviewer in 30 seconds, answer "what changed, why, and where do I start reading?" before they open the diff. Enforces draft-only creation, mandatory generic AI disclosure, STE100 prose, and a section budget locked to the diff size.

## When to load

- Trigger phrases (SKILL.md:4): "create a PR", "open a pull request", "update PR description"
- Pushing a branch with PR intent
- Forge step 5 (PR) invokes it explicitly — draft mode, AI disclosure — and requires updating the PR description after each squash commit lands (`skills/forge/SKILL.md:106-110`)
- `Skill(skill='pr-review')` and `Skill(skill='pr-resolve')` both load `Skill(skill='ste100')`, the prose skill this one depends on

## How it works

1. **Detect and gather** (`SKILL.md:23-37`). Check for an existing PR with `gh pr view --json number,title,body,baseRefName,url`, then read the actual branch state: `git diff $BASE...HEAD` (full diff), `git diff $BASE...HEAD --stat` (shape), `git log $BASE..HEAD --oneline` (commits). Search for supporting evidence instead of asking the user.

2. **Classify by size gate** (`SKILL.md:39-48`). Lock the section budget from the `git diff --stat` line count before writing:
   - Small (< 50 lines): TL;DR only
   - Medium (50–200): TL;DR + files table + ≤2 more sections
   - Large (200+): all applicable sections; files table and Reviewer notes mandatory

3. **Draft the description.** Title is active voice, present tense, full scope, capped at 2 consecutive nouns (`SKILL.md:85-88`). TL;DR is exactly two sentences — first the problem with a concrete number/error/example, then what the PR does (`SKILL.md:90-91`). Only sections that earn their space for this size: Why, How, Reviewer notes, Visual aids, Tests, Follow-up, Links (`SKILL.md:99-110`). The "Cut these every time" list bans file-by-file narration, implementation play-by-play, commit-message archaeology, and diff echoing (`SKILL.md:112-121`).

4. **Load `Skill(skill='ste100')` before drafting** — a critical rule (`SKILL.md:17`). Its rules govern every sentence.

5. **Post-generation review** (`SKILL.md:58-68`). Re-read the diff; for each sentence cut anything the diff already says, rewrite weak openers ("This PR", "This change"), verify sections earn their space, confirm the AI disclosure closes the body.

6. **Apply via file, never inline** (`SKILL.md:70-82`). Write the body to a temp file and use `gh pr create --draft --title "..." --body-file /tmp/pr-body.md` or `gh pr edit <number> --title "..." --body-file /tmp/pr-body.md`. Never pass the body via HEREDOC or `--body`.

7. **Pass the reviewer-friendliness checklist** (`SKILL.md:138-151`): disclosure in place, size gate honored, title scope/voice/noun-stack, TL;DR concrete, no weak openers, no diff echoing, "start here" marked (medium+), focus area explicit, visual aids only where faster, 6-month test.

**Critical rules** (`SKILL.md:15-19`): always `--draft` (the user marks ready); end every body with `---` + `_This PR description was generated with AI assistance._` — generic, no agent/model/tool named; STE100 prose; size gate before drafting.

## Files in this skill

- `skills/creating-pull-requests/SKILL.md` — Main definition: critical rules, 4-step flow, size gate, title/TL;DR contracts, section and cut lists, checklist, two worked examples (212 lines).
- `skills/creating-pull-requests/PR-EXAMPLES.md` — Companion with the complete body template and three worked examples: medium retry-config feature, large Kafka-to-NATS migration, small docs-only PR (202 lines). Load when drafting medium/large PRs per `SKILL.md:211`.

## See also

- `Skill(skill='ste100')` — Mandatory prose layer; loaded before every draft and governs every sentence (`SKILL.md:17`).
- `Skill(skill='forge')` — Orchestrator; invokes this skill in step 5 and mandates PR-description updates after each squash commit.
- `Skill(skill='pr-review')` — Reviews the PR this skill produces; posts one caveman-review format review per PR.
- `Skill(skill='pr-resolve')` — Consumes `Skill(skill='pr-review')` findings on the PR and pushes fixes to its head branch.
- `Skill(skill='verification-before-completion')` — Forge step 6; runs the full suite on the merged feat branch before review.

## Notes

- Frontmatter attributes the skill to an external source (`tdhopper/dotfiles2.0`); the skill is an adapted copy, not original to this repo.
- No scripts or executable templates ship with this skill — only the two markdown files.
