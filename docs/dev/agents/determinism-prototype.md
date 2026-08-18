# Determinism sampling — prototype

Sampling pass per ADR 0004 (per-skill `kimi -p`). Raw stdout at `.tmp-determinism/logs/prototype.log` (gitignored).

## Sample

- **Task:** for "does the state model for wayfinder ticket dependency resolution feel right?", pick LOGIC.md vs UI.md with rationale, describe artifact shape, split mechanical vs judgment. DRY RUN.
- **Run:** `kimi -p` on 2026-08-18T01:30:06Z, exit 0, 26 log lines (incl. model reasoning).
- **Outcome:** model picked LOGIC.md (state model question, not appearance), described the single-file HTML prototype with free-play buttons + tabbed walkthroughs, and correctly placed the artifact next to the wayfinder skill (the "next to where it will be used" rule).

## Observed meta-decisions

- Read `skills/prototype/SKILL.md` first.
- Branch choice was a one-line lookup: "state model" → "does this logic feel right?" → LOGIC.md.
- Artifact placement followed the skill's "next to where it will be used" rule explicitly (file path `skills/wayfinder/prototype-*.html`).
- Chose walkthrough cases ("cycle in blocked_by, resolving a parent with open children, frontier recompute, orphan/unblock cascades") — these are the genuine edge cases for the state model, not a generic list.
- Did **not** write files (respected DRY RUN).

## Seam table

| # | Step | Judgment-call phrasing | Always-same parts | Recommended replacement | I/O contract |
|---|------|------------------------|-------------------|-------------------------|--------------|
| 1 | Pick branch (LOGIC vs UI) | low — question keywords | full — fixed two-row branch table | **shell script** — keyword match ("state model", "logic", "what should this look like", "UI") → branch. | input: question text; output: branch. |
| 2 | Choose branch artifact template | none | full — fixed template per branch | **premade prompt template** — HTML+buttons+tabs skeleton for LOGIC; route variations + bottom bar for UI. | input: subject; output: artifact skeleton. |
| 3 | Place the artifact "next to where it will be used" | low — path heuristic | mostly — `module-under-test` → adjacent file | **shell script** — `git ls-files <module-dir>` to find the containing folder; prototype lives there. | input: module path; output: artifact path. |
| 4 | Naming (clearly marked as throwaway) | none | full — fixed naming convention | **shell script** — matches `prototype-*` / `*.prototype.*` pattern. | n/a. |
| 5 | In-memory state + state dump after every action | none | full — rules 3, 5 | **premade prompt template** — wrapper provides the state-dump pattern. | input: state; output: rendered state. |
| 6 | Trivial-to-run (single command) | none | full — rule 2 | **shell script** — detect `package.json` scripts / `python` / `bun`; wire to task runner. | input: project; output: run command. |
| 7 | No persistence by default | none | full — rule 3 | **shell script** — `test` for accidental DB writes. | input: artifact; output: violations. |
| 8 | Skip polish (no tests / error handling / abstractions) | none | full — rule 4 | **linter** — refuse to emit tests in the prototype path. | input: artifact; output: violations. |
| 9 | Choose which edge cases the walkthrough covers | high — picking the right cases | none | **keep-as-model** — the cases are the point of the prototype. | input: state model; output: walkthrough plan. |
| 10 | Model the state transitions faithfully | high — semantic fidelity | none | **keep-as-model** — authoring the model. | input: subject semantics; output: state machine. |
| 11 | Capture ritual (commit to throwaway branch, context pointer on the issue, verdict in the issue) | low — command shapes fixed | full — rules enumerated | **shell script** — point at the implementation issue, commit to a branch like `throwaway/<slug>`, reference on the issue. | input: prototype + issue; output: branch + issue note. |

## Notes

- The skill is small (27 lines) and very **rule-shaped**: of 11 steps, 8 are mechanical/near-mechanical. The two judgement spots (9, 10) are also the *only* places the prototype is useful — replacing them with a deterministic tool would defeat the purpose.
- The strongest determinism win is a **`forge_mcp.prototype_branch(question, branch)` MCP tool** that creates the throwaway branch, captures the prototype, and posts the context pointer — but the model still authors the state model and walks.
- The "no persistence by default" rule is a good check for a linter: a prototype that opens a real DB connection is a tell.
- The skill's two branches produce very different artifacts (single HTML vs route variants); the branch-pick is the highest-leverage call and the simplest to script.