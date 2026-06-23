---
name: conventional-commits
description: >
  Conventional Commits v1.0.0 specification reference — commit message format,
  types, SemVer mapping, breaking changes, scope rules, and revert conventions.
  Load when creating any git commit message.
---

# Conventional Commits

A specification for adding human and machine readable meaning to commit messages.

## Summary

The Conventional Commits specification is a lightweight convention on top of commit messages. It provides an easy set of rules for creating an explicit commit history, which makes it easier to write automated tools on top of. This convention dovetails with SemVer, by describing the features, fixes, and breaking changes made in commit messages.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types and SemVer Impact

| Type | SemVer | Description |
|------|--------|-------------|
| `fix` | PATCH | A commit that patches a bug in the codebase |
| `feat` | MINOR | A commit that introduces a new feature |
| `build` | — | Changes that affect the build system or external dependencies |
| `ci` | — | Changes to CI configuration files and scripts |
| `docs` | — | Documentation only changes |
| `style` | — | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.) |
| `refactor` | — | A code change that neither fixes a bug nor adds a feature |
| `perf` | — | A code change that improves performance |
| `test` | — | Adding missing tests or correcting existing tests |
| `chore` | — | Other changes that don't modify src or test files |
| `revert` | — | Reverts a previous commit |

**Breaking Change:** A commit with `BREAKING CHANGE:` footer, or `!` after type/scope, introduces a breaking API change (MAJOR in SemVer). Breaking changes can be part of commits of any type.

## Scope

A scope may be provided after a type to provide additional contextual information: `feat(parser): add ability to parse arrays`. A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis.

## Rules

1. Commits MUST be prefixed with a type followed by optional scope, optional `!`, and required colon + space.
2. `feat` MUST be used when a commit adds a new feature.
3. `fix` MUST be used when a commit represents a bug fix.
4. Description MUST immediately follow the colon and space after type/scope prefix.
5. A longer commit body MAY be provided after the short description, separated by one blank line.
6. One or more footers MAY be provided one blank line after the body.
7. Breaking changes MUST be indicated in type/scope prefix (`!`) or as footer (`BREAKING CHANGE:`).
8. Types other than `feat` and `fix` MAY be used (e.g., `docs:`, `chore:`, `refactor:`).
9. BREAKING CHANGE MUST be uppercase when used as footer token.

## Breaking Changes

### Via `!` suffix
```
feat!: send email to customer when product is shipped
```

### Via `!` with scope
```
feat(api)!: send email to customer when product is shipped
```

### Via footer
```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Both `!` and footer
```
feat!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

## Revert Commits

Use `revert` type with a footer referencing commit SHAs:
```
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

## Examples

### No body
```
docs: correct spelling of CHANGELOG
```

### With scope
```
feat(lang): add Polish language
```

### Multi-paragraph body with footers
```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

## Why Use Conventional Commits

- Automatically generating CHANGELOGs
- Automatically determining a semantic version bump (based on commit types)
- Communicating the nature of changes to teammates, the public, and other stakeholders
- Triggering build and publish processes
- Making it easier for people to contribute to your projects

## Forge Integration

- **Mode**: Loaded by `git` mode via `skill` tool (after forge skill)
- **Trigger**: Load on-demand whenever `/git` is invoked for commit message creation
- **Usage**: Reference this skill's format and rules when constructing `git_commit` messages
- **Complement**: Pipeline-specific enforcement lives in `rules/git/mandatory-commit-guardrail.md` — this skill provides the general specification
