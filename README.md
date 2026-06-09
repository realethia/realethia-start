# Realethia Start

Local workspace bootstrap for the [Realethia](https://github.com/realethia) system.

## Quick start

Clone this repo first, then run setup from its directory:

```bash
git clone https://github.com/realethia/realethia-start.git
cd realethia-start
make setup
make start
```

`make setup` will:

1. Check prerequisites (git, Go, Node, npm)
2. Clone sibling repos into the parent directory (e.g. `~/work/realethia/`)
3. Prepare all repos (npm install, copy `.env` files from examples)
4. Regenerate `realethia.code-workspace`

Nothing is built or started during setup. Use `make start` to run the Ethia Docker stack.

Open the multi-root workspace:

```bash
make workspace-open
```

## Workspace layout

After setup, the parent folder typically looks like:

```
realethia/                    # REALETHIA_WORKSPACE (default: parent of realethia-start)
├── realethia-start/          # this repo
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
make setup       # Clone repos + prepare deps/env (no start)
make start       # Build and start Ethia Docker stack
make check       # Prerequisites only
make clone       # Clone/update all repos
make bootstrap   # Prepare all repos (npm, .env files)
make status      # Which repos are cloned
make dev-all     # Print commands for full local stack
```

### Ethia (backend)

After `make setup`, edit `../ethia/infra/.env` and fill secrets, then:

```bash
make start
# or: cd ../ethia && make build-start && make debezium-register
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

Org-wide agent rules live in **`realethia-start` only** (not copied into sibling repos). Open `realethia.code-workspace` so they apply across all repos.

- [`AGENTS.md`](AGENTS.md) — system map and conventions for coding agents
- [`.cursor/rules/`](.cursor/rules/) — org-wide Cursor rules (`alwaysApply`)
- [`docs/local-development.md`](docs/local-development.md) — detailed local dev guide
- [`docs/architecture-overview.md`](docs/architecture-overview.md) — cross-repo architecture summary

## Prerequisites

| Tool | Used by |
|------|---------|
| git | Clone repos |
| Go 1.22+ | ethia services |
| Node 20+ / npm | dashboard, app |
| make | ethia, realethia-start |
| Docker + Compose | `make start` (Ethia stack) |

Optional: Azure CLI / azd (dashboard deploy), kubectl + hcloud (realethia-infra), Expo Go (mobile testing).

## Adding a repository

1. Add an entry to `repos.yaml`
2. Run `make workspace` to refresh the VS Code workspace file
3. Update `AGENTS.md` and `docs/architecture-overview.md` in **realethia-start**
4. Add repo-specific Cursor rules in `realethia-start/.cursor/rules/` only if needed — do not copy org-wide rules into the new repo

## License

Same as other Realethia organization repositories.
