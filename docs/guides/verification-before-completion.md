# verification-before-completion

Enforces the Iron Law: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE. Before claiming any task is complete, fixed, or passing, you must identify the verification command, run it fully, read the complete output, check the exit code, and only then make the claim with evidence attached.

## When to load

- About to claim "complete", "fixed", "passing", "done", or any synonym
- Before committing, creating a PR, or marking a task done
- Before moving to the next task or delegating to agents
- When Forge reaches step 6 (Verify) — runs full test suite on the merged feat branch and verifies each subagent's claimed state against `git status` and suite results

## How it works

1. **IDENTIFY** — Determine the exact command that proves the claim (test suite, linter, build, reproduction script, checklist against requirements)
2. **RUN** — Execute the FULL command fresh; no cached or partial runs
3. **READ** — Capture the complete output, exit code, and failure counts
4. **VERIFY** — Confirm the output actually supports the claim
   - If NO: state actual status with evidence (e.g., "3 failures: test_x, test_y, test_z")
   - If YES: state the claim WITH the evidence (e.g., "✅ [Run test command] [See: 34/34 pass] All tests pass")
5. **ONLY THEN** make the completion claim

Red flags that signal a skipped gate: using "should", "probably", "seems to"; expressing satisfaction before verification; trusting agent success reports without checking VCS diff.

## Files in this skill

- `skills/verification-before-completion/SKILL.md` — The skill definition: Iron Law, gate steps, evidence templates for tests/regression/build/requirements/agent delegation, red flags, and when to apply

## See also

- `forge` — Orchestrates the session flow; step 6 (Verify) loads this skill to run the full test suite on the merged feat branch and cross-check subagent claims against `git status`
- `subagent-driven-development` — Produces the per-task worktrees whose squash commits are verified by this skill in Forge's Verify step
- `pr-review` / `pr-resolve` — Review and resolve loops that precede the final verification; their findings must be cleared before this skill gives green

## Notes

- The skill directory contains only `SKILL.md`; no scripts or templates are bundled.
- The Forge integration (step 6) is described in `skills/forge/SKILL.md:89-92` — "Load `verification-before-completion`. Run the full test suite on the merged feat branch. Check each subagent's claimed state against `git status` and the suite result."