# Determinism mechanism matrix — locked

**Status:** Locked 2026-08-24. T2 (#33) and T3 (#34) close against this artifact.

**Map issue:** #31
**Tickets:** T2 #33 (proposal — closing), T3 #34 (this lock — closing), T2-A #85 … T2-J #94 (sub-decisions — closing), reopen push-backs #43, #52, #57, #73, #75 (closing).

## Mechanism legend (3 types, per ADR 0005 rewrite)

- **MCP** — typed tool on `forge-mcp`. Folds in shell, Node wrappers, linters, scanners, wrappers (T3 wave 1 collapse).
- **AgentSwarm** — `AgentSwarm` builtin with `{{item}}` templates. Thin shim `forge_mcp.spawn` adds audit + reservation + flow-prefix (T2-E).
- **keep-as-model** — judgement stays with the model, with stated rationale. Residue is small: naming, slicing, prioritization, creative choices.
- **harness** — already deterministic harness behaviour; no work needed (sub-feature, not a new type).

## Matrix

| Skill | Step | T1 mechanism | Locked | User-amendment |
|-------|------|--------------|--------|----------------|
| 12-factor-app | load factor + mistakes tables | harness | harness | sidecar layout (T2-A) |
| 12-factor-app | map stated defect → factor | Node+template | MCP | sidecar layout (T2-A) |
| 12-factor-app | repo fact scan | MCP | MCP | — |
| 12-factor-app | infer implied factors; prioritize | keep-as-model | keep-as-model | — |
| caveman | mode activation | harness | harness | co-loaded with ste100 at start (T2-B) |
| caveman | drop lists | linter | MCP | — |
| caveman | preservation rules | linter | MCP | — |
| caveman | fact selection | keep-as-model | keep-as-model | — |
| caveman-commit | read diff | shell | MCP | `forge_mcp.git_diff` (T2-C) |
| caveman-commit | type/scope pick | shell | MCP | heuristic |
| caveman-commit | format rules | linter | MCP | shared with conventional-commits |
| caveman-commit | subject wording; body why | keep-as-model | keep-as-model | wraps kimi -p via `forge_mcp.commit_files` → `run_loop` |
| caveman-commit | direct OpenAI call | — | deferred | Future ADR per user; not now (#43) |
| caveman-review | obtain diff | shell | MCP | — |
| caveman-review | finding format + severity | linter | MCP | — |
| caveman-review | spot bug; dedup; phrase fix | keep-as-model | keep-as-model | — |
| conventional-commits | format shape | linter | MCP | folded into caveman-commit (#43 amendment) |
| conventional-commits | type enum pick | shell | MCP | — |
| conventional-commits | subject/body wording | keep-as-model | keep-as-model | — |
| creating-pull-requests | gather diff/stat/commits | shell | MCP | — |
| creating-pull-requests | size gate → section budget | shell | MCP | — |
| creating-pull-requests | draft flag, disclosure, `--body-file` | shell + template | MCP | — |
| creating-pull-requests | title/TL;DR/files-table content | keep-as-model | keep-as-model | — |
| creating-pull-requests | banned openers, noun-stack | linter | MCP | — |
| deep-research | output path; report skeleton | shell + template | MCP | — |
| deep-research | per-round Think/Summary cadence | Node+template | MCP | — |
| deep-research | parallel sub-question dispatch | AgentSwarm | AgentSwarm | — |
| deep-research | query design; source selection | keep-as-model | keep-as-model | — |
| dispatching-parallel-agents | identify independent domains | keep-as-model | keep-as-model | (T2-E) |
| dispatching-parallel-agents | AgentSwarm dispatch | AgentSwarm | AgentSwarm | via `forge_mcp.spawn` shim; main chat = master orchestrator calling kimi -p via MCP (T2-E) |
| dispatching-parallel-agents | MANDATORY FIRST block | template | MCP | — |
| domain-modeling | file locations, formats, lazy-create | shell + template | MCP | `forge_mcp.record_adr` + `forge_mcp.next_adr_number` (T2-F) |
| domain-modeling | glossary constraint; ADR 3-criteria | linter + Node | MCP | `forge_mcp.lint` + `forge_mcp.adr_offer_test` (T2-F) |
| domain-modeling | detect conflict; coin canonical term | keep-as-model | keep-as-model | (+ `forge_mcp.term_lookup`) (T2-F) |
| domain-modeling | automatic ADR+PR pipeline | — | MCP | 12-step pipeline, 12 `forge_mcp.*` tools, per-ADR PR (T2-F design shipped) |
| finishing-a-development-branch | verify tests; env detect; squash-merge | shell + Node | MCP | — |
| finishing-a-development-branch | confirm base; interpret red tests | keep-as-model | keep-as-model | — |
| finishing-a-development-branch | never-merge-to-main guard | shell | MCP | — |
| forge-cleanup | detect candidates (5 command classes) | shell / MCP | MCP | per-project checkoff (T2-D amendment) |
| forge-cleanup | per-candidate prompt, ordering | shell | MCP | agents check off docker/other; cleanup deterministic; wrapper instances undeterministic (#52 amendment) |
| forge-cleanup | escalate to repo-level `reset --hard` | keep-as-model | keep-as-model | — |
| forge-cleanup | public-PR cleanup option | — | MCP | drop from commit history OR skip commit entirely for non-forge repos; agents subdir in docs cleaned (T2-D amendment) |
| forge-cleanup | stale kimi wrapper cleanup | — | MCP | blocked by T3 wave 3 job queue |
| forge-docs | trigger → affected sub-folder | shell / MCP | MCP | `forge_mcp.init_repo` mode=docs (T2-D) |
| forge-docs | sub-README templates; same-commit | template + shell | MCP | — |
| forge-docs | one-line "why it exists" | keep-as-model | keep-as-model | — |
| forge-eu-accessibility | scope classification | shell | MCP | — |
| forge-eu-accessibility | WCAG audit | MCP + keep-as-model | MCP | — |
| forge-eu-accessibility | exemption assessments | keep-as-model | keep-as-model | — |
| forge-eu-accessibility | live legal source verification | shell | MCP | — |
| forge-flow | detect map; reuse-vs-create | MCP | MCP | — |
| forge-flow | derive `feat/<slug>` | Node+template | MCP | — |
| forge-flow | cut branch; goal; handoff | shell + template | MCP | — |
| forge-flow | flow as systemprompt section | — | (cross-cutting) | `[FORGE-*]` prefix injected into kimi -p prompts by wrapper; forge skill read for glossary (#57 amendment) |
| forge-init | AGENTS.md detect/prepend/append/merge | shell / MCP | MCP | `forge_mcp.init_repo` mode=init (T2-D) |
| forge-init | grilling waves for repo specifics | keep-as-model | keep-as-model | — |
| forge-seo | route to reference file(s) | shell | MCP | — |
| forge-seo | companion-skill selection | shell | MCP | — |
| forge-seo | apply reference guidance | keep-as-model | keep-as-model | — |
| forge-setup | clone, harness probe, grep inventory | shell / MCP | MCP | `forge_mcp.setup_repo` (T2-D) |
| forge-setup | research harness equivalents | keep-as-model | keep-as-model | — |
| forge-tailwindcss-conventions | version detect; framework detect | shell | MCP | — |
| forge-tailwindcss-conventions | class ordering; anti-patterns | linter | MCP | — |
| forge-tailwindcss-conventions | token authoring | keep-as-model | keep-as-model | — |
| frontend-design | token-plan shape | template | MCP | — |
| frontend-design | palette/type/signature choices | keep-as-model | keep-as-model | — |
| frontend-design | AI-default check; quality floor | linter | MCP | — |
| git-issue-tracker | create/read/label/close | MCP | MCP | densest cluster |
| git-issue-tracker | sub-issue wiring; blocked_by; frontier; claim; resolve | MCP | MCP | — |
| git-issue-tracker | branch association | MCP | MCP | — |
| git-issue-tracker | title/body content | keep-as-model | keep-as-model | — |
| grilling | question format; wave cap; cadence | Node+template | MCP | — |
| grilling | fact-needs routed to sub-agents | AgentSwarm | AgentSwarm | — |
| grilling | tree decomposition; frontier picks | keep-as-model | keep-as-model | — |
| kiss-principle | moving-part counts | shell / MCP | MCP | — |
| kiss-principle | proportionality call | keep-as-model | keep-as-model | — |
| loops | argv parse, render, `kimi -p`, exit codes | shell → Node | (dropped) | skill folder deleted; templates moved to each skill's reference subfolder; executable folds into `forge_mcp.run_loop` (T2-J) |
| loops | template authoring | keep-as-model | keep-as-model | — |
| planning-and-task-breakdown | plan mode + approval gate | harness | harness | — |
| planning-and-task-breakdown | task/plan templates | template + linter | MCP | — |
| planning-and-task-breakdown | dependency graph; slicing; sizing; risk | keep-as-model | keep-as-model | — |
| planning-and-task-breakdown | parallel dispatch | AgentSwarm | AgentSwarm | — |
| pr-resolve | worktree; collect comments; triage | MCP + Node | MCP | — |
| pr-resolve | resolve-loop dispatch; integrate; push; thread replies | Node+template + MCP | MCP | — |
| pr-resolve | fix content | keep-as-model | keep-as-model | — |
| pr-review | worktree setup; VALIDATE hard rules | shell + Node | MCP | — |
| pr-review | REVIEW loop over diff | Node+template | MCP | — |
| pr-review | POST review; identity check; handoff | MCP | MCP | — |
| prototype | branch pick | shell | MCP | — |
| prototype | artifact skeletons; state-dump | template + linter | MCP | — |
| prototype | edge-case selection; state-model fidelity | keep-as-model | keep-as-model | — |
| prototype | capture ritual | shell / MCP | MCP | — |
| resolving-merge-conflicts | state inspection; stage/commit/continue | shell / MCP | MCP | — |
| resolving-merge-conflicts | intent extraction; per-hunk | keep-as-model | keep-as-model | — |
| resolving-merge-conflicts | SDD handoff threshold | Node + AgentSwarm | MCP | — |
| ste100 | word/sentence caps; approved words; idioms | linter | MCP | co-loaded with caveman at start via systemprompt adaptation (T2-B amendment) |
| ste100 | fact preservation; format preservation | linter | MCP | — |
| ste100 | compression; topic splits | keep-as-model | keep-as-model | — |
| subagent-driven-development | worktree setup; pre-flight | Node wrapper | MCP | — |
| subagent-driven-development | implementer + reviewer dispatch | AgentSwarm | AgentSwarm | — |
| subagent-driven-development | report routing; fix-loop classification | keep-as-model | keep-as-model | — |
| subagent-driven-development | squash-merge integrate | Node wrapper + verify | MCP | — |
| use-git-identity | variant pick; set config | shell / MCP | MCP | `forge_mcp.git_identity` (T2-H) — 95% of commit work via MCP server; predefined coauthor (#73 amendment) |
| use-git-identity | identity value source | shell | MCP | — |
| using-git-worktrees | detect isolation; submodule guard; sync; create | shell / MCP | MCP | — |
| using-git-worktrees | baseline runner detect | shell | MCP | — |
| using-git-worktrees | consent gate; cleanup timing | shell | MCP | — |
| verification-before-completion | RUN/READ; red-green cycle | shell / MCP | MCP | `forge_mcp.verify` mode=evidence |
| verification-before-completion | claim-format gate; hedge-word ban | linter + gate | MCP | — |
| verification-before-completion | IDENTIFY (pick proving command); VERIFY | keep-as-model | keep-as-model | — |
| verification-before-completion | **post-merge verify loop** | — | MCP | runs as last step after squash-merge to feat branch; iterates files touched in worktree; checks against input "goal/claim"; new mode `post_merge_verify` (T2-I amendment) |
| wayfinder | map/ticket creation; blocking; claim | MCP | MCP | — |
| wayfinder | label setup | shell as-is | MCP | — |
| wayfinder | research subagent fan-out | AgentSwarm | AgentSwarm | — |
| wayfinder | destination naming; frontier slicing | keep-as-model | keep-as-model | — |

## Aggregate counts (locked)

| Mechanism | Seams | Share |
|-----------|-------|-------|
| MCP (`forge-mcp`) | ~76 | ~74% |
| AgentSwarm | 9 | ~9% |
| keep-as-model | ~30 | ~29% |
| harness | 4 | ~4% |
| dropped (loops skill) | -2 | — |

(Rows can carry a primary + sub-feature; percentages exceed 100%.)

## Deferred / out-of-scope

- **Direct OpenAI call for commit messages** (#43 amendment) → future ADR when ADR 0008 reactivates. Single skill `caveman-commit` covers conventional-commits for now.
- **Stale kimi wrapper cleanup in forge-cleanup** → blocked by T3 wave 3 job queue; default `wrappers=false` until queue ships.
- **Open skill-naming-conventions PR** → referenced by T2-G; do not modify.

## Pending research (sub-tickets spawned for follow-up)

- **T2-C kimi -p with context** (#87 follow-up) — can `kimi -p` be started with project context for `commit_files`? Research spawned.
- **T2-E MCP wrapping kimi tool calls** (#89 follow-up) — feasible? If not, main chat calls kimi -p directly outside MCP. Research spawned.
- **T2-G kimi harness systemprompt default + skill-naming PR** (#91 follow-up) — exact mechanism + PR number. Research spawned.

## Related

- Map: #31 (`docs/dev/CONTEXT.md`)
- T1 sampling: #32 (closed)
- T2 proposal: #33 (closing against this matrix)
- T3 matrix lock: #34 (closing with this artifact)
- T2 sub-decisions: #85–#94 (closing — user amended all)
- Push-back reopenings: #43, #52, #57, #73, #75 (closing — user re-answered all)
- T7 (#38) verify tool → folded into MCP `forge_mcp.verify` modes (post-merge verify added)
- T18 (#83) trust model → encoded in ADR 0006 amendment
- ADR 0005 rewrite: `docs/adr/0005-mechanism-assignment-policy.md` (3-type policy)
- ADR 0006 amendment: `docs/adr/0006-build-forge-mcp-server.md` (T18 trust model + timeout-estimator-deferred note)
- T1 seams draft: `docs/dev/agents/determinism-seams-summary.md`