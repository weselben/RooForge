# Git Commit Guardrails

## Use `/git` First

Whenever this rule applies, load `/git` before branch checks, staging review, or commits run_slash_command with the command `git`

Use the loaded `/git` workflow for branch setup, MCP/CLI fallback, staging review, and commit creation. This file enforces commit-subject quality only; it does not duplicate `/git`.

## Mandatory Commit Shape

Commit subjects must use:

```
type(scope): subject
```

Subject rules:

- Use imperative mood.
- Keep the subject at or below 72 characters.
- End with no trailing period.
- Use a project-area scope.

## DO

- Put one logical change in one commit.
- Use imperative mood in every subject.
- Use a project-area scope `type:(project-area scope):subject` that matches the files changed.
- Split unrelated files into separate commits.
- Use `docs:` only when the commit changes documentation without changing any code.

## MANDATORY DON'T

- Do not use pipeline jargon in commit subjects or branches.
- Do not mention Forge pipeline internals in commit subjects or branches.
- Do not use these or similiar terms in commit subjects or branches: `phase 2`, `phase N`, `blueprint`, `context envelope`, `state of intel`.
- Do not mix unrelated concerns in one commit.
- Do not use broad or vague scopes when a project-area scope applies.
- Do not expose internal orchestration state in commit messages.
- Do not expose internal phase numbers or blueprint artifacts like descripted above

## Anti-Pattern

Bad commit:

```
docs: enforce phase 2 guardrails and add deep research docs and fix web table syntax
```

Why rejected:

- The subject contains Forge pipeline (blueprint) phase artifact `phase 2`.
- The subject mixes documentation updates, and code syntax fixes.
- The commit touched documentation, project configuration, and code behavior files; split those concerns by project area and logical concern in propper conventionel commits.
- The type `docs` hides code behavior changes.

## Good Example

```
feat(commands): add memory override for deep-research
```

Why accepted:

- Subject uses `type(scope): subject`.
- Subject is imperative.
- Subject is under 72 characters.
- Subject has no trailing period.
- Scope `commands` matches code-area behavior.
- Commit should contain only the memory override change for the relevant command files.
- Subject contains no blueprint artifacts or Forge pipeline mentions.
