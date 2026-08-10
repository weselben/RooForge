---
name: forge-setup
description: One-shot harness adaptation + repo bootstrap. Clones this repo to a temp directory, discovers every non-harness-agnostic reference, researches the running harness's equivalents, patches with minimal diffs, and optionally installs the adapted skills into the harness's skill directory. Run once on any non-Kimi harness.
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/forge-setup/SKILL.md
---

# Forge Setup

The skills in this repo are authored against **Kimi Code CLI**. Most are pure prompt contracts and run anywhere — but a handful reference harness-specific machinery: `kimi -p` non-interactive loops, the `CreateGoal` tool, plan mode, and the `AgentSwarm`/`Agent` subagent API. On a different harness (Claude Code, Codex, Gemini CLI, opencode, …) those references are dead.

This skill is the **discovery + adaptation + bootstrap procedure**: it clones the repo to a temp directory, makes the agent find every non-agnostic surface itself, research its own harness's equivalent, patch the references with minimal changes, and optionally install the adapted skills into the harness's skill directory. It does not ship a per-harness mapping table — harnesses change faster than any table stays true. The agent running on the target harness is the best researcher for that harness.

## When to run

- First session on any harness that is **not** Kimi Code CLI.
- After upgrading the harness, when a skill's referenced tool/flag no longer exists.
- When `loops`, `pr-review`, `pr-resolve`, `forge-flow`, `dispatching-parallel-agents`, or `subagent-driven-development` reference tooling the current session does not have.

## Step 0 — Clone the repo to a temp directory

Before any discovery, clone this repo to a throwaway workspace so patches don't touch the original (or the harness's skill directory until verified):

```bash
REPO_URL="https://github.com/weselben/RooForge"
WORKDIR="/tmp/rooforge-$(date +%s)"
git clone "$REPO_URL" "$WORKDIR"
cd "$WORKDIR"
```

**Done when:** the repo is cloned to `$WORKDIR` and you are inside it. All subsequent steps run from `$WORKDIR`.

## Step 1 — Identify the harness

Try to identify what is running you, in order:

1. **Own tool surface** — which tools exist this session? (`AgentSwarm`, `CreateGoal`, `EnterPlanMode`, a `Skill` tool, a `Task` tool, …)
2. **Environment** — CLI binary on `PATH` (`which kimi claude codex gemini opencode`), harness config dirs (`~/.kimi-code`, `~/.claude`, `~/.codex`, …), env vars.
3. **Ask the user.** If neither identifies it, ask: *"Which harness/CLI is running this session?"* Do not guess and patch blind.

**Done when:** the harness name and its CLI binary (if any) are known.

## Step 2 — Discover non-agnostic surfaces

Scan the **cloned** repo for harness-specific references. This exact inventory, run from `$WORKDIR`:

```bash
grep -rn -E 'kimi -p|kimi\b|CreateGoal|EnterPlanMode|ExitPlanMode|plan mode|AgentSwarm|subagent_type|Agent\(resume|run_in_background' skills/ --include='*.md' --include='*.sh'
```

Known surfaces today (verify against the grep — the grep is the truth, this list is the orientation):

| Surface | Where | Kimi form | What it needs |
|---------|-------|-----------|---------------|
| Non-interactive CLI loop | `loops/scripts/run_loop.sh`, `loops/SKILL.md`, `pr-review`, `pr-resolve` (scripts + templates) | `kimi -p "<prompt>"` | The harness CLI's headless one-shot-prompt flag that prints the reply to stdout |
| Goal / contract persistence | `forge-flow/SKILL.md` | `CreateGoal` tool | A long-living goal/contract mechanism, or a file fallback |
| Plan mode with approval gate | `forge/SKILL.md`, `planning-and-task-breakdown/SKILL.md`, `pr-review`/`pr-resolve` templates | `EnterPlanMode` / plan file / user approval | The harness's plan-mode equivalent, or a file-based plan contract |
| Parallel subagent dispatch | `dispatching-parallel-agents/SKILL.md`, `subagent-driven-development/SKILL.md` (+ prompt templates), `planning-and-task-breakdown/SKILL.md` | `AgentSwarm` with `{{item}}` template, `subagent_type: coder/explore/plan`, `Agent(resume=…)`, `run_in_background` | The harness's subagent/parallel-task API: batch dispatch, agent roles, resume, background runs |
| Skill loading | `AGENTS.md`, several SKILL.md "load X" instructions | Skills read as plain files from `skills/` | Nothing — file reads are harness-agnostic. Only patch if the harness has a native skills dir the repo should be symlinked/copied into |

## Step 3 — Research the harness's equivalents

For each surface found in step 2, research how **this** harness does it:

1. **Own documentation first** — the harness's docs dir, `--help` output (`<cli> --help`), built-in skill/command listings, config schema.
2. **Web second** — search for the harness's headless/non-interactive mode, subagent API, and plan/goal features. Prefer official docs.
3. Record each mapping before patching: `kimi -p "…"` → e.g. `claude -p "…"`, `CreateGoal` → e.g. a `GOAL.md` contract file, `AgentSwarm` → e.g. parallel `Task` calls.

If the harness has **no equivalent** for a surface, fall back to the simplest file-based convention and say so in the patch:

- No goal API → `GOAL.md` at repo root, re-read at every session start (forge-flow already treats the goal as a re-injected contract; a file satisfies that).
- No plan mode → write the plan file and stop for user approval in plain chat.
- No subagent API → run the swarm sequentially; keep the prompt templates unchanged.

## Step 4 — Patch the cloned repo with minimal diffs

Premade example replace commands — **adapt the replacement side to whatever step 3 found**. Run from `$WORKDIR`. Each is deliberately narrow; never rewrite skill logic, only the harness reference.

