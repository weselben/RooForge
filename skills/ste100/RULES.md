# STE100 extended rule digest

Compressed digest of the ASD-STE100 writing rules (Issue 8), for long-form text. The core rules in `SKILL.md` cover most prose; this file adds the finer limits and the approved-word discipline.

## Length limits by text type

| Text | Sentence max | Paragraph max |
|---|---|---|
| Instruction (procedural) | 20 words | 6 sentences |
| Description | 25 words | 6 sentences |
| Warning / caution | 25 words | one instruction per step |

In procedures: keep steps to one sentence; nested substeps allowed, max 3 levels.

## Approved-word discipline

STE permits a word from the approved dictionary plus technical names and technical verbs. In practice for software prose:

- Technical names (class names, flags, endpoints) are always permitted — write them exactly once, then reuse the same token or one plain-English name, never both interchangeably.
- A technical name needs no approval; an ordinary word used with a new technical meaning does. If you invent a meaning, define it at first use.
- Homographs are banned: do not use one word in two functions ("check the check results" — write "check the test results").
- -ing forms only as part of an approved technical name ("the caching layer"), never as a verb substitute ("after the merging of the branch" — write "after you merge the branch").

## Approved function words

- "and" / "or" — but never both in one sentence ("A and/or B" is banned; split the sentence).
- "if … then" — keep "then" when the condition is long or nested.
- "because" for cause; not "since", not "due to".
- "so that" for purpose; not "in order to".
- "between" for two, "among" for three or more.
- Numbers: digits for quantities ("3 retries"), words only at sentence start — better, restructure to avoid.

## Punctuation

- Commas: only where they remove ambiguity, or in lists.
- Colon introduces a list or example; semicolons are banned — split into two sentences.
- Parentheses for non-essential detail only; em-dashes banned — use a colon or a new sentence.
- Hyphens join words used as one modifier ("two-step process"); do not hyphenate technical names that stand alone.

## Warnings, cautions, notes

- Warning text: max 25 words per sentence, states the danger first, then the avoidance action.
- Notes: start with "NOTE:" and carry information the reader can skip without risk.
- Never bury a warning mid-paragraph — it is its own block.

## Verification checklist

Run on any long human-facing text before delivering:

- Every sentence under the word limit for its type.
- Every thing named once, named the same everywhere.
- Every instruction in imperative mood, active voice.
- No "-ing" verb substitutes, no contractions, no idioms.
- "must / can / should" used with their single approved meanings.
