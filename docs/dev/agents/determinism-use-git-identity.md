# Determinism sampling — use-git-identity

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/use-git-identity.log` (gitignored).

## Sample

- **Task:** for "set repo-local identity in a fresh clone /tmp/demo", output the exact commands and the always-same vs judgment split. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:30:53Z, exit 0, 71 log lines (incl. model reasoning).
- **Outcome:** model produced the two `git config` commands verbatim, classified the form as always-same, and correctly flagged the literal name/email strings as the judgment spot (defaults vs `forge-setup` post-install values).

## Observed meta-decisions

- Read `skills/use-git-identity/SKILL.md` first.
- Detected the **conditional variant** (`git config` vs `-c` vs `--amend`) and mapped it to the "first commit in repo" case.
- Correctly noted the **identity source**: defaults are the maintainer's, but `forge-setup` step 6 rewrites them on first install — so the literal strings are conditional on history.
- Flagged the `forge-setup` link as the source of truth for the post-install values.
- Did **not** mutate anything (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Pick the variant (first-commit / one-off / fix-existing) | low — heuristic | fully rule-driven | **shell script** — detect by `git config user.name` against empty + `git log -1` against no commits. | input: repo; output: variant. |
| 2 | Set `user.name` / `user.email` repo-local | none | full — fixed command form | **shell script** — `git config user.name "$1"` and `git config user.email "$2"`. | input: name + email; output: configured. |
| 3 | Use `-c` for one-off | none | full — fixed | **shell script** — `git -c user.name=... -c user.email=... <subcommand>`. | input: name + email + subcommand; output: outcome. |
| 4 | `git commit --amend --reset-author --no-edit` | none | full — fixed | **shell script** — verbatim. | input: repo; output: amended. |
| 5 | `git push --force-with-lease` | medium — confirm before force-push | rule is fixed | **shell script** with a confirmation gate. | input: user confirm; output: pushed. |
| 6 | Source of the name/email values | medium — defaults vs post-install | defaults are fixed | **premade prompt template** — read the `use-git-identity/SKILL.md` (or `forge-setup` post-install file) to get the current values. | input: skill file; output: name + email. |
| 7 | Refuse `--global` unless asked | none | full — fixed rule | **shell script** — wrapper that filters out `--global` flags. | input: command; output: validated. |

## Notes

- This is the **most scriptable skill in the entire set**: every step is a fixed command with one judgement (which variant). The model role is essentially nil beyond reading the values from the skill file.
- The strongest determinism win is a **`forge_mcp.git_identity(target, variant)` MCP tool** that handles all three variants and is the only way the agent sets identity. The tool is the skill.
- The `forge-setup` chain (skill wrote → step 6 rewrites → use-git-identity reads) is a **values-as-data** pattern: the literal name/email flows through files, not memory. A deterministic wrapper that reads the file is strictly better than the model remembering it.
- The `--global` refusal is a guard, not a step — but a wrapper that strips `--global` is a cheap, valuable check.