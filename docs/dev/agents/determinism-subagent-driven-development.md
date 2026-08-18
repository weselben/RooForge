# Determinism sampling — subagent-driven-development

Sampling pass per ADR 0004. Raw stdout at `.tmp-determinism/logs/subagent-driven-development.log` (gitignored).

## Sample

- **Task:** SDD over two independent tasks T1=add README badge, T2=add LICENSE, integration branch `feat/init`.
- **Run:** `kimi -p` on 2026-08-18T01:30:53Z, exit 0, 118 lines.
- **Outcome:** produced a 7-step trace with a precise mechanical/judgment split; correctly identified worktree creation, BASE-sha diff generation, and squash-merge as mechanical; identified spec-vs-defect adjudication, fix-loop classification, and breaker adjudication as judgment.

## Observed meta-decisions

- Named the four-item implementer report (branch, commits, tests, summary) verbatim from the skill.
- Recognised the `AgentSwarm` + `{{item}}` dispatch as the canonical fan-out shape.
- Distinguished the `Agent(resume=...)` rounds 1-3 from the fresh-dispatch rounds 4-5 (correct).
- Identified step 7's `verification-before-completion` cross-check as the gate before "done".
- Did **not** modify files.

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Setup — read plan, confirm integration branch, create one worktree per task off integration | integration-branch confirmation (ask if unclear); pre-flight conflict scan | `git worktree add` shell | **Node wrapper** that reads the integration branch + per-task spec and creates worktrees. | input: plan + integration_branch; output: worktree_paths[]; gate: each worktree's baseline suite is green. |
| 2 | Pre-flight conflict scan | medium — batch into one question | scan shell | **Node wrapper** that does the textual pre-flight and returns the question list. | input: tasks[]; output: `questions[]` or `null` if none. |
| 3 | Dispatch implementer swarm — one `AgentSwarm` call, `prompt_template` with `{{item}}`, `subagent_type: coder` | homogeneous fan-out over independent tasks | full dispatch shape | **AgentSwarm `{{item}}`** — already the canonical mechanism (ADR 0005 #3); keep. | input: implementer template + items[]; output: implementer reports[]. |
| 4 | Handle implementer report — route by status (`DONE` / `DONE_WITH_CONCERNS` / `NEEDS_CONTEXT` / `BLOCKED`) | high — split-vs-escalate vs fill-context vs assess-concerns | none on the happy path; judgment on others | **keep-as-model** — the skill already enumerates the four branches. | input: report; output: next action. |
| 5 | Per-task review — record BASE, generate diff (`git log`/`diff --stat`/`diff -U10`), dispatch read-only `explore` reviewer | reviewer verdicts (spec compliance AND task quality) | diff generation | **Node wrapper** that produces the diff path; reviewer dispatch is `AgentSwarm` over reviewers. | input: BASE, HEAD, slug; output: diff_path; reviewer returns `{spec: pass/fail, quality: pass/fail, findings[]}`. |
| 6 | Fix loop — rounds 1-3 `Agent(resume=...)`, rounds 4-5 fresh, scoped re-review after each | high — classify finding (Critical/Important/spec-❌ / minor / plan-mandated); at cap adjudicate | dispatch shell | **Node wrapper** orchestrating the resume/dispatch and the scoped re-review; **keep-as-model** for the classification and the breaker adjudication. | input: findings, round; output: next prompt or breaker ruling. |
| 7 | Final whole-branch review — one reviewer on most-capable model over full range | high — triage deferred-minor + parked | dispatch shell | **AgentSwarm** for the dispatch; **keep-as-model** for triage. | input: branch range + parked list; output: residual findings[]. |
| 8 | Integrate — `git merge --squash <task-slug>` per task; one Conventional Commit per task | conventional-commit wording (commit subject) | full squash-merge shell | **Node wrapper** around `merge --squash` + commit message render. | input: integration_branch, task_branches[], commit_subjects[]; output: integration_branch sha; gate: full suite green. |
| 9 | Pre-PR cross-check — `verification-before-completion` re-verifies each implementer's claim against `git status` + suite | none — gate is mechanical | full | covered by `verification-before-completion` artifact. | gate: every claim has fresh evidence. |

## Notes

- The dispatch is **already AgentSwarm-native** (ADR 0005 #3). No rework needed there.
- The biggest **Node wrapper** opportunity is the **fix-loop orchestrator** — the rounds, resume-vs-fresh, and scoped re-review are all mechanical shells wrapped around a model decision (the classification).
- The **breaker adjudication** (cap-exceeded handling) is a clear keep-as-model case — ADR 0005 #5 explicitly lists it.
- The **four-item implementer report contract** should become a typed I/O contract enforced by the wrapper, not a prose paragraph the subagent writes.