---
name: Bug Report
about: Report unexpected behavior in a skill
title: "fix(<skill-name>): <brief description>"
labels: bug, triage
assignees: ''
---

## 🐛 Bug Description

A clear description of what the unexpected behavior is.

## 🤖 Affected Skill

Skill path (e.g. skills/wayfinder/SKILL.md):

Which area does the affected skill belong to? Check all that apply:

- [ ] Orchestration flow (forge, forge-flow, loops)
- [ ] Communication (caveman, caveman-commit, caveman-review, ste100, conventional-commits)
- [ ] Planning (wayfinder, grilling, prototype, deep-research, planning-and-task-breakdown, domain-modeling)
- [ ] Execution (using-git-worktrees, subagent-driven-development, dispatching-parallel-agents, finishing-a-development-branch, verification-before-completion, pr-review, pr-resolve, creating-pull-requests, resolving-merge-conflicts, use-git-identity)
- [ ] Bootstrap (forge-init, forge-setup, forge-docs, forge-cleanup, git-issue-tracker)
- [ ] Sidecars (12-factor-app, kiss-principle, frontend-design, forge-tailwindcss-conventions, forge-eu-accessibility, forge-seo)

## 📋 Steps to Reproduce

1. Load the skill in your harness (Kimi Code CLI: `/skill:<name>`)
2. Provide the following prompt: _'...'_
3. Observe the behavior at step...
4. ...

## ✅ Expected Behavior

What did you expect the skill to do according to the skill's SKILL.md contract?

## ❌ Actual Behavior

What actually happened? Include any relevant output or observed behavior.

## 🔗 Flow Impact

Does this affect the forge flow? If so, how?

- [ ] Blocks other skills from functioning
- [ ] Produces incorrect output that propagates into the forge flow
- [ ] Breaks the skill's own contract (trigger, procedure, boundaries)
- [ ] No flow impact — isolated issue

## 📎 Context

- **Harness (e.g. Kimi Code CLI) and version:**
- **Skill file version/commit:**
- **Other skills loaded during the session:**

## 📝 Additional Information

Any other context, logs, or screenshots that help explain the issue.
