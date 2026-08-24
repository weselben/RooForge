# Determinism seams summary — draft mechanism matrix

Aggregation of the per-skill sampling artifacts (`docs/dev/agents/determinism-<skill>.md`, 35 files) produced for wayfinder map #31, ticket #32 (T1), per ADR 0004. One row per seam: skill, step, seam, recommended mechanism. Raw `kimi -p` logs at `.tmp-determinism/logs/` (gitignored).

## Mechanism legend

- **MCP** — typed tool on `forge-mcp` (ADR 0005 #1: tracker/infra → MCP, ADR 0006).
- **shell** — plain shell script or fixed command sequence.
- **Node+template** — Node wrapper rendering a premade prompt template (ADR 0005 #2, ADR 0007).
- **AgentSwarm** — `AgentSwarm` fan-out with `{{item}}` (ADR 0005 #3).
- **linter** — deterministic post-hoc checker over text/artefacts (a shell-class mechanism; called out separately because it verifies rather than generates).
- **keep-as-model** — judgment stays with the model (ADR 0005 #5), with stated rationale.
- **harness** — already deterministic harness behaviour; no work needed.

## Matrix

| Skill | Step | Seam | Recommended mechanism |
|-------|------|------|------------------------|
| 12-factor-app | load factor + mistakes tables | reference content injection | harness (skill auto-load) |
| 12-factor-app | map stated defect → factor | 1:1 table lookup | Node+template (audit skeleton) or keep-as-model |
| 12-factor-app | repo fact scan (secrets, Dockerfile, logging) | infra checks | **MCP** `forge_mcp.twelve_factor_scan(repo)` |
| 12-factor-app | infer implied factors; prioritize fixes | proportionality/sequencing | keep-as-model (ADR 0005: prioritization is judgment) |
| caveman | mode activation + level switch | trigger parse + enum | harness (slash command) |
| caveman | drop lists (articles, filler, hedging) | fixed word lists | keep-as-model + **linter** (banned-word check) |
| caveman | preservation rules (code, errors, not/never) | verbatim token set | keep-as-model + **linter** (preserved-token diff) |
| caveman | fact selection; auto-clarity triggers | what survives compression | keep-as-model |
| caveman-commit | read the diff | `git diff --staged` | **shell** |
| caveman-commit | type/scope pick per repo convention | path-prefix lookup | **shell** (skills/<name>/ → scope) |
| caveman-commit | format rules (imperative, ≤50/72, no period) | fixed rules | **linter** (commit-msg hook) |
| caveman-commit | subject wording; body why | semantic compression | keep-as-model |
| caveman-review | obtain diff | `gh pr diff` / `git diff` | **shell** |
| caveman-review | finding format + severity taxonomy | fixed template + enum | **linter** (format), heuristic triage |
| caveman-review | spot the bug; couple/dedup findings; phrase fix | semantic defect work | keep-as-model (+ **MCP** `forge_mcp.sast_scan` pre-flag) |
| conventional-commits | format shape, `!`, `BREAKING CHANGE:` footer | v1.0.0 spec rules | **linter** (shared with caveman-commit) |
| conventional-commits | type enum pick | mostly 1:1 | **shell** heuristic + keep-as-model for ambiguous framing |
| conventional-commits | subject/body/footer wording | authoring | keep-as-model |
| creating-pull-requests | gather diff/stat/commits | fixed gh/git invocations | **shell** |
| creating-pull-requests | size gate → section budget | fixed 3-row table | **shell** (line count → enum) |
| creating-pull-requests | draft flag, AI disclosure, `--body-file` | fixed strings/flags | **shell** + premade template |
| creating-pull-requests | title/TL;DR/files-table content | semantic summary | keep-as-model (+ AgentSwarm for per-file "Why") |
| creating-pull-requests | banned openers, noun-stack cap, checklist | fixed lists | **linter** |
| deep-research | output path; report skeleton; forge-docs chain | fixed templates | **shell** + premade template |
| deep-research | per-round Think/Summary cadence | fixed protocol | Node+template (round engine wrapper) |
| deep-research | parallel sub-question dispatch | homogeneous fan-out | **AgentSwarm** `{{item}}` |
| deep-research | query design; source selection; stop signal | research judgment | keep-as-model |
| dispatching-parallel-agents | identify independent domains; partition | partition judgment | keep-as-model |
| dispatching-parallel-agents | `AgentSwarm` dispatch with `{{item}}` | canonical fan-out | **AgentSwarm** (already the mechanism) |
| dispatching-parallel-agents | MANDATORY FIRST block | hard contract literal | premade template token |
| domain-modeling | file locations, entry/ADR formats, lazy-create | fixed paths + templates | **shell** + premade template |
| domain-modeling | glossary content constraint; ADR 3-criteria test | fixed rules | **linter** + Node wrapper (AND of 3 yes/no) |
| domain-modeling | detect conflict; coin canonical term; scenarios | naming/invention | keep-as-model (+ **MCP** `forge_mcp.term_lookup`) |
| finishing-a-development-branch | verify tests; env detect; squash-merge; push/PR | fixed command chains | **shell** (+ Node wrapper around merge loop) |
| finishing-a-development-branch | confirm base; interpret red tests; conflict resolution | recovery judgment | keep-as-model (delegates to resolving-merge-conflicts) |
| finishing-a-development-branch | never-merge-to-main guard | branch policy | **shell** (pre-push guard) |
| forge | auto-load always-on skills | harness injection | harness |
| forge | detect map + branch load-vs-chart | three-case lookup | **MCP** `forge_mcp.detect_map(repo)` |
| forge | chart dispatch (wayfinder + grilling) | fan-out over fog areas | **AgentSwarm** `{{item}}` |
| forge | skip-resolve-vs-full-rigour; plan authoring | orchestrator judgment | keep-as-model |
| forge-cleanup | detect candidates (5 command classes) | fixed detection commands | **shell** (emit `found.json`) / **MCP** `forge_mcp.cleanup_scan` |
| forge-cleanup | per-candidate prompt, ordering, action table | fixed templates | **shell** (interactive loop) |
| forge-cleanup | escalate to repo-level `reset --hard` | fuzzy threshold | keep-as-model |
| forge-docs | trigger → affected sub-folder lookup | fixed table | **shell** / **MCP** `forge_mcp.docs_index_diff` |
| forge-docs | sub-README templates; same-commit rule | fixed templates | premade template + **shell** pairing |
| forge-docs | one-line "why it exists" phrasing; system-design trigger | prose judgment | keep-as-model |
| forge-eu-accessibility | scope classification; microenterprise test; baseline | table lookups + thresholds | **shell** |
| forge-eu-accessibility | WCAG audit | checklist vs live UI | **MCP** `forge_mcp.wcag_scan(url)` + keep-as-model (residual) |
| forge-eu-accessibility | exemption assessments (§16/§17) | legal judgment | keep-as-model |
| forge-eu-accessibility | live legal source verification | fixed source list | **shell** (`WebSearch`/`FetchURL` wrapper) |
| forge-flow | detect map; reuse-vs-create branch lookup | ordered lookups | **MCP** `forge_mcp.detect_map`, `forge_mcp.find_feat_branch` |
| forge-flow | derive `feat/<slug>` | example-shaped rule | Node+template (slugify wrapper; example list = test corpus) |
| forge-flow | cut branch; goal objective; handoff | fixed commands/templates | **shell** + Node+template |
| forge-init | AGENTS.md detect/prepend/append/merge/idempotency | marker greps + fixed blocks | **shell** / **MCP** `forge_mcp.agents_merge` |
| forge-init | grilling waves for repo specifics | interview content | keep-as-model (wave cadence scriptable) |
| forge-seo | route to reference file(s) | two-row keyword table | **shell** (keyword matcher) — highest-leverage router win |
| forge-seo | companion-skill selection; verify live sources | fixed lists | **shell** |
| forge-seo | apply reference guidance to the task | code/UX judgment | keep-as-model |
| forge-setup | clone, harness probe, grep inventory, sed swaps, verify, install | verbatim shell | **shell** / **MCP** `forge_mcp.harness_adapt` |
| forge-setup | research harness equivalents; identity-skip decision | research judgment | keep-as-model (fallbacks templated) |
| forge-tailwindcss-conventions | version detect; framework detect | manifest checks | **shell** |
| forge-tailwindcss-conventions | class ordering; anti-patterns; verification checklist | tooled rules | **linter** (defer to `prettier-plugin-tailwindcss` / `eslint-plugin-tailwindcss`) |
| forge-tailwindcss-conventions | token authoring; component extraction | design judgment | keep-as-model |
| frontend-design | token-plan shape (colors, roles, layout, signature) | fixed output skeleton | premade template |
| frontend-design | palette/type/signature choices | creative core | keep-as-model (the skill's entire purpose) |
| frontend-design | AI-default check; quality floor; copy rules | enumerated lists | **linter** |
| git-issue-tracker | create/read/label/close ops | fixed `gh` shapes | **MCP** (typed wrappers) |
| git-issue-tracker | sub-issue wiring; blocked_by; frontier; claim; resolve | fixed `gh api` endpoints | **MCP** `forge_mcp.sub_issue_add`, `blocked_by_add`, `frontier`, `claim`, `resolve` |
| git-issue-tracker | branch association (slug + pointer + fallbacks) | fixed rule chain | **MCP** `forge_mcp.map_branch` |
| git-issue-tracker | title/body content | wording | keep-as-model (label enum is fixed) |
| grilling | question format; wave cap; cadence; done-check | fixed protocol | Node+template (tree-as-data wrapper) |
| grilling | fact-needs routed to sub-agents | fixed rule | **AgentSwarm** `{{item}}` |
| grilling | tree decomposition; frontier picks; recommendations | interview judgment | keep-as-model |
| kiss-principle | moving-part counts; anti-pattern match; dep counts | numeric/table lookups | **shell** / **MCP** `forge_mcp.complexity_scan` |
| kiss-principle | proportionality call; simpler alternative | design judgment | keep-as-model |
| loops | argv parse, render, `kimi -p`, status grep, exit codes | zero-judgment plumbing | **shell as-is** → **Node** (ADR 0007 migration) |
| loops | template authoring (caller's job) | prompt content | keep-as-model |
| planning-and-task-breakdown | plan mode + approval gate | harness plan tooling | harness |
| planning-and-task-breakdown | task/plan templates; checkpoint placement; verification checklist | fixed templates/rules | premade template + **linter** |
| planning-and-task-breakdown | dependency graph; vertical slicing; sizing; risk | slicing judgment | keep-as-model (+ **shell** topological sort) |
| planning-and-task-breakdown | parallel dispatch | fan-out | **AgentSwarm** `{{item}}` |
| pr-resolve | worktree; collect comments; triage; group | fixed queries + rule table | **MCP** `collect_review_comments`, `triage_comments`, `group_findings` + Node wrapper |
| pr-resolve | resolve-loop dispatch; integrate; push; thread replies | fixed loop + typed replies | Node+template + **MCP** `reply_to_review_thread`, `post_review_summary` |
| pr-resolve | fix content (guard, early-return, …) | resolver judgment | keep-as-model |
| pr-review | worktree setup; VALIDATE hard rules | fixed scripts | **shell as-is** + Node wrapper |
| pr-review | REVIEW loop over diff | model-in-loop | Node+template (`templates/review-loop.md`) |
| pr-review | POST review; identity check; handoff | typed API calls | **MCP** `forge_mcp.post_review`, `identify_user` |
| prototype | branch pick (LOGIC vs UI); placement; naming | keyword + path rules | **shell** |
| prototype | artifact skeletons; state-dump; no-persistence | fixed templates/rules | premade template + **linter** |
| prototype | edge-case selection; state-model fidelity | the prototype's point | keep-as-model |
| prototype | capture ritual (throwaway branch + issue pointer) | fixed commands | **shell** / **MCP** `forge_mcp.prototype_branch` |
| resolving-merge-conflicts | state inspection; run checks; stage/commit/continue | fixed commands | **shell** / **MCP** `forge_mcp.merge_state` |
| resolving-merge-conflicts | intent extraction; per-hunk resolution | semantic merge work | keep-as-model |
| resolving-merge-conflicts | SDD handoff threshold; per-file fix dispatch | count rule + fan-out | Node wrapper + **AgentSwarm** `{{item}}` |
| ste100 | word/sentence caps; approved words; idioms; modals | fixed rule set | **linter** (**MCP** `forge_mcp.ste100_lint`) |
| ste100 | fact preservation; format preservation | diffable constraints | **linter** / **MCP** `forge_mcp.fact_loss` |
| ste100 | compression (keep/cut); topic splits; editorial | prose judgment | keep-as-model |
| subagent-driven-development | worktree setup; pre-flight scan; diff generation | fixed commands | Node wrapper |
| subagent-driven-development | implementer + reviewer dispatch | homogeneous fan-out | **AgentSwarm** `{{item}}` |
| subagent-driven-development | report routing; fix-loop classification; breaker | adjudication judgment | keep-as-model (loop shell → Node wrapper) |
| subagent-driven-development | squash-merge integrate; pre-PR cross-check | fixed commands + gate | Node wrapper + verification-before-completion |
| use-git-identity | variant pick; set config; `-c` one-off; amend | fixed command forms | **shell** / **MCP** `forge_mcp.git_identity` |
| use-git-identity | identity value source (defaults vs post-install) | file-read rule | **shell** (values-as-data read) |
| using-git-worktrees | detect isolation; submodule guard; sync; create; setup | fixed command blocks | **shell** / **MCP** `forge_mcp.worktree_create` |
| using-git-worktrees | baseline runner detect; "no runner → flag" | fixed candidate list | **shell** (fail-loud on no match) |
| using-git-worktrees | consent gate; cleanup timing ("work landed") | state rules | **shell** (gh/git state gates) |
| verification-before-completion | RUN/READ; red-green cycle; diff checks | fixed procedures | **shell** / **MCP** `forge_mcp.verify` |
| verification-before-completion | claim-format gate; hedge-word ban | fixed rules | **linter** + wrapper gate (no evidence → no claim) |
| verification-before-completion | IDENTIFY (pick the proving command); VERIFY (interpret) | evidence judgment | keep-as-model |
| wayfinder | map/ticket creation; blocking; claim; decisions append | typed tracker ops | **MCP** `create_map`, `create_ticket`, `add_blocking`, `claim`, `append_decision` |
| wayfinder | label setup script | existing script | **shell as-is** |
| wayfinder | research subagent fan-out | homogeneous dispatch | **AgentSwarm** `{{item}}` |
| wayfinder | destination naming; frontier slicing; resolve | chart-mode judgment | keep-as-model (ADR 0005 #5) |

## Aggregate counts (seam-level, this matrix)

| Mechanism | Seams | Share |
|-----------|-------|-------|
| keep-as-model | 31 | ~30% |
| MCP (`forge-mcp`) | 24 | ~23% |
| shell script (incl. as-is) | 33 | ~32% |
| Node+template | 10 | ~10% |
| AgentSwarm `{{item}}` | 9 | ~9% |
| linter | 13 | ~12% |
| harness (no work) | 4 | ~4% |

(Rows can carry a primary + secondary mechanism; percentages exceed 100%.)

## Cross-cutting findings

1. **The model is a router and an author, not a sysadmin.** Every sampled skill executes its fixed commands/templates exactly as written; the deviations the samples caught were all *spec bugs* (see anomalies), never model disobedience. Determinism work should target the ops surface, not model behaviour.
2. **Tracker ops are the densest MCP cluster.** `git-issue-tracker`, `wayfinder`, `pr-review`, `pr-resolve`, `forge`, `forge-flow` all wrap the same `gh api` shapes (sub_issues, dependencies/blocked_by, reviews, comments). One `forge-mcp` tool family covers all of them — this is T2's core surface.
3. **The commit-format linter is a shared win.** `caveman-commit` and `conventional-commits` need the same `commit-msg`-style validator; build once.
4. **Verification-style linters generalize.** STE100 rules, caveman drop lists, frontend-design's three AI defaults, and the banned-opener list are all the same shape: fixed rule set + text check. A generic `forge_mcp.lint(text, ruleset)` covers four skills.
5. **Fan-out is already solved.** Every parallel-dispatch seam across `dispatching-parallel-agents`, `subagent-driven-development`, `deep-research`, `grilling`, `wayfinder`, `resolving-merge-conflicts`, `planning-and-task-breakdown`, and `forge` is the same AgentSwarm `{{item}}` pattern. No new mechanism needed — T3 should confirm, not redesign.
6. **Judgment cores are small and consistent.** Across all 35 skills the keep-as-model residue is: naming/summarizing (commit subjects, PR TL;DRs, destinations), slicing/decomposition (vertical slices, design trees, domains), prioritization/proportionality, and creative/design choices. This matches ADR 0005 #5's list with no new categories.
7. **Honesty invariants are scriptable.** "No fake green" (using-git-worktrees), "no claim without evidence" (verification-before-completion), "never merge to main" (finishing-a-development-branch), "never `--abort`" (resolving-merge-conflicts) are all state gates a wrapper can enforce.

## Anomalies surfaced by sampling (follow-ups, not T1 scope)

- `forge-tailwindcss-conventions/SKILL.md`: numbered class-order list (colors before effects) contradicts its own canonical example (effects `rounded-lg` before colors). The model followed the example because `prettier-plugin-tailwindcss` is the declared enforcer. Fix the doc so list and example agree.
- `docs/dev/agents/` had no `README.md` before this ticket despite the `forge-docs` index mandate; this commit adds one.
- `frontend-design` and creative skills: single-sample evidence is thin (ADR 0004 risk note) but the recommendation is keep-as-model for the core, so mis-judgment risk is low.

## Unusable logs

None. All 35 logs are present, non-empty, exit code 0, and contain both the raw stdout and the model's meta-decisions.

## Downstream feeds

- **T2 (MCP tool-surface proposal):** the 24 MCP rows above, deduplicated into one `forge-mcp` tool family (tracker ops, scans, lint, verify, worktree/identity/docs utilities).
- **T3 (mechanism assignment matrix):** this matrix is the draft; HITL review per ADR 0004's risk note.
- **T4 (Node wrapper migration):** the 10 Node+template rows plus ADR 0007's `loops` migration; the fix-loop orchestrator in `subagent-driven-development` is the largest single wrapper.
- **T7 (policy/contract tests):** the I/O contracts in each per-skill artifact are the test corpus; the cross-cutting honesty invariants (finding 7) are the first contract tests to write.
