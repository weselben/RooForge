---
name: complete
description: >
  Standardized attempt_completion format. Run when work is done (or blocked)
  to format final result. All Forge modes use this for consistent, verifiable
  output. Includes blocked variant for unresolvable issues.
---

# /complete — Attempt Completion Format

Task done or blocked. Format `attempt_completion` result with **ALL** required sections. Omitting sections = protocol failure.

## Completed Task Format

### 1. Output
What was produced or changed. Be specific:
- File paths with line references where applicable
- Function/class/component names affected
- Configuration values changed
- Research modes: key findings + sources

### 2. Blockers
Remaining issues preventing full completion. State `"No blockers"` if none.
- Blocked: describe blocker, what was attempted, what is needed to resolve
- Include error messages verbatim if applicable

### 3. Proof
Verification that work is correct + complete:
- Test output (pass/fail counts, relevant assertions)
- Build status (success/failure with relevant output)
- File diff summary (files added/modified/deleted with change counts)
- Research: source citations (URLs, file paths)
- Planning: verification criteria met

### 4. Context Chain
Concise execution trace in exact format:
```
[did X] → [did Y] → [completed Z] → [status]
```
- Each step = past-tense action
- Final element = current status: `completed`, `blocked`, or `partial`
- Example: `[analyzed schema] → [designed Preferences model] → [wrote migration] → [completed]`

### Completed Template

```
## Output
[specific details]

## Blockers
[issues or "No blockers"]

## Proof
[verification evidence]

## Context Chain
[did X] → [did Y] → [completed Z] → [status]
```

## Blocked Variant

Cannot complete task due to unresolvable error, missing dependency, or scope ambiguity. Use this format instead:

### 1. Blocker
What prevents completion. Be specific:
- Error message verbatim (if applicable)
- Missing dependency or resource
- Scope ambiguity requiring user input
- External system failure

### 2. What Was Attempted
Steps taken to resolve blocker:
- What you tried
- What succeeded before blocker
- What failed + why

### 3. What Is Needed
Exactly what would unblock task:
- Specific information needed
- Dependency that must be resolved first
- User decision required
- External fix required

### 4. Partial Output
Any work completed before blocker that may be usable:
- Files created or modified (with paths)
- Partial results or findings
- State of Intel gathered so far

### Blocked Template

```
## Blocker
[specific blocker description]

## What Was Attempted
[steps taken]

## What Is Needed
[exact requirements to unblock]

## Partial Output
[any usable work completed]
```

## Before attempt_completion

Run `run_slash_command` with command `memory` → persist key insights to `.memory/`. Include:
- What was accomplished or discovered
- Decisions made + why
- Any context helpful for future pipeline runs

Ensures working memory stays current across tasks. Then proceed with `attempt_completion`.

## Rules
- Do NOT summarize vaguely — specificity mandatory
- Do NOT skip sections — every section must be present
- Do NOT add sections beyond defined above
- Keep narrative brief; reserve detail for Output + Proof sections
- Do NOT skip memory update — pipeline continuity depends on it
- Blocked → use Blocked Variant format, then `attempt_completion`
