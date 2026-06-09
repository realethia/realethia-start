# Architecture overview (cross-repo)

High-level map of the Realethia system. For Ethia internals, see [ethia/docs/architecture.md](https://github.com/realethia/ethia/blob/main/docs/architecture.md).

## Data plane (Ethia)

```
PostgreSQL (flows) ──CDC──▶ Orchestrator ──▶ Redis (feed registry)
                                │
Poller ──fetch──▶ dedup ──▶ Kafka (Redpanda) ──▶ Connect pools ──▶ outputs
```

| Component | Responsibility |
|-----------|----------------|
| PostgreSQL | Flow definitions, configuration |
| Debezium | CDC from `flows` table to Kafka |
| Orchestrator | Bootstrap Redis, react to flow changes, manage Connect deployments |
| Poller | Poll RSS/HTTP feeds, publish to `source` topic |
| Redis | Feed runtime config, dedup (Bloom), distributed locks |
| Redpanda | Event bus (source, transform, output, DLQ topics) |
| Connect | Shared transformer/output pipeline pools |

## Control plane & clients

| Repo | Layer |
|------|-------|
| realethia-dashboard | Operator UI, OpenAPI-defined backend contract (mock locally) |
| realethia-app | End-user mobile experience |
| realethia-infra | Runs Ethia and supporting services on Kubernetes (Hetzner) |

## Deployment topology

- **Local**: Docker Compose in `ethia/infra/`
- **Staging/Prod**: `realethia-infra/envs/*` — k3s on Hetzner, Redpanda StatefulSet, app manifests

## Research

`realethia-research-docs` holds exploratory topics (e.g. Usenet sources). Not authoritative for implementation.

## Related documentation

| Topic | Location |
|-------|----------|
| Ethia deep dive | `ethia/docs/architecture.md` |
| Dashboard tech spec | `realethia-dashboard/docs/tech-spec.md` |
| API spec | `realethia-dashboard/api-spec/openapi.yaml` |
| Infra quick start | `realethia-infra/README.md` |
| Agent instructions | `realethia-start/AGENTS.md` |
