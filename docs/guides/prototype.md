# prototype

Build throwaway code to answer a design question. The skill splits into two branches by question type: a single self-contained HTML file that lets a non-developer drive a state model through free-play buttons and guided walkthroughs (logic), or several radically different UI variants on one route, switchable via a `?variant=` URL param and a floating bottom bar (UI). Either way the prototype is captured to a throwaway branch after the question is settled, and only the validated decision lands in main.

## When to load

Trigger phrases drawn from `SKILL.md` and the branch docs:

- "Does this logic / state model feel right?" → `LOGIC.md` branch.
- "Does this state machine handle the edge case where X then Y?" / "Does this data model actually let me represent…" → `LOGIC.md`.
- "I want to feel out what the API should look like before writing it." → `LOGIC.md`.
- "What should this look like?" / "I want to see a few options for this dashboard before committing." / "Try a different layout for the settings screen." → `UI.md`.
- Any forge `wayfinder:prototype` ticket — invoked by the orchestrator in `skills/forge/SKILL.md` step 2 (Resolve).

When the question is genuinely ambiguous and the user is unreachable, `SKILL.md` defaults to whichever branch matches the surrounding code (backend module → logic; page or component → UI) and states the assumption at the top of the prototype (`SKILL.md` line 15).

## How it works

1. **Pick a branch** based on the question (`SKILL.md` lines 9–13): state/logic/data-shape → `LOGIC.md`; visual layout → `UI.md`. Mis-picking wastes the whole prototype.
2. **State the question** before coding — one paragraph at the top of the artifact in a visible intro (`LOGIC.md` line 13; `UI.md` line 22). A logic prototype answers the wrong question is pure waste.
3. **Logic branch — isolate logic in a portable module.** A `<script>` block written as a pure module: reducer, state machine, set of pure functions, or class with clear method surface (`LOGIC.md` lines 21–31). No DOM, no `document`, no button handlers reaching inside — the page calls into it, not the other way. This is what makes it liftable into the real module later.
4. **Logic branch — build the shareable HTML.** One file, plain HTML/CSS/JS, no framework, no bundler, no server (`LOGIC.md` lines 33–43). Layout: title and one-line explanation; current state panel re-rendered after every click; free-play buttons (one per action); tabbed guided walkthroughs with scenarios that cover the awkward cases. Domain language, not code. Clean typography, generous spacing, one accent colour.
5. **UI branch — pick N variants.** Default 3, cap 5 (`UI.md` line 22). Plan written in one line at the top, e.g. `"Three variants of the settings page, switchable via ?variant=, on the existing /settings route."` (`UI.md` line 27).
6. **UI branch — generate structurally different variants.** Different layout, information hierarchy, and primary affordance — not just colour or copy (`UI.md` lines 31–34). Default to sub-shape A: variants on an existing route gated by `?variant=`, keeping the existing data fetching and auth intact (`UI.md` lines 18–20). Reach for sub-shape B (a throwaway route under whatever convention the project already uses) only when nothing sensible hosts it.
7. **UI branch — wire the switcher.** Pseudo-code at `UI.md` lines 40–48: read `?variant` from the URL, render the matching variant plus a `PrototypeSwitcher`. Update the URL via the framework router (`router.replace` on Next, `navigate` on React Router) so the variant is shareable and reload-stable (`UI.md` lines 57–60).
8. **UI branch — build the floating switcher.** Fixed-position bar, bottom-centre: left arrow, label (`B — Sidebar layout`), right arrow, wraps around (`UI.md` lines 51–53). Keyboard `←`/`→` cycles too, unless an `<input>`, `<textarea>`, or `[contenteditable]` is focused (`UI.md` line 59). Hidden in production builds (gate on `process.env.NODE_ENV !== 'production'`, `UI.md` line 61). Put the switcher in shared UI so both sub-shapes reuse it.
9. **Hand it over.** Logic: send the file or open it — non-developers click through whenever they get to it; interesting moments are "wait, that shouldn't be possible" (`LOGIC.md` line 51). UI: surface the URL and `?variant=` keys; the interesting feedback is usually a hybrid ("header from B with the sidebar from C", `UI.md` line 66).
10. **Capture.** Fold the validated decision into the real code, then capture the prototype itself as a primary source on a throwaway branch (out of main) and leave a context pointer on the implementation issue (`SKILL.md` rule 6, lines 21–23). Logic: the reducer/machine/function set lifts into the real module, the HTML shell rides along to the throwaway branch (`LOGIC.md` lines 57–60). UI: sub-shape A — fold the winner into the existing page, drop the losers and the switcher from main (`UI.md` lines 74–75); sub-shape B — promote the winning variant to a real route, drop the throwaway route and switcher from main (`UI.md` lines 76–77).

Common rules that apply to both branches, from `SKILL.md` lines 17–23:

- Throwaway from day one, clearly marked; locate next to where it will be used but obey the project's existing routing convention (`SKILL.md` rule 1).
- Trivial to run — one task-runner command for UI, double-click for logic (rule 2).
- No persistence by default; in-memory state unless the question explicitly involves a database (rule 3).
- Skip the polish — no tests, no error handling beyond what makes it runnable, no abstractions (rule 4).
- Surface the state — print or render the full relevant state after every action or variant switch (rule 5).

## Files in this skill

- `skills/prototype/SKILL.md` — frontmatter, branch picker, and the six common rules that apply to both branches.
- `skills/prototype/LOGIC.md` — logic/state-model branch: pure-module shapes, HTML layout, scenarios, anti-patterns.
- `skills/prototype/UI.md` — UI branch: variant count, sub-shape A vs B, `?variant=` wiring, floating switcher spec, anti-patterns.

## See also

- `skills/forge/SKILL.md` — orchestrator; step 2 (Resolve) invokes `prototype` when a wayfinder ticket carries the `wayfinder:prototype` label.
- `skills/prototype/LOGIC.md` — the logic branch (referenced from `SKILL.md` and `UI.md` for routing the other kind of question).
- `skills/prototype/UI.md` — the UI branch (referenced from `SKILL.md` and `LOGIC.md` for routing the other kind of question).
- `skills/wayfinder/` (referenced via `skills/forge/SKILL.md`) — charters the map whose `wayfinder:prototype` tickets dispatch this skill.
