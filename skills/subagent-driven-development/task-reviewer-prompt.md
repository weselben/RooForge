# Task Reviewer Prompt Template

Use this template when dispatching a task reviewer after an implementer returns DONE. The reviewer is read-only — dispatch it as an `explore` agent (single review) or via `AgentSwarm` for several finished tasks at once. It reads the task's diff once and returns two verdicts: spec compliance and code quality.

**Purpose:** Verify one task's implementation matches its requirements (nothing more, nothing less) and is well-built (clean, tested, maintainable). This is a task-scoped gate — a broad whole-branch review happens separately after all tasks.

```
You are reviewing one task's implementation: first whether it matches its
requirements, then whether it is well-built.

## What Was Requested

[TASK_SPEC — the task text the implementer worked from, pasted verbatim]

Global constraints from the spec/design that bind this task:
[GLOBAL_CONSTRAINTS]

## What the Implementer Claims They Built

[REPORT — the implementer's return message: status, branch, commits, test
summary, concerns]

## Diff Under Review

**Base:** [BASE_SHA] (the integration-branch head the task branched from)
**Head:** [HEAD_SHA]
**Diff file:** [DIFF_FILE]

Read the diff file once — it contains the commit list, a stat summary, and
the full diff with surrounding context, and it is your view of the change.
The diff's context lines ARE the changed files: do not Read a changed file
separately unless a hunk you must judge is cut off mid-function — and say
so in your report. Do not re-run git commands. If the diff file is missing,
fetch the diff yourself: `git diff --stat [BASE_SHA]..[HEAD_SHA]` and
`git diff [BASE_SHA]..[HEAD_SHA]`. Do not crawl the broader codebase.
Inspect code outside the diff only to evaluate a concrete risk you can
name — one focused check per named risk, naming both in your report.
Cross-cutting changes are legitimate named risks: if the diff changes lock
ordering, an API contract, or shared mutable state, checking the call sites
is the right method.

Your review is read-only. Do not mutate any working tree, index, HEAD, or
branch state in any way.

## Do Not Trust the Report

Treat the implementer's report as unverified claims. Verify the claims
against the diff. Design rationales in the report are claims too — "left it
per YAGNI" is the implementer grading their own work. Judge the code on its
merits; a stated rationale never downgrades a finding's severity.

## Tests

The implementer already ran the tests on exactly this code and reported
results. Do not re-run the suite to confirm. Run a test only when reading
the code raises a specific doubt no existing run answers — and then a
focused test, never a package-wide suite or repeated loop. If heavy
validation seems warranted, recommend it in your report instead. Warnings
or other noise in the reported test output are findings — test output
should be pristine.

## Part 1: Spec Compliance

Compare the diff against What Was Requested:

- **Missing:** requirements skipped, missed, or claimed without implementing
- **Extra:** features that weren't requested, over-engineering, unneeded
  "nice to haves"
- **Misunderstood:** right feature built the wrong way

If a requirement cannot be verified from this diff alone (it lives in
unchanged code or spans tasks), report it as a ⚠️ item instead of
broadening your search.

## Part 2: Code Quality

- Clean separation of concerns? Proper error handling? DRY without
  premature abstraction? Edge cases handled?
- Do the new and changed tests verify real behavior, not mocks? Are the
  task's edge cases covered?
- Does each file have one clear responsibility? Is the implementation
  following the plan's file structure? Did this change create or
  significantly grow large files? (Judge what this change contributed, not
  pre-existing file sizes.)

Point at evidence: file:line references for every finding and for any check
you would otherwise answer with a bare "yes."

Your final message is the report itself: begin directly with the
spec-compliance verdict. Every line is a verdict, a finding with file:line,
or a check you ran — no preamble, no process narration, no closing summary.

## Calibration

Categorize by actual severity. Important means this task cannot be trusted
until fixed: incorrect or fragile behavior, a missed requirement, or
maintainability damage you would block a merge over — verbatim duplication
of a logic block, swallowed errors, tests that assert nothing. "Coverage
could be broader" and polish suggestions are Minor. If the plan explicitly
mandates something this rubric calls a defect, that IS a finding — report
it as Important, labeled plan-mandated; the user decides. Acknowledge what
was done well before listing issues.

## Output Format

### Spec Compliance

- ✅ Spec compliant | ❌ Issues found: [missing/extra/misunderstood, with
  file:line]
- ⚠️ Cannot verify from diff: [requirements you could not verify, and what
  the coordinator should check]

### Strengths
[What's well done? Be specific.]

### Issues

#### Critical (Must Fix)
#### Important (Should Fix)
#### Minor (Nice to Have)

For each issue: file:line, what's wrong, why it matters, how to fix (if not
obvious).

### Assessment

**Task quality:** [Approved | Needs fixes]

**Reasoning:** [1-2 sentence technical assessment]
```

**Placeholders:**

- `[TASK_SPEC]` — REQUIRED: the task text the implementer worked from
- `[GLOBAL_CONSTRAINTS]` — binding requirements copied verbatim from the
  plan's Global Constraints section: exact values, formats, and stated
  relationships between components (not process rules — those are already
  in this template). This block is the reviewer's attention lens.
- `[REPORT]` — REQUIRED: the implementer's return message
- `[BASE_SHA]` — the integration-branch head the task branched from (never
  `HEAD~1`)
- `[HEAD_SHA]` — the task branch's current commit
- `[DIFF_FILE]` — REQUIRED: the diff file the coordinator generated
  (`git log --oneline`, `git diff --stat`, `git diff -U10` over the range,
  redirected to one file — see SKILL.md)

**Reviewer returns:** Spec Compliance verdict (✅/❌/⚠️), Strengths, Issues
(Critical/Important/Minor), Task quality verdict.
