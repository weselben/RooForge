# Contributing to RooForge

First off, thank you for your interest in this project! We appreciate the community's involvement and welcome contributions that improve the agent orchestration workflow.

## ⚠️ Important: Pull Request Policy

**We do not generally accept pull requests.** This repository maintains a carefully curated agent "stack" where each mode is designed to work in concert with the others. Before any PR is considered, it must go through the following process:

1. **Testing** - You must thoroughly test your changes by importing the modified YAML files into Roo Code and verifying that the mode behaves as expected within the full pipeline.
2. **Evaluation** - We evaluate whether the change actually benefits the intended workflow and orchestration pattern. Changes that introduce inconsistency, break the pipeline, or deviate from the design philosophy will not be accepted.
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
| `feat/` | New feature or mode | `feat/add-debug-mode` |
| `fix/` | Bug fix | `fix/orchestrator-pipeline-order` |
| `docs/` | Documentation changes | `docs/update-installation-guide` |
| `refactor/` | Code/mode refactoring | `refactor/simplify-ask-mode` |
| `chore/` | Maintenance tasks | `chore/update-workflow` |

### 3. Make Your Changes

- Edit the relevant `agents/*.yaml` file(s)
- Ensure YAML syntax is valid
- Test the mode in Roo Code within the full pipeline context

### 4. Commit with Conventional Commits (Extended)

We follow the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/) specification with extended types:

```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

#### Required Format

```
feat(architect): add support for multi-repo planning

Added ability for the Architect mode to handle cross-repository
blueprints by accepting multiple codebase contexts.