```bash
# 1. Non-interactive loop engine — replace the CLI + flag (example: claude -p)
grep -rl 'kimi -p' skills/ | xargs sed -i 's/kimi -p/claude -p/g'
grep -rl '\bkimi\b' skills/ --include='*.sh' | xargs sed -i 's/\bkimi\b/claude/g'

# 2. Goal tool — replace with the harness's goal mechanism or the file fallback
grep -rl 'CreateGoal' skills/ | xargs sed -i 's/CreateGoal/GOAL.md contract file/g'

# 3. Plan mode naming — match the harness's own terms, keep the approval gate intact
grep -rl 'EnterPlanMode\|ExitPlanMode' skills/ | xargs sed -i 's/EnterPlanMode/plan mode/g; s/ExitPlanMode/exit plan mode/g'

# 4. Subagent dispatch — rename the API, keep {{item}} template mechanics and role mandates
grep -rl 'AgentSwarm' skills/ | xargs sed -i 's/AgentSwarm/parallel Task dispatch/g'
```

Patch rules:

- **Minimal changes.** One reference swapped for its equivalent. No reformatting, no rewording of surrounding prose, no "while I'm here" cleanups.
- **Contracts stay.** `DONE:`/`BLOCKED:` in `run_loop.sh`, the role-mandate blocks, the MANDATORY FIRST loads, and the plan-approval gate are behavior, not harness references — never touch them.
- **Scripts must still parse.** After patching a `.sh`, run `bash -n` on it.
- **Same-scope commits.** Per repo convention, conventional commits with the skill name as scope. A harness adaptation spans several skills — use `chore(forge-setup): adapt skills to <harness>` as one commit.

## Step 5 — Verify the adapted clone

1. Re-run the step-2 grep from `$WORKDIR`. Expected: zero hits for the old harness's terms outside `forge-setup` itself (this file documents the Kimi forms on purpose — leave it).
2. Syntax-check every patched script: `find skills/ -name '*.sh' -exec bash -n {} \;`.
3. Smoke-test the loop engine if the harness CLI exists: one `run_loop.sh` call with a trivial prompt template that answers `DONE: ok` on iteration 1.
4. Report the mapping table (old → new, per surface) to the user.

## Step 6 — Prepare identity for commit authorship

Before installing skills, the user must set their git identity. If the user wants the adapted `use-git-identity` skill to reflect their own identity (not the RooForge default), prompt:

```
The adapted use-git-identity skill currently sets:
  user.name = "weselben/rooforge"
  user.email = "bengottwaldi04@gmail.com"

Enter your desired git name (or press Enter to keep "weselben/rooforge"):
Enter your desired git email (or press Enter to keep "bengottwaldi04@gmail.com"):
```

Update `$WORKDIR/skills/use-git-identity/SKILL.md` with the provided values before proceeding. This ensures commits made by the adapted skills carry the user's identity.

## Step 7 — Install adapted skills into the harness skill directory (optional)

If verification passes, offer to copy the adapted skills into the harness's skill directory so future sessions load them natively.

**First, delete any existing RooForge skills in the harness directory** to ensure a clean update on re-run:

```bash
# Determine the harness skill directory (prefer user's config dir)
HARNESS_SKILLS_DIR=""
if [ -d "$HOME/.claude/skills" ]; then
  HARNESS_SKILLS_DIR="$HOME/.claude/skills"
elif [ -d "$HOME/.codex/skills" ]; then
  HARNESS_SKILLS_DIR="$HOME/.codex/skills"
elif [ -d "$HOME/.kimi-code/skills" ]; then
  HARNESS_SKILLS_DIR="$HOME/.kimi-code/skills"
elif [ -d "$HOME/.opencode/skills" ]; then
  HARNESS_SKILLS_DIR="$HOME/.opencode/skills"
else
  HARNESS_SKILLS_DIR="$HOME/.agents/skills"
fi

mkdir -p "$HARNESS_SKILLS_DIR"

# Remove existing RooForge skill directories (clean update)
for skill in $(ls "$WORKDIR/skills/"); do
  [ -d "$HARNESS_SKILLS_DIR/$skill" ] && rm -rf "$HARNESS_SKILLS_DIR/$skill"
done

# Copy adapted skills one-by-one (exclude forge-setup — it documents the Kimi baseline)
for skill in $(ls "$WORKDIR/skills/"); do
  [ "$skill" = "forge-setup" ] && continue
  cp -r "$WORKDIR/skills/$skill" "$HARNESS_SKILLS_DIR/$skill"
done
echo "Adapted skills installed to: $HARNESS_SKILLS_DIR"
```

Ask the user before copying. If they decline, the adapted clone remains at `$WORKDIR` for manual inspection.

## Rules

- **Discovery over assumption.** The grep inventory in step 2 is re-run every time — never patch from a memorized list.
- **Ask when unknown.** Harness unidentified → ask the user. Equivalent not found after research → ask the user before inventing a fallback.
- **Minimal diffs.** Reference swap only. Anything beyond that is a separate change.
- **forge-setup is exempt from its own patches.** This file names the Kimi forms as the reference baseline; step 5's grep excludes it deliberately.
- **Work on the clone.** Steps 2–5 run on `$WORKDIR`, not the original repo or the harness skill directory. Only step 7 copies out.

## Boundaries

Forge Setup does not:
- Install the harness CLI or change harness config
- Rewrite skill behavior, contracts, or prompt templates beyond the harness reference
- Run `forge-init` (repo bootstrap) or `forge-flow` (session bootstrap) — those come after, using the adapted skills
- Commit anything without the user's go-ahead
- Modify the original GitHub repo (works on a local clone only)