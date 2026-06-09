# Local development guide

## First-time setup

```bash
git clone https://github.com/realethia/realethia-start.git
cd realethia-start
make setup
```

Edit `../ethia/infra/.env` and set at minimum:

- `POSTGRES_PASSWORD`
- Azure storage variables (if testing blob outputs)
- `OPENAI_API_KEY` (optional; for AI-generated RSS test articles)

## Ethia

From `ethia/`:

| Command | Description |
|---------|-------------|
| `make build-start` | Build binaries, images, start Compose stack |
| `make start` | Start stack only |
| `make stop` | Stop stack |
| `make debezium-register` | Register CDC connector (after first healthy start) |
| `make db-sample` | Load sample data |
| `make check` | Lint + tests |
| `make clean` | Stop and remove containers/volumes |

URLs:

- Redpanda Console: http://localhost:8080
- PostgreSQL: `localhost:5432` (user/db from `.env`)
- RSS test server: `make start-test-rss-server` → http://localhost:8081

## Dashboard

From `realethia-dashboard/`:

```bash
npm ci
npm run codegen:types
```

Two terminals:

```bash
npm run mock   # Prism — http://localhost:3001
npm run dev    # Next.js — http://localhost:4000
```

Quality gate before PRs:

```bash
npm run check
```

API tools live under `api-spec/tools/`.

## Mobile app

From `realethia-app/`:

```bash
npm ci
npx expo start
```

Use Expo Go or simulators per Expo docs.

## Infra (optional)

Only needed for cloud cluster work. See `realethia-infra/README.md`:

```bash
make setup          # macOS brew deps
make staging deploy # requires credentials
```

## Troubleshooting

### Docker / Ethia won't start

- Ensure Docker Desktop is running
- Check port conflicts (5432, 8080, 9092)
- `cd ethia && make clean && make build-start`

### Dashboard mock vs real backend

Default local dashboard development uses the **Prism mock** (`npm run mock`), not Ethia. Integrating dashboard against a live Ethia API is a separate wiring task (env/base URL).

### Expo port 8081 vs Ethia RSS test server

Both may use 8081. Run only one at a time, or configure Expo to another port.

### Clone already exists

`make clone` skips existing git repos. To update:

```bash
cd ../ethia && git pull
# repeat per repo
```

Or `SKIP_EXISTING=0 make clone` to fetch and checkout the configured branch.
