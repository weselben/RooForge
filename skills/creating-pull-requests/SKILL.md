---
name: creating-pull-requests
source: https://github.com/tdhopper/dotfiles2.0/blob/master/.claude/skills/creating-pull-requests/SKILL.md
description: "Write clear, size-gated PR descriptions with mandatory AI disclosure. Load `ste100` for prose. Triggers: \"create a PR\", \"open a pull request\", \"update PR description\", or pushes a branch with PR intent."
---

# Creating & Updating Pull Requests

A PR description manages a reviewer's attention. Optimize for review speed: orient in 30 seconds, answer "what changed, why, and where do I start reading?" before they open the diff.

## Critical rules

- **Draft mode.** Always create PRs with `--draft`. User marks ready.
- **AI disclosure.** End every body with: `---` + `_This PR description was generated with AI assistance._` No agent/model/tool named anywhere.
- **Ste100 prose.** Load `ste100` before drafting. Its rules govern every sentence.
- **Size gate.** Classify by `git diff --stat` before drafting. Lock in the section budget.

## Steps

### 1. Detect & gather

```bash
gh pr view --json number,title,body,baseRefName,url 2>/dev/null
BASE=$(gh pr view --json baseRefName -q '.baseRefName' 2>/dev/null || echo "main")

git diff $BASE...HEAD          # full diff
git diff $BASE...HEAD --stat   # shape
git log $BASE..HEAD --oneline  # commits
```

Read the actual diff. Search for supporting evidence — don't ask the user for what you can find.

**Done when:** diff read, shape known, links gathered.

### 2. Classify & draft

Check `git diff --stat` line count. Lock in size gate before writing:

| Size | Lines | Sections |
|------|-------|----------|
| Small | < 50 | TL;DR only |
| Medium | 50–200 | TL;DR + files table + ≤2 more |
| Large | 200+ | All that apply (files table + Reviewer notes mandatory) |

Sketch TL;DR first — it forces clarity. Fill only sections the gate allows.

**Done when:** every section written earns its space for this size.

### 3. Post-generation review

Re-read the diff. For each sentence:
1. Could the reviewer learn this from the diff? Cut it.
2. Starts with "This PR", "This change", "In this pull request"? Rewrite.
3. Section earning its space for this size? Cut the section.
4. Would you say this out loud? If not, simplify.

Confirm AI disclosure line closes the body, generic and unbranded.

**Done when:** checklist passes, disclosure in place.

### 4. Apply

Write to temp file, use `--body-file`:

```bash
# Create
gh pr create --draft --title "..." --body-file /tmp/pr-body.md
# Update
gh pr edit <number> --title "..." --body-file /tmp/pr-body.md
```

**Never** pass inline via HEREDOC or `--body`.

**Done when:** PR exists with body; on update, body reflects current full branch state (not a changelog).

## Reference

### Title format

Active voice, present tense, full scope. `<Verb> <what> [in/for/to <context>]`. Verbs: Add, Fix, Update, Remove, Refactor, Improve, Replace, Enable, Disable, Use, Make.

**Noun stacking cap: 2 consecutive nouns max.** Three+ creates a garden-path — rewrite.

### TL;DR contract

Two sentences. First: problem with concrete number/error/example. Second: what the PR does. If it can't fit in two clean sentences, you don't understand the PR well enough.

### Files table (medium+)

Mark "start here" entry point. Every file needs a one-line "Why".

### Sections (use only what earns space)

| Section | When to include |
|---------|-----------------|
| **Why** | Problem not covered by TL;DR — before/after table, screenshot, numbers |
| **How** | Design decisions (not implementation play-by-play); sequential = numbered, parallel = bullets |
| **Reviewer notes** | One bullet per non-obvious fact. Bold headline. End with focus-area bullet if needed. |
| **Visual aids** | Before/after tables, mermaid diagrams, code snippets, screenshots — only when faster than prose. Use `<details>` for supporting evidence. |
| **Tests** | What's covered, what isn't, how to run. |
| **Follow-up** | Out-of-scope work this PR sets up — only if deliberately incomplete. |
| **Links** | Ticket, Slack thread, related PRs. Inline essential context; link for depth. |

