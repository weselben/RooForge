---
name: loops
description: "Drive `kimi -p` review/resolve loops via a shell framework. Dynamic prompts: callers supply their own `.md` template; loops renders it, compresses it, drives `run_loop` until `DONE:` or `BLOCKED:`. Triggers: \"kimi -p loop\", \"review loop\", \"resolve loop\"."
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/loops/SKILL.md
---

# loops — shell framework for `kimi -p` loops

**Leading word: render.** The calling skill supplies the prompt template; loops renders it, compresses it, drives the cycle. The framework owns the plumbing; the caller owns the prompt.

## Usage

```bash
scripts/run_loop.sh <prompt.md> [max_iter=10] [workdir]
```

- `<prompt.md>` — prompt template. **The calling skill owns this file** (under its own `templates/`). Loops reads, compresses, fills placeholders.
- `[max_iter]` — max iterations (default 10). Each is one `kimi -p` call.
- `[workdir]` — directory to `cd` into before starting. Default: current directory. Loop sets `pwd` so kimi chats land under that workdir in history.

## Steps

1. **START** — `cd` to `[workdir]`. Render `<prompt.md>` through `scripts/cavemanize.sh` (compresses prose; preserves code, identifiers, errors).
2. **LOOP** — for `i` in `1..max_iter`:
   - Run `kimi -p "<rendered>"`, capture output.
   - Check for `DONE:` or `BLOCKED:`.
   - On `DONE:` — write artifact path, exit 0.
   - On `BLOCKED:` — write blocker reason, exit 2.
   - Otherwise — append reply to prompt, re-render (cavemanize new content too).
3. **CAP** — exit 1 with "max_iter reached without DONE".

**Done when:** the loop exits 0 with `DONE:` and an artifact path.

## Scripts — `scripts/`

| Script | Role |
|---|---|
| `scripts/run_loop.sh` | The framework. Args: `prompt.md [max_iter] [workdir]`. |
| `scripts/cavemanize.sh` | Compresses prose to caveman form. Reads stdin, writes stdout. |

## Caller contract

Any skill that needs a `kimi -p` loop supplies its own prompt template under its own `templates/` dir. The template is the `kimi -p` prompt body — MANDATORY FIRST skill loads, no-plan-mode instruction, `DONE:`/`BLOCKED:` contract line.

**No ambiguity.** Every prompt must include **broader context** (why this task exists, where it fits, what's done, what's downstream) AND **task context** (exact paths, exact commands, exact output format). STE100 prose: one meaning per word, short sentences, active voice. The subagent must never need to ask a clarifying question — that signal means the prompt was incomplete.


Example wiring (from `pr-review`):

```
# inside pr-review skill
scripts/review-loop.sh <pr-ref> <worktree> [max_iter]
   │
   └─► renders templates/review-loop.md
       └─► compresses via ../loops/scripts/cavemanize.sh
           └─► drives ../loops/scripts/run_loop.sh
```

Cross-skill paths are relative to each skill's own SKILL.md — `../loops/scripts/run_loop.sh` from pr-review reaches the loops framework.

## Hard rules

- The loop sets `pwd` to `[workdir]` before starting. Chats land in the user's history under that workdir.
- Every iteration cavemanizes the running prompt.
- `DONE:` is the only success exit. `BLOCKED:` is a real signal.
- The calling skill owns the prompt. Loops never modifies the template body.

## Boundaries

- Does not interpret findings — that is `caveman-review`'s job.
- Does not manage worktrees — that is `using-git-worktrees`'s job.
- Does not post to GitHub — that is `pr-review`'s or `pr-resolve`'s job.