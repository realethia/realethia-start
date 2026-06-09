# Realethia Start

Local workspace bootstrap for the [Realethia](https://github.com/realethia) system — clone all repos, prepare local development, and provide AI-oriented context (`AGENTS.md`, Cursor rules, architecture notes).

## Quick start

Clone this repo first, then run setup from its directory:

```bash
git clone https://github.com/realethia/realethia-start.git
cd realethia-start
make setup
```

`make setup` will:

1. Check prerequisites (git, Docker, Go, Node, npm)
2. Clone sibling repos into the parent directory (e.g. `~/work/realethia/`)
3. Bootstrap local-dev repos (npm install, Ethia Docker stack)
4. Regenerate `realethia.code-workspace`

Open the multi-root workspace:

```bash
make workspace-open
```

## Workspace layout

After setup, the parent folder typically looks like:

```
realethia/                    # REALETHIA_WORKSPACE (default: parent of realethia-start)
├── realethia-start/            # this repo
├── ethia/                    # flow engine (Go + Docker Compose)
├── realethia-dashboard/      # Next.js + OpenAPI mock
├── realethia-app/            # Expo mobile app
├── realethia-infra/          # K8s / Hetzner deployment
└── realethia-research-docs/  # draft research
```

Override the workspace root:

```bash
export REALETHIA_WORKSPACE=/path/to/your/workspace
make clone
```

## Repositories

| Repo | Purpose | Local dev |
|------|---------|-----------|
| [ethia](https://github.com/realethia/ethia) | News flow engine (orchestrator, poller, connect) | Yes — Docker Compose |
| [realethia-dashboard](https://github.com/realethia/realethia-dashboard) | Web UI + API spec / Prism mock | Yes |
| [realethia-app](https://github.com/realethia/realethia-app) | React Native (Expo) | Yes |
| [realethia-infra](https://github.com/realethia/realethia-infra) | Staging/prod K8s on Hetzner | No (cloud) |
| [realethia-research-docs](https://github.com/realethia/realethia-research-docs) | Research drafts | Optional |

Canonical list: [`repos.yaml`](repos.yaml).

## Common commands

```bash
make check              # Prerequisites only
make clone              # Clone/update all repos
make bootstrap          # Prepare local-dev repos
make bootstrap-env-only # Copy ethia .env without starting Docker
make status             # Which repos are cloned
make dev-all            # Print terminal commands for full stack
```

### Ethia (backend)

```bash
cd ../ethia
cp infra/.env.example infra/.env   # if not done by bootstrap
# Fill POSTGRES_PASSWORD, OPENAI_API_KEY, Azure storage vars
make build-start                   # Build + start stack
make debezium-register             # Once after first healthy start
```

- Console: http://localhost:8080
- PostgreSQL: localhost:5432

### Dashboard (frontend + mock API)

```bash
cd ../realethia-dashboard
npm run mock    # http://localhost:3001
npm run dev     # http://localhost:4000
```

### Mobile app

```bash
cd ../realethia-app
npx expo start
```

## AI development

- [`AGENTS.md`](AGENTS.md) — system map and conventions for coding agents
- [`.cursor/rules/`](.cursor/rules/) — Cursor rules (always-on system context)
- [`docs/local-development.md`](docs/local-development.md) — detailed local dev guide
- [`docs/architecture-overview.md`](docs/architecture-overview.md) — cross-repo architecture summary

## Prerequisites

| Tool | Used by |
|------|---------|
| git | Clone repos |
| Docker + Compose | ethia local stack |
| Go 1.22+ | ethia services |
| Node 20+ / npm | dashboard, app |
| make | ethia, realethia-start |

Optional: Azure CLI / azd (dashboard deploy), kubectl + hcloud (realethia-infra), Expo Go (mobile testing).

## Adding a repository

1. Add an entry to `repos.yaml`
2. Run `make workspace` to refresh the VS Code workspace file
3. Update `AGENTS.md` and `docs/architecture-overview.md`

## License

Same as other Realethia organization repositories.
