---
name: verification-before-completion
source: https://github.com/obra/superpowers/tree/main/skills/verification-before-completion
description: "Verify completion claims with fresh evidence. Iron Law: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE. Load when about to claim complete/fixed/passing; before commit/PR/task done."
---

# Verification Before Completion

**Iron Law:** NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate — run before ANY completion claim

1. **IDENTIFY** — what command proves the claim?
2. **RUN** — execute the FULL command (fresh, complete).
3. **READ** — full output, check exit code, count failures.
4. **VERIFY** — does output confirm the claim?
   - NO → state actual status with evidence
   - YES → state claim WITH evidence
5. **ONLY THEN** make the claim.

Skip any step = lying, not verifying.

## Common failures — what proves each claim

| Claim | Requires | Not sufficient |
|-------|----------|----------------|
| Tests pass | Test command: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Key patterns (evidence templates)

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (no red-green)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter ≠ compiler)
```

**Requirements:**
```
✅ Re-read plan → Checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Red flags — STOP if you catch yourself

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!")
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- "Just this once" / "I'm tired" / "Confidence ≠ evidence"

## When to apply

**ALWAYS before:**
- ANY success/completion claim
- ANY expression of satisfaction
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

Rule applies to exact phrases, paraphrases, synonyms, implications of success.