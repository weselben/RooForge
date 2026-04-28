---
name: clarify
description: >
  User clarification protocol. Run before finalizing any plan or Blueprint
  to resolve ambiguity + gather user preferences. Used by architect mode.
---

# /clarify — User Clarification Protocol

Before finalizing plan or Blueprint, resolve ambiguity by gathering user preferences. Use `ask_followup_question` following these rules.

## When to Clarify

Run /clarify when:
- Task has multiple valid approaches, no clear best choice
- Requirements vague or could be interpreted differently
- User preferences on technology, style, or priority unknown
- Scope boundaries unclear (what is IN vs OUT)
- Any assumption would be required to proceed

## How to Clarify

Use `ask_followup_question` with these constraints:

### Question Format
- One clear, specific question per ask_followup_question call
- Frame question with context: what you know, what you need to decide
- Never ask "what do you want?" → ask "should I use X or Y given Z?"

### Suggested Answers
- Provide 2-4 complete, actionable suggested answers
- FIRST suggested answer = recommended default
- Each suggestion specific enough to act on without follow-up
- Never use placeholders like "your preference here"

### Depth Rule
Ask MORE, not less. Better to over-clarify than assume. Unsure whether to ask → ask.

### When to Stop
Stop clarifying when:
- All technical decisions have clear direction
- Scope boundaries defined
- User preferences recorded
- No assumptions remain that could affect Blueprint

## Rules
- Do NOT proceed to planning without clarification if ANY ambiguity exists
- Do NOT ask multiple questions in one call — one question per ask_followup_question
- Do NOT skip this step because "answer seems obvious"
- ALWAYS make first suggested answer = recommended default

## Important
Run `run_slash_command` ('clarify') once to load this context → use tool `ask_followup_question` directly.
