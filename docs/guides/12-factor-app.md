# 12-factor-app

Heroku's methodology for portable, scalable, maintainable SaaS apps. Twelve core factors + six modern extensions. Framework-agnostic; applies to any language or runtime.

## When to load

- Designing, building, or reviewing SaaS / cloud-native / microservice / serverless / containerized systems.
- The user mentions 12-factor, "config in env", stateless processes, dev/prod parity, port binding, or disposability.

## How it works

**Twelve original factors** (one-line each):

1. **Codebase** — one repo per app, many deploys
2. **Dependencies** — explicitly declare and isolate
3. **Config** — store in environment
4. **Backing services** — treat as attached resources
5. **Build, Release, Run** — strictly separate stages
6. **Processes** — stateless, share-nothing
7. **Port binding** — self-contained, export via port
8. **Concurrency** — scale out via process model
9. **Disposability** — fast startup, graceful shutdown
10. **Dev/Prod parity** — keep environments similar
11. **Logs** — treat as event streams (stdout)
12. **Admin processes** — run as one-off processes

**Six modern extensions**: observability, API-first, security, progressive delivery, auth/authz, sustainability.

## Agent evaluation flow

1. Identify deployment model (VM, container, serverless, edge)
2. Check each factor systematically against the agent-check column
3. Distinguish violations from mitigations
4. Prioritize by impact: Config, Processes, Build/Release/Run are most critical
5. Suggest concrete fixes: "replace X with Y using Z approach"

## Common mistakes

- Secrets in `.env` committed to git → Vault, K8s Secrets, or cloud secret manager
- `const sessions = {}` in memory → Redis or DB session store
- `npm install && npm build && npm start` in Dockerfile → multi-stage build, run pre-built artifact
- Hardcoded DB URLs → `os.environ.get("DATABASE_URL")`
- File-based logging → stdout only, structured
- 2+ minute startup → lazy-load, defer to background workers

## Related principles

- KISS — simplicity in design
- Unix philosophy — do one thing well, compose
- Infrastructure as Code — declarative infra
- DRY — eliminate duplication without over-abstracting
- YAGNI — defer hypothetical features

## Files in this skill

- `skills/12-factor-app/SKILL.md` — full factor table, evaluation flow, common mistakes, sources

## See also

- `kiss-principle` — applies to architecture review under 12-factor
- `forge-docs` — load before writing system-design notes that cite 12-factor

## Notes

- No scripts, templates, or companion files.
- Source: https://12factor.net/.
