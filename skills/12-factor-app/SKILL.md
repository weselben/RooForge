---
name: 12-factor-app
description: "Load when designing, building, or reviewing SaaS, cloud-native apps, microservices, containerized workloads, or serverless functions — or when the user mentions 12-factor, config in env, stateless processes, or dev/prod parity."
source: https://12factor.net/
---

# 12-Factor App

> Heroku's methodology for building portable, scalable, maintainable SaaS apps. Language-agnostic.
> Modern extensions: observability, API-first, security, progressive delivery, auth, sustainability.

## The 12 Factors (Original)

| # | Factor | Core Rule | Agent Check |
|---|--------|-----------|-------------|
| I | **Codebase** | One repo per app, many deploys | Single source of truth; IaC in same repo |
| II | **Dependencies** | Explicitly declare and isolate | Manifest + lockfile; no system-wide deps; exact Docker base image versions |
| III | **Config** | Store in environment | Env vars / config systems; secrets in Vault/K8s Secrets; never in code |
| IV | **Backing Services** | Treat as attached resources | URL-based config; swappable local → managed; circuit breakers + retries |
| V | **Build, Release, Run** | Strictly separate stages | Immutable releases tagged with unique ID; no builds in production |
| VI | **Processes** | Stateless, share-nothing | No in-memory sessions; no local persistent writes; multiple instances concurrent |
| VII | **Port Binding** | Self-contained, export via port | Configurable port; standalone without external web server |
| VIII | **Concurrency** | Scale out via process model | Horizontal scaling; separate web/worker process types; no single points of failure |
| IX | **Disposability** | Fast startup, graceful shutdown | <30s startup (ideally <10s); SIGTERM handling; cattle, not pets |
| X | **Dev/Prod Parity** | Keep environments similar | Same DB type/version; Docker/IaC for parity; one-command local dev |
| XI | **Logs** | Treat as event streams | stdout only; structured (JSON); no log file management in app code |
| XII | **Admin Processes** | Run as one-off processes | Same codebase/config as app; never inside web/worker processes |

## Modern Extensions

| # | Factor | Core Rule |
|---|--------|-----------|
| XIII | **Observability** | OpenTelemetry, metrics, traces, structured logs, SLIs/SLOs |
| XIV | **API-First** | Contract-first design (OpenAPI/gRPC); consumers generate from spec |
| XV | **Security** | SBOM, image signing, zero-trust, secrets rotation, dependency scanning |
| XVI | **Progressive Delivery** | Feature flags, canary releases, blue/green deployments |
| XVII | **Auth/AuthZ** | Externalized identity (OIDC/OAuth2), RBAC/ABAC, service-to-service mTLS |
| XVIII | **Sustainability** | FinOps, right-sizing, carbon-aware computing |

## Agent Evaluation Flow

1. Identify deployment model (VM, container, serverless, edge)
2. Check each factor systematically against the checklist above
3. Distinguish violations from mitigations
4. Prioritize by impact: Config, Processes, Build/Release/Run are most critical
5. Suggest concrete fixes: "replace X with Y using Z approach"

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Secrets in `.env` committed to git | Use Vault, K8s Secrets, or cloud provider secret managers |
| `const sessions = {}` in memory | Redis or database for session storage |
| `npm install && npm build && npm start` in Dockerfile | Multi-stage Docker build; compile in stage 1, run pre-built artifact in stage 2 |
| Hardcoded DB URLs | `os.environ.get("DATABASE_URL")` |
| File-based logging | `ConsoleHandler()` → stdout |
| 2+ minute startup times | Lazy-load heavy resources; defer to background workers |

## Related Principles

- **KISS** — simplicity in design and implementation
- **Unix Philosophy** — do one thing well, compose with text streams
- **Infrastructure as Code** — declarative infrastructure management
- **DRY** — eliminate duplication without over-abstraction
- **YAGNI** — defer unnecessary features

## Source

- https://12factor.net/
- https://tadata.fr/posts/twelve-factor-app
- https://techradar.aoe.com/methods-and-patterns/12-factor-apps/
