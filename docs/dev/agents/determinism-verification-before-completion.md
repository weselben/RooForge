# Determinism sampling — verification-before-completion

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/verification-before-completion.log` (gitignored).

## Sample

- **Task:** for claim "all 35 SKILL.md files under skills/ exist and are non-empty", output (1) single command, (2) exit-code/output check, (3) Gate mechanical vs judgment split. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:30:53Z, exit 0, 140 log lines (incl. model reasoning).
- **Outcome:** model proposed `find skills -type f -name SKILL.md -size +0c | wc -l`, classified Gate steps 2/3/5 as mechanical and 1/4 as judgment, and surfaced a sharp question: "does '35' really mean every file is present and non-empty, or could a count match hide one empty + one oversized?" — a verification-quality concern.

## Observed meta-decisions

- Read `skills/verification-before-completion/SKILL.md` first.
- Considered **multiple candidate commands** (`-size +0c` vs `-size +1c`, count-then-test vs test-then-count) and chose the most legible.
- Identified a subtle verification failure mode (count match can hide a deficit + surplus) and proposed a follow-up command to close it — exactly what the skill's "Don't trust partial verification" red flag guards against.
- Did **not** execute the verification command (respected DRY RUN); if executed, the count would have been 35 (verified independently during this run by `ls skills/ | wc -l`).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | IDENTIFY (what command proves the claim?) | high — predicate choice | none | **keep-as-model** — picking the right evidence command is judgment. | input: claim; output: candidate command. |
| 2 | RUN (execute full command) | none | full — fixed control flow | **shell** — harness executes. | n/a. |
| 3 | READ (exit code, full output) | none | full — fixed | **shell** — capture `$?` + stdout/stderr. | input: command; output: exit + output. |
| 4 | VERIFY (does output confirm the claim?) | high — interpret count vs truth | "doesn't confirm → state actual" is rule-shaped | **keep-as-model** — the verification interpretation; a wrapper can flag obvious "count match can hide deficit+surplus" patterns. | input: claim + output; output: pass/fail. |
| 5 | CLAIM (state WITH evidence) | low — phrasing | format is fixed (claim + bracketed evidence) | **premade prompt template** — fixed format with `✅` / `❌` markers per the skill's templates. | input: pass/fail + evidence; output: claim string. |
| 6 | Regression red-green cycle (write → pass → revert → fail → restore → pass) | none | full — fixed procedure | **shell script** — sequence of git/test operations. | input: test name; output: cycle result. |
| 7 | "Don't trust agent success" — check VCS diff on agent claims | none | full — fixed procedure | **shell script** — `git diff` against the agent's claimed state. | input: agent claim; output: actual diff. |
| 8 | "Requirements met" line-by-line checklist | medium — checklist authoring | the verification is mechanical once the list exists | **premade prompt template** — ask for the line items; wrapper runs the per-item verifier. | input: plan; output: per-item status. |
| 9 | "No 'should' / 'probably' / 'seems to'" prose gate | none | full — fixed | **linter** — flag hedging words. | input: claim text; output: violations. |
| 10 | "Express satisfaction before verification" → STOP | none | full — fixed rule | **wrapper** — block completion claim until verification artifact attached. | input: claim; output: allowed/blocked. |

## Notes

- This skill is the **honesty scaffold**: it does not write code or content, it gates claims. The model's role is the small judgement at steps 1 and 4; everything else is mechanical enforcement.
- The strongest determinism win is a **`forge_mcp.verify(claim, command)` MCP tool** that runs the command, captures exit + output, and refuses to emit a "pass" claim without the evidence attached. The model's role shrinks to picking the command and interpreting the output.
- The "count match can hide deficit+surplus" pattern the model surfaced is a generic verification bug; a wrapper that pairs counts with detailed lists (and refuses to confirm on match alone) would close it.
- The skill's "Iron Law" is structurally enforceable: every claim text passes through a hedge-word linter and a missing-evidence gate. A model that emits "should pass" without a fresh command output simply cannot pass.