### Cut these every time

- File-by-file narration (files table + diff cover this)
- Implementation play-by-play (describe design, not your steps)
- Motivation the ticket already explains (link it, one sentence)
- Obvious type/signature changes restated (say *why* it changed)
- Defensive disclaimers (put specific questions in Reviewer notes)
- Commit-message archaeology ("In the first commit I did X...")
- Any sentence the diff already tells the reviewer

### Writing quality (disclosed AI still earns attention)

- **Openers:** Never start with "This PR", "This change", "This commit", "In this pull request". Start with the subject/problem/fact.
- **Concrete > vague:** "p50 dropped 45 ms → 3 ms" not "improved significantly".
- **Variety:** Mix sentence structures. Repetitive bullets are a tell.
- **Self-contained:** Essential context inline. Links for depth, not sole reference.
- **6-month test:** A stranger reading `git log` understands why.

### Visual aids

Before/after tables, mermaid (<15 nodes), code snippets, screenshots — only when faster than prose. `<details>` for supporting evidence. `> [!IMPORTANT]` for breaking changes. Never decorate — illustrate.

## Reviewer-friendliness checklist

Before submitting:

- [ ] AI disclosure (generic, unbranded)
- [ ] Size gate honored
- [ ] Title: full scope, active voice, ≤2 noun stack
- [ ] TL;DR: symptom + fix, concrete number
- [ ] No weak openers
- [ ] No diff echoing
- [ ] Files table marks "start here" (medium+)
- [ ] Focus area explicit if needed
- [ ] Visual aids: present where faster, absent where decorative
- [ ] 6-month test passes

## Examples

### Small PR — one-concern bug fix (~20 lines)

```
Title: Fix off-by-one in chunk boundary calculation

## TL;DR

Chunking a 10-second stereo clip at 5-second boundaries produced three chunks
instead of two — the boundary loop used `<=` instead of `<`, generating a
zero-length trailing chunk. Now uses exclusive end indices.

[DIFF-1234](url)
```

### Medium PR — routing change with visual aid

```
Title: Route small converter outputs to Bigtable instead of GCS

## TL;DR

Converter cache reads for small features (< 50 kB) hit GCS with per-object
latency — p50 of 45 ms adds up to ~8 minutes per preprocessing job on a
10k-track dataset. `RoutingCacheContext` sends small features to Bigtable
(p50: 3 ms) and keeps large features on GCS.

**Files to review (5, +287 / -34):**

| File | Why |
|---|---|
| `core/utils/caching.py` *(start here)* | New `RoutingCacheContext` — all routing logic lives here. |
| `core/constants.py` | `FeatureSizeHint` enum and Bigtable constants. |
| `converters/base.py` | Converters declare `feature_size_hint`. |
| `tests/.../test_routing_cache.py` *(new)* | 12 tests covering routing, fallback, threshold edge cases. |
| `kubernetes/bigtable/bigtable.yaml` | Column family for converter cache. |

## Why

| | GCS (current) | Bigtable (this PR) |
|---|---|---|
| p50 read latency | 45 ms | 3 ms |
| 10k-track job overhead | ~8 min | ~30 sec |

## Reviewer notes

- **Fallback on Bigtable failure.** Retries once, falls back to GCS, logs warning.
- **Threshold is declared, not measured.** Converters declare hint statically.
- No migration needed: existing GCS entries stay; new writes route by hint.
- **Focus area:** fallback logic in `RoutingCacheContext.write()` — concurrent writes.

> [!IMPORTANT]
> Cache key format unchanged. Existing GCS entries remain valid.

<details>
<summary>Bigtable capacity planning</summary>

Current cache: ~2M entries/day, 95% under 50 kB. Bigtable (3 nodes, SSD)
handles 10K reads/sec at p99 < 10 ms. Headroom: 5x current peak.

</details>

## Links

- [DIFF-5678](url)
- [Bigtable capacity planning doc](url)
```

## External reference

Full worked examples, style tables, and the complete template live in [`PR-EXAMPLES.md`](./PR-EXAMPLES.md) — load when drafting medium/large PRs. This file stays lean.