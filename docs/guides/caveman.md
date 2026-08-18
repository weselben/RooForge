# caveman

Ultra-compressed communication mode that reduces output tokens by ~65% (measured) while preserving full technical accuracy. It achieves this by stripping filler words, articles, hedging, and pleasantries while keeping all technical substance intact. Supports six intensity levels: lite, full (default), ultra, wenyan-lite, wenyan-full, wenyan-ultra.

## When to load

- User explicitly says: "caveman mode", "talk like caveman", "use caveman", "less tokens", "be brief"
- User invokes `/skill:caveman` slash command
- Token efficiency is explicitly requested
- Auto-loads as **caveman(ultra)** on every session start via `forge` (mandatory per forge's invariant rules)

## How it works

1. **Mode selection** — Default intensity is `full`. Switch via `/skill:caveman lite|full|ultra|wenyan-lite|wenyan-full|wenyan-ultra|off` (SKILL.md:18)
2. **Compression rules applied** (SKILL.md:23–43):
   - Drop articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging
   - Use fragments; short synonyms (big not extensive, fix not "implement a solution for")
   - No tool-call narration, no decorative tables/emoji, no raw error log dumps unless asked
   - Standard well-known acronyms OK (DB/API/HTTP); never invent abbreviations (cfg/impl/req/res/fn) — tokenizer splits them same as full word
   - Never drop negation words (not/never/no/only/except) — flips meaning
   - Numbers and units preserved exactly
   - Tool calls fire directly; no preamble/plan/progress notes before or between calls
   - Preserve user's dominant language exactly — compress style, not language
3. **Auto-clarity overrides** (SKILL.md:55–67) — Drop caveman when:
   - Security warnings
   - Irreversible action confirmations
   - Multi-step sequences where fragment order or omitted conjunctions risk misread
   - Compression creates technical ambiguity
   - User asks to clarify or repeats question
   Resume caveman after clear part done
4. **Boundaries** (SKILL.md:69–73) — Persisted outside chat (code, comments, commits, docs, issue/PR/MR text, memory files, third-party messages) writes normal prose. "stop caveman" or "normal mode" reverts to normal. Level persists until changed or session end.

## Files in this skill

- `skills/caveman/SKILL.md` — Main skill definition: rules, intensity levels, examples, auto-clarity, boundaries, and source attribution

## See also

- `forge` — Orchestrates session start; auto-loads caveman(ultra) as mandatory invariant (forge/SKILL.md:14, 18, 21)
- `caveman-commit` — Applies caveman compression to commit messages (separate skill, referenced in forge's git flow)
- `caveman-review` — Applies caveman compression to PR review format (separate skill, used by forge's pr-review step)

## Notes

- The `source` field in SKILL.md references https://github.com/JuliusBrussee/caveman/tree/main/skills/caveman — external upstream not verified
- `caveman-commit` and `caveman-review` are referenced in forge's flow but their SKILL.md files were not examined for this guide
- Wenyan modes (classical Chinese) compress by character count (80–90%), not token count — distinct from lite/full/ultra