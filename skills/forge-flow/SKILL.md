---
name: forge-flow
description: "Load when the user starts a new session on an ongoing effort — fresh chat, 'let's continue', 'pick up where we left off', or the first turn of any working session."
source: https://raw.githubusercontent.com/weselben/RooForge/main/skills/forge-flow/SKILL.md
---

# Forge Flow

Forge Flow is the **session-start bootstrap** that runs before forge step 1. It prepares the **work surface** (branch) and the **contract** (goal), then hands off to forge.

The goal is **long-living**, not per-session: it covers the full wayfinder map, which may take months to resolve. The goal is the contract; forge steps are the proof.

## Steps

### 1. Detect map

Three cases:

- **Map URL or number provided** — load it. The map defines the scope of the contract.
- **Map exists in tracker** — query for an open `wayfinder:map` issue. Load it if found.
- **No map** — hand off to forge step 1, which invokes `wayfinder` chart mode. Goal is written in step 5 with placeholder map reference.

**Completion criterion:** agent knows whether the map exists, and if so, its URL/number.

### 2. Name the feat branch

Branch name follows `feat/<slug>`.

Derive the slug from the map name when a map exists, else from the user's first turn:

- Map `"Idempotency keys for payment endpoint"` → `feat/idempotency-keys`
- Map `"Auth JWT refactor"` → `feat/auth-jwt-refactor`
- No map, user says `"fix cache race"` → `feat/cache-race-fix`

If the map already has an associated `feat/*` branch (queried via tracker convention or git), reuse it. Otherwise create new.

**Completion criterion:** a valid `feat/<slug>` name is determined, or an existing one is identified.

### 3. Create or switch to the feat branch from main

Always cut from `main` — never from another feat, hotfix, or chore branch.

```bash
git checkout main
git pull
git checkout -b feat/<slug>   # or: git checkout <existing-feat-slug>
```

**Completion criterion:** `git branch --show-current` returns the feat branch; `git merge-base --is-ancestor main HEAD` is true.

### 4. Write the contract goal

The goal is the **full map contract**, STE100-formulated. It covers the entire wayfinder map — every ticket to resolve, every decision to lock — not just today's session work. A session may resolve one ticket; the goal tracks them all.

Create with `CreateGoal` (if available), objective:

```
Complete wayfinder map "<map-title>" (map: <map-url-or-number>) — load forge skill (mandatory while goal is active). Map every open ticket, resolve every ticket, integrate via forge flow, merge PR, user merges. Goal is long-living: tracks the full map across all sessions until user merges.
```

The goal contains three mandatory fields:

1. **Forge skill reference** — the literal phrase `load forge skill (mandatory while goal is active)` ensures forge reloads on every turn where the goal is in scope.
2. **Map URL or number** — anchors the contract to a concrete tracker artefact. Include it even when chart mode creates the map mid-flow; update the goal once the map exists.
3. **STE100 prose** — short sentences, one meaning per word, no hedge. The goal text is re-injected into the agent's context on every turn; ambiguity compounds.

If the harness supports goal fields beyond `objective` (e.g. `description`, `metadata`), put the full STE100 expansion there — the map destination, the destination, the ticket summary, the standing constraints — so the agent reads the contract at full resolution when the goal enters scope.

**Update rule:** the goal is immutable from the moment it is written. Additions (new tickets, scope changes, map URL corrections) go into the goal's **description** or **metadata**, never into the **objective**. The objective is the contract; everything else is expansion.

**Completion criterion:** goal exists and is `active`; objective contains `load forge skill (mandatory while goal is active)` and the map URL/number (or explicit placeholder if no map yet).

### 5. Hand off to forge step 1

Tell the agent: "Continue with forge step 1 — load or chart the wayfinder map."

**Completion criterion:** forge skill is invoked; no further action in this skill.

## Rules

- **Always from main.** Never cut a feat branch from another dev branch.
- **One goal per map.** If a goal already exists for the map, reuse it (do not create a duplicate). Forge Flow only writes the goal when none exists.
- **Goal is the contract.** Treat the goal text as immutable after creation. Expand in metadata or description, never rewrite the objective.
- **STE100 prose.** Goal text re-injects on every turn; ambiguity compounds. Short sentences, one meaning per word.
- **No chat before step 1.** Forge Flow is silent unless it must ask the user for the feature name (when the first turn is ambiguous and no map exists).

## Boundaries

Forge Flow does not:
- Load `caveman` or `wayfinder` (forge does that)
- Chart the map or resolve tickets (forge step 1–2)
- Plan, work, verify, review, resolve (forge step 3–8)

It only prepares the work surface and the contract, then hands off.
