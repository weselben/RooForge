---
name: ste100
description: Write human-facing text in ASD-STE100 Simplified Technical English — short sentences, approved words, one meaning per word. Governs PR bodies, docs, and issue/PR comments; chat replies and commit messages are not in scope (caveman-commit owns commits).
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/ste100/SKILL.md
---

# STE100

All text that faces other humans — PR bodies, issue comments, docs — goes out in STE100. Commit messages are the exception: `caveman-commit` owns those. Short, direct, unambiguous. The reader is busy; the text does the work, not the reader.

**Leading word: terse.** STE100 prose is terse by construction: short sentences, one meaning per word, no filler.

## Core rules

**Sentences:**
- One topic per sentence. One instruction per sentence.
- Max 20 words per instruction, 25 per description.
- Max 6 sentences per paragraph.
- Imperative mood: "Restart the server", not "The server should be restarted".
- Active voice. The actor is in the sentence.

**Words:**
- One word for one meaning, everywhere. "check" on line one is never "test" on line ten.
- Prefer the short approved word: "use" not "utilize", "show" not "demonstrate".
- Verbs as verbs, nouns as nouns. No noun-verb drift.
- Every thing gets one technical name, used consistently. First use may define it.
- No contractions. No idioms. No phrasal ambiguity.

**Tense and mood:**
- Present tense for what is true. Past tense for what is done. Future tense only when the event is truly later.
- "must" = obligation, "can" = capability, "should" = recommendation.

## Examples

- ❌ "In this PR we've implemented a brand new caching layer in order to facilitate improved performance across the board"
- ✅ "This PR adds a cache layer. It decreases the response time of the API."

- ❌ "You might want to consider updating your dependencies, as there could potentially be vulnerabilities"
- ✅ "Update the dependencies. Two have known vulnerabilities."

- ❌ "This PR description was written to explain the changes made to the authentication module"
- ✅ "fix(auth): accept tokens with trailing whitespace"

## Extended rules

For the full writing-rule digest — approved verb list, word-count limits per text type, punctuation, warnings and notes format — read [`RULES.md`](RULES.md). Load it when the text is long-form (docs, reports) or when a sentence resists the core rules.

## Boundaries

STE100 shapes the prose the agent produces. It does not strip required format (commit type prefixes, PR headings, AI-attribution trailers) and does not censor facts. If the user asks for a different tone ("formal", "marketing"), the user wins for that text.