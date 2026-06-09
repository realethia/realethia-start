# AGENTS.md — Realethia system

Instructions for AI coding agents working across the Realethia monorepo workspace.

## Bootstrap repo

This repository (`realethia-start`) is the **entry point**. It does not contain application code. Clone sibling repos with `make clone` and open `realethia.code-workspace`.

Workspace root: parent of `realethia-start` (override with `REALETHIA_WORKSPACE`).

## System map

| Repository | Stack | Role |
|------------|-------|------|
| **ethia** | Go, PostgreSQL, Redis, Redpanda, Redpanda Connect, Debezium | Real-time news **flow engine**: ingest feeds, transform, route outputs |
| **realethia-dashboard** | Next.js 15, TypeScript, OpenAPI/Prism | **Web dashboard**; API contract in `api-spec/openapi.yaml` |
| **realethia-app** | Expo / React Native | **Mobile client** |
| **realethia-infra** | Python, K8s manifests, Hetzner k3s | **Cloud deployment** (staging/prod); not needed for default local dev |
| **realethia-research-docs** | Markdown | Draft research only — not production specs |

## Ethia (core backend)

- **Orchestrator**: CDC-driven flow management, Redis feed registry, Connect pool health
- **Poller**: RSS/feed fetch, dedup, publish to Kafka `source` topic
- **Connect**: Redpanda Connect pipelines (router, transformers, outputs)

Local stack: `ethia/infra/docker-compose.yml`. Start with `make start` from `realethia-start/` (or `make build-start` from `ethia/`).

Key paths:

- `ethia/services/orchestrator/` — orchestrator service
- `ethia/services/poller/` — poller service
- `ethia/services/connect/` — connect processors and templates
- `ethia/pkg/db/migrations/` — PostgreSQL schema
- `ethia/docs/architecture.md` — authoritative architecture doc

Secrets: `ethia/infra/.env` (from `.env.example`). Required for full functionality: `POSTGRES_PASSWORD`, Azure storage, `OPENAI_API_KEY` for AI test articles.

## Dashboard

- OpenAPI spec: `realethia-dashboard/api-spec/openapi.yaml`
- Generated types: `src/types/generated.ts` via `npm run codegen:types`
- Local dev uses **Prism mock** (`npm run mock` on :3001), not ethia, unless explicitly integrated
- Run `npm run check` before proposing PRs (format, lint, typecheck, tests)

## Mobile app

- Expo Router in `realethia-app/`
- Minimal README; follow `package.json` scripts and Expo conventions

## Infra

- Environments under `realethia-infra/envs/{staging,prod}/`
- Deploy via `make staging deploy` (requires Hetzner/cloud credentials)
- Do not confuse **Ethia orchestrator bootstrap** (Redis/DB load) with **this dev bootstrap repo**

## Conventions for agents

1. **Minimize scope** — change only the repo and files relevant to the task
2. **Match existing style** — Go in ethia, Next/React patterns in dashboard, Expo in app
3. **No secrets in commits** — never commit `.env`, keys, or connection strings
4. **ethia is source of truth** for pipeline/flow behavior; dashboard OpenAPI may lag ethia APIs
5. **research-docs** are exploratory — do not treat as implementation specs
6. Run repo-local checks: `make check` (ethia), `npm run check` (dashboard)

## Git commits

All repos follow Conventional Commits. See `.cursor/rules/git-commits.mdc`.

Format: `type: Description starting with capital letter.`

Example: `feat: Separate setup from start for local bootstrap.`

Rules for agents:

- Use `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, or `perf`
- No `Co-authored-by` trailers
- No mentions of Cursor or AI tools in messages
- Commit only when the user explicitly asks

## Local ports (default)

| Service | Port |
|---------|------|
| Ethia console | 8080 |
| Ethia PostgreSQL | 5432 |
| Ethia RSS test server | 8081 |
| Dashboard web | 4000 |
| Dashboard mock API | 3001 |
| Expo dev server | 8081 (conflicts with RSS test — run one at a time) |

## Useful commands (from realethia-start)

```bash
make setup    # clone + prepare (no start)
make start    # build and start Ethia stack
make status
make dev-all
```

Per-repo commands are documented in each repository's README and in `docs/local-development.md`.
