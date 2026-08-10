---
name: conventional-commits
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/conventional-commits/SKILL.md
description: Format commits per Conventional Commits v1.0.0 spec. Load when writing any commit message.
---

# Conventional Commits

A lightweight convention on top of commit messages. Provides rules for explicit commit history, makes it easier to write automated tools on top of it. Dovetails with SemVer.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | SemVer | Description |
|------|--------|-------------|
| `fix` | PATCH | Patches a bug |
| `feat` | MINOR | Introduces a feature |
| `build` | — | Build system / external dependencies |
| `ci` | — | CI config / scripts |
| `docs` | — | Documentation only |
| `style` | — | Formatting, whitespace |
| `refactor` | — | Code change, no bug fix, no feature |
| `perf` | — | Performance improvement |
| `test` | — | Adding/correcting tests |
| `chore` | — | Other, no src/test modification |
| `revert` | — | Reverts a previous commit |

**SemVer impact — every commit has one.** The commit type tells CI/CD whether the next release bumps major, minor, patch, or nothing:

| Type | CI/CD effect | Example scenario |
|------|-------------|----------------|
| `fix` | **PATCH** — next release is `x.y.Z+1` | `fix(auth): accept tokens with trailing whitespace` |
| `feat` | **MINOR** — next release is `x.Y+1.0` | `feat(api): add user profile endpoint` |
| `feat!` / `fix!` | **MAJOR** — next release is `X+1.0.0` | `feat!: drop support for Node 16` |
| `BREAKING CHANGE:` | **MAJOR** — footer has same effect as `!` | `feat: allow config to extend other configs` + footer |
| `refactor` | **NONE** — no version bump | Internal cleanup, no behavior change |
| `docs` | **NONE** — no version bump | Documentation only |
| `style` | **NONE** — no version bump | Whitespace, formatting |
| `perf` | **NONE** — no version bump | Faster but no API change |
| `test` | **NONE** — no version bump | Adding tests only |
| `build` | **NONE** — no version bump | Build system, deps |
| `ci` | **NONE** — no version bump | CI config |
| `chore` | **NONE** — no version bump | Misc maintenance |
| `revert` | **NONE** — no version bump | `revert: let us never speak of the noodle incident` |

**Rule of thumb:** `feat` and `fix` bump versions. Everything else is metadata — it describes the change but does not release. `feat!` and `BREAKING CHANGE:` are the only paths to major.

**Accidental release guard:** if you don't want a release, don't use `feat` or `fix`. If you do want a release, `feat` or `fix` is mandatory — nothing else triggers one.

**Breaking Change:** `BREAKING CHANGE:` footer or `!` after type/scope introduces MAJOR version bump.

## Rules

1. Prefix: type + optional scope + optional `!` + colon + space.
2. `feat` for new features. `fix` for bug fixes.
3. Description immediately after colon + space.
4. Body MAY follow short description (blank line separator).
5. Footers MAY follow body (blank line separator).
6. Breaking changes MUST use `!` in prefix or `BREAKING CHANGE:` footer.
7. `BREAKING CHANGE` footer MUST be uppercase.

## Examples

```
feat: send email to customer when product is shipped
feat(api)!: rename /v1/orders to /v1/checkout

feat: allow config to extend other configs
BREAKING CHANGE: `extends` key now used for config extension

revert: let us never again speak of the noodle incident
Refs: 676104e, a215868
```