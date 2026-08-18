# Contributing to RooForge

First off, thank you for your interest in this project! We appreciate the community's involvement and welcome contributions that improve the forge orchestration flow.

## ⚠️ Important: Pull Request Policy

**We do not generally accept pull requests.** This repository maintains a carefully curated skill collection where each skill is designed to work in concert with the others. Before any PR is considered, it must go through the following process:

1. **Testing** - You must thoroughly test your changes by loading the changed skill in the Kimi Code CLI (slash command `/skill:<name>`) or another harness and exercising its trigger.
2. **Evaluation** - We evaluate whether the change actually benefits the intended workflow and orchestration pattern. Changes that introduce inconsistency, break the flow, or deviate from the design philosophy will not be accepted.
3. **Review** - If the change passes testing and evaluation, we will review the implementation details.

If your contribution passes all three stages, we will work with you to merge it.

## 🛠️ How to Contribute

### 1. Fork & Branch

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/weselben/RooForge.git
cd RooForge

# Create a feature branch (see Branch Naming below)
git checkout -b feat/my-new-feature
```

### 2. Branch Naming

Use descriptive feature branches with a conventional prefix:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feat/` | New skill or skill feature | `feat/new-skill-name` |
| `fix/` | Bug fix | `fix/forge-step-order` |
| `docs/` | Documentation changes | `docs/update-installation-guide` |
| `refactor/` | Skill refactoring | `refactor/wayfinder-ticket-rules` |
| `chore/` | Maintenance tasks | `chore/update-workflow` |

> Branch descriptions must use **technical language only**.

### 3. Make Your Changes

- Edit the relevant `skills/<name>/SKILL.md` (and its companion files)
- Ensure the YAML frontmatter is valid (`name` + `description` required)
- Load the changed skill in the Kimi Code CLI (`/skill:<name>`) or another harness and exercise its trigger within the full flow context

### 4. Commit with Conventional Commits (Extended)

We follow the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/) specification with extended types:

```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

#### Required Format

```
feat(wayfinder): add blocking-edge wiring pass

Wayfinder tickets can now declare blocking edges between map
nodes; the wiring pass links each ticket to the tickets it
blocks so the frontier query surfaces only unblocked work.

Closes #42
```

#### Commit Types

| Type | Description | Version Impact |
|------|-------------|---------------|
| `feat` | A new feature | **Minor** bump |
| `fix` | A bug fix | **Patch** bump |
| `feat!` or `BREAKING CHANGE:` | Breaking change | **Major** bump |
| `docs` | Documentation only | None |
| `style` | Formatting, whitespace | None |
| `refactor` | Code restructuring (no behavior change) | None |
| `perf` | Performance improvements | None |
| `test` | Adding or updating tests | None |
| `build` | Build system or dependencies | None |
| `ci` | CI/CD changes | None |
| `chore` | Maintenance, tooling | None |
| `revert` | Reverts a previous commit | None |

#### Tips

- **Use the imperative mood** in the subject: `add feature` not `added feature`
- **Reference issues** in the footer: `Closes #12` or `Refs #34`
- **Keep subjects under 72 characters**
- **Separate subject from body** with a blank line

### 5. Push & Open a Pull Request

```bash
git push origin feat/my-new-feature
```

Then open a PR against the `main` branch on GitHub. Your PR description should include:

- **What** you changed and why
- **How** you loaded and exercised the skill
- **Which skills** are affected
- **Any cross-skill implications** - does this change affect how skills reference each other?

## ✅ Testing Checklist

Before submitting a PR, verify:

- [ ] The YAML frontmatter is valid (`name` + `description` required)
- [ ] The frontmatter `description` states when to invoke the skill (triggers, situations, keywords)
- [ ] The body states what the skill does
- [ ] Per-skill commit - one scope per commit, per `AGENTS.md`
- [ ] `README.md` skills table and `docs/guides/<skill>.md` updated when public behavior changed
- [ ] No stale references to other harnesses

## 📋 Code of Conduct

Be respectful, constructive, and professional. We're all here to build something useful together.

## ❓ Questions?

Feel free to [open an issue](https://github.com/weselben/RooForge/issues/new) for questions, suggestions, or discussions before investing time in a PR.

---

## The Forge Flow

This repository curates the forge orchestration flow: map → resolve → plan → work → verify → review → resolve. The entry point is the **forge** skill at `skills/forge/SKILL.md`; the `README.md` section **The Flow** describes the full orchestration. Read both before proposing changes to how skills reference each other.

---

Thank you for contributing! 🎯
