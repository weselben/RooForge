This is a letter from me — the engineer, the user — to you — the agent, the harness, whatever you call yourself. I am writing down what you must know to work this repo the way I intend. Read it. Follow it. No hedge.

This repository is a curated collection of skills. The `skills/` directory at the root holds one subfolder per skill — the folder name is the skill name (`skills/caveman/` is the caveman skill, `skills/forge/` is the forge skill, etc.). Skills in this repo are not tools you can call directly. They are prompt-engineering artefacts — text contracts that define behaviour. You read a skill's `SKILL.md`, you know what it does, you invoke it by following the procedure it describes. You do not call skills via a tool.

When the user or I write to you about a skill by name, or ask you to change a skill, search the `skills/` directory for a matching subfolder before doing anything else. The skill's source of truth is `skills/<name>/SKILL.md`; treat any other reference as a pointer, not as the canonical content.

When you change any skill in `skills/`, the change must travel with its index updates. Update `README.md` (global skills table, source links, install section) in the same commit, and update any corresponding guide under `docs/guides/<skill>.md` if the public-facing behaviour changed. Per-skill commits, one scope per commit, conventional commit format — never bundle several skills into one commit, never split a single skill change across many.

A skill is a loadable unit of behaviour, not a library. You read its `SKILL.md`, you know what it does, you need to imagine to call it when the situation matches its trigger. You do not need to run it to know whether it applies. The work in this repo is shaping the skills themselves and the conventions they encode.

The conventional commit format governs every commit on this repo. The type is one of the standard Conventional Commits types. The scope, when there is one, is the name of the skill the commit touches, in parentheses. The title is a short imperative summary, no trailing period. A body goes below when the why is not obvious from the title.

`docs/` follows a small fixed structure owned by `forge-docs`: `adr/` for architecture decision records (no subfolders, no index file — the glossary in `docs/dev/CONTEXT.md` is the index), `dev/` for internal artefacts with a `CONTEXT.md` glossary, `dev/agents/` for deep research reports, `guides/` for how-to notes, `system-design/` for architecture notes, `public/` for external-facing text. Every subfolder that holds files keeps a `README.md` that lists its contents. The global `docs/README.md` lists the subfolders.

Read the repo before you change it. When a change introduces a new file, update the matching subfolder's `README.md` in the same commit. When a change introduces a new architectural decision, write an ADR in `docs/adr/` and cross-reference it from `docs/dev/CONTEXT.md`.

This file is a local contract between us. It is not a skill, not a tool, not part of the public surface. Treat its rules as you would treat the ones in any other skill: read once at the start of a session, follow them, do not negotiate.

The `forge-setup` skill lives at `skills/forge-setup/SKILL.md`. That file is the single source of truth for the harness-adaptation procedure — load it from there when needed; do not duplicate its contents in this contract.