Closes #42
```

#### Commit Types

| Type | Description | Version Impact |
|------|-------------|---------------|
| `feat` | A new feature | **Minor** bump |
| `fix` | A bug fix | **Patch** bump |
| `feat!` or `BREAKING CHANGE` | Breaking change | **Major** bump |
| `docs` | Documentation only | None |
| `refactor` | Code restructuring (no behavior change) | None |
| `chore` | Maintenance, tooling, CI | None |
| `test` | Adding or updating tests | None |
| `style` | Formatting, whitespace | None |
| `perf` | Performance improvements | None |
| `ci` | CI/CD changes | None |

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
- **How** you tested the change in Roo Code
- **Which modes** are affected
- **Any pipeline implications** - does this change affect how modes interact?

## ✅ Testing Checklist

Before submitting a PR, verify:

- [ ] The modified YAML file(s) import successfully into Roo Code
- [ ] The mode activates and follows its role definition correctly
- [ ] The mode integrates properly with the other modes in the pipeline
- [ ] No YAML syntax errors or broken references
- [ ] The change aligns with the orchestration philosophy of this stack

## 📋 Code of Conduct

Be respectful, constructive, and professional. We're all here to build something useful together.

## ❓ Questions?

Feel free to [open an issue](https://github.com/weselben/RooForge/issues/new) for questions, suggestions, or discussions before investing time in a PR.

---

## 🔄 Simulated Agent Flow Walkthrough

To understand what each mode is expected to do, here is a complete walkthrough of an imaginary task flowing through the entire agent stack.

### Scenario: "Add a REST API endpoint for user preferences"

#### Phase 1 - Intel Acquisition (Ask Mode)

**Input from Orchestrator:** "Research what's needed to add a REST API endpoint for user preferences. Identify the current project stack, existing API patterns, and any relevant libraries."

**What Ask does:**
1. Searches the codebase for existing API route definitions (e.g., `routes/`, `controllers/`)
2. Identifies the framework in use (e.g., Express, Fastify, Hono)
3. Searches the web for best practices and the framework's latest API patterns
4. Checks `.memory/` for any previously cached intel
5. Examines existing authentication middleware and database models

**Output - "State of Intel" Report:**
```
STATE OF INTEL - User Preferences API Endpoint
================================================
Framework: Express.js v4.18 (package.json line 12)
Existing pattern: /api/v1/* routes in src/routes/
Auth middleware: requireAuth() from src/middleware/auth.js
Database: PostgreSQL via Prisma ORM (schema.prisma)
Existing model: User model exists, no Preferences model
Relevant files:
  - src/routes/index.js (route registry)
  - src/middleware/auth.js
  - prisma/schema.prisma
  - src/controllers/userController.js
Constraints:
  - All routes require authentication
  - API follows RESTful conventions
  - Response format: { success: boolean, data: any, error?: string }
Sources: codebase analysis, Express.js docs (https://expressjs.com/en/4x/api.html)
```

#### Phase 2 - Architectural Grounding (Architect Mode)

**Input from Orchestrator:** The full Master Context Package (original request + complete State of Intel + constraints).

**What Architect does:**
1. Analyzes the intel to understand the existing architecture
2. Designs the new endpoint following established patterns
3. Breaks the work into phases with individual tasks using /blueprint
4. Defines verification criteria and checkpoints for each phase

**Output - "Blueprint":**
```
BLUEPRINT - User Preferences API Endpoint
==========================================

Phase 1: MVP — Database & Core API
  Checkpoint: Preferences model exists, API responds to GET requests

  Task 1.1: Database Schema & Migration
    Description: Create the Preferences model and migration
    Acceptance criteria:
      - Prisma model defines all required fields
      - Migration runs without errors
    Verification: Prisma migrate succeeds, model is queryable
    Dependencies: None
    Files likely touched: prisma/schema.prisma, migration file
    Scope: S

  Task 1.2: API Route & Controller
    Description: Implement GET/PUT /api/v1/user/preferences
    Acceptance criteria:
      - GET returns user preferences
      - PUT updates user preferences
      - Auth middleware applied
    Verification: Route responds to requests, auth middleware applied
    Dependencies: Task 1.1 (model must exist)
    Files likely touched: src/routes/preferences.js, src/controllers/preferencesController.js
    Scope: M

Phase 2: Robustness — Validation & Error Handling
  Checkpoint: Invalid input is properly rejected, errors are handled

  Task 2.1: Input Validation & Error Handling
    Description: Add validation middleware and error responses
    Acceptance criteria:
      - Invalid input returns 400 with descriptive message
      - Valid input passes through
    Verification: Invalid input returns 400, valid input passes through
    Dependencies: Task 1.2 (route must exist)
    Files likely touched: src/middleware/validatePreferences.js
    Scope: S

Phase 3: Quality — Tests & Documentation
  Checkpoint: All tests pass, docs are up to date

  Task 3.1: Tests & Documentation
    Description: Write integration tests and update API docs
    Acceptance criteria:
      - Integration tests cover GET and PUT
      - API docs reflect new endpoint
    Verification: Tests pass, docs reflect new endpoint
    Dependencies: Task 2.1 (full flow must work)
    Files likely touched: tests/preferences.test.js, docs/api.md
    Scope: M
```

#### Phase 3 - Phase-Based Execution (Orchestrator)

**What the Orchestrator does:**
1. Receives the Blueprint from Architect
2. Writes out ALL phases and tasks fully before dispatching any
3. For each task, builds a "Context Envelope" containing:
   - The task's objective and scope boundary
   - The relevant Blueprint excerpt
   - The relevant State of Intel slice
   - Current project state
   - Known blockers/risks
4. Dispatches Task 1.1 to Subtask Orchestrator via `new_task`
5. Verifies phase checkpoints between phases

#### Phase 4 - Atomic Execution (Subtask Orchestrator + Specialists)

**For Task 1.1 (Database Schema & Migration):**

The Subtask Orchestrator further decomposes into atomic subtasks:

| Subtask | Specialist | Job |
|---------|-----------|-----|
| ST-1.1a | Code | Add `Preferences` model to `prisma/schema.prisma` |
| ST-1.1b | Code | Run `npx prisma migrate dev --name add-preferences` |
| ST-1.1c | Code | Verify model is queryable with a quick test query |

**What happens step by step:**

1. **Subtask Orchestrator** dispatches ST-1.1a to **Code** mode with full context:
   - The exact model fields needed (from Blueprint)
   - The existing schema location (from State of Intel)
   - The instruction: "Add a Preferences model to prisma/schema.prisma with fields: id, userId, theme, notifications, language. Follow existing model patterns."

2. **Code** mode implements the change and returns via `attempt_completion`:
   - "Added Preferences model to prisma/schema.prisma (line 45). Fields: id (Int, autoincrement), userId (Int, relation to User), theme (String, default 'system'), notifications (Boolean, default true), language (String, default 'en')."

3. **Subtask Orchestrator** verifies the output matches expectations, then dispatches ST-1.1b.

4. After all subtasks complete, **Subtask Orchestrator** returns to **Orchestrator** with an exhaustive state report.

5. **Orchestrator** evaluates the result, then dispatches **Git** mode to commit Task 1.1.

6. **Git** mode validates staged content, generates commit: `feat(db): add Preferences model and migration`, and returns the commit hash.

7. **Orchestrator** proceeds to Task 1.2, and the cycle repeats. After all tasks in Phase 1 complete, the phase checkpoint is verified before starting Phase 2.

#### Final Flow Summary

```
User Request
  → Orchestrator receives and evaluates
    → Ask researches (State of Intel)
    → Architect designs (Blueprint with phases and tasks)
    → Orchestrator navigates phases and dispatches tasks sequentially:
        Phase 1: Task 1.1 → Subtask-Orchestrator → Code → Git commit
                 Task 1.2 → Subtask-Orchestrator → Code → Git commit
                 [Phase 1 checkpoint verified]
        Phase 2: Task 2.1 → Subtask-Orchestrator → Code → Git commit
                 ...
  → Orchestrator returns final result to User
```

### Key Principles Illustrated

| Principle | How It Manifests |
|-----------|-----------------|
| **No mode switches** | Every mode returns via `attempt_completion`; the Orchestrator controls all delegation via `new_task` |
| **Atomic purity** | Each subtask has exactly one verifiable output; no specialist is overloaded |
| **Explicit context** | Every delegation includes the full relevant context - no mode assumes prior knowledge |
| **Sequential execution** | Tasks execute one at a time; each is committed before the next begins |
| **Phase checkpoints** | System is verified in a working state between phases |
| **Pipeline enforcement** | Ask → Architect → Subtask-Orchestrator order is non-negotiable |

---

Thank you for contributing! 🎯
