# Realethia Start

## Quick start

**One command** from the folder that should contain all repos:

```bash
curl -fsSL https://raw.githubusercontent.com/realethia/realethia-start/main/scripts/install.sh | bash
```

Manual steps:

```bash
git clone https://github.com/realethia/realethia-start.git
cd realethia-start
make setup
make workspace-open
```

## Repositories

| Repo | Description |
|------|-------------|
| [ethia](https://github.com/realethia/ethia) | Reality consumption system |
| [realethia-dashboard](https://github.com/realethia/realethia-dashboard) | Realethia Dashboard |
| [realethia-app](https://github.com/realethia/realethia-app) | Realethia App |
| [realethia-infra](https://github.com/realethia/realethia-infra) | Realethia Infrastructure |
| [realethia-research-docs](https://github.com/realethia/realethia-research-docs) | Realethia Research Docs and Samples |

Canonical list: [`repos.yaml`](repos.yaml).

## Common commands

```bash
make install       # Setup workspace and open Cursor (from realethia-start)
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

## Adding a repository

1. Add an entry to `repos.yaml`
2. Run `make workspace` to refresh the VS Code workspace file
3. Update `AGENTS.md` and `docs/architecture-overview.md` in **realethia-start**
4. Add repo-specific Cursor rules in `realethia-start/.cursor/rules/` only if needed — do not copy org-wide rules into the new repo
