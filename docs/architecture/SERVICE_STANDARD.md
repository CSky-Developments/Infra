# Service Standard

## Why does this exist?
To define the mandatory "constitution" that every CSky service must follow. Conformity ensures that any engineer can maintain any service instantly.

## When should it be used?
When creating a new service or migrating an old service to the platform.

## How does it work?
By enforcing strict rules on directory layouts, configuration, and logging, we eliminate mental overhead and edge cases.

## The Standard

### 1. Directory Layout
Every service repository must follow this structure exactly:
```text
/
├── infra/
│   ├── docker-compose.yml
│   └── .env
├── data/
├── keys/
├── backups/
├── src/
└── Dockerfile

Application repositories should not invent their own layouts. Every service must conform to this self-contained structure.
```

### 2. Configuration Files (`docker-compose.yml` & `.env`)
- The compose file must be located at `infra/docker-compose.yml` and define the `proxy` network.
- An accompanying `infra/.env` (or `.env.example`) file MUST always be generated containing `PUID=` and `PGID=` placeholders so the deployment doesn't instantly fail.
- **Project Name**: Must define `name: <service-name>` at the top to prevent namespace collisions.
- **Networks**: Must attach to the shared `proxy` network for external traffic.
- **User Mapping**: Must enforce `user: "${PUID}:${PGID}"` (see [PERMISSIONS.md](PERMISSIONS.md)).
- **Environment**: Must consume configuration via an `env_file`.
- **Restart Policy**: Must be set to `unless-stopped` or `always`.
- **Logging**: Must limit the json-file driver (e.g. max-size 10m).
- **Resources**: Must define reasonable memory/cpu limits.
- **Orphan Containers**: Always deploy with `docker compose up -d --remove-orphans`.

### 3. Deployment User Standard
- Services run as the host deployment user (`csky`).
- Containers must consume `PUID` and `PGID` supplied by the infrastructure.
- Numeric UIDs must never be assumed.
- UID `1000` must never be hardcoded.
- Files under `/srv` must always be owned by `csky:csky`.
- Service repositories must inherit these standards from the Infrastructure Repository instead of redefining them.

See [PERMISSIONS.md](PERMISSIONS.md) for implementation details.

### 4. CI/CD
Must use GitHub Actions to build and push to GHCR. See [CI_CD.md](CI_CD.md).

### 5. Volumes & Persistent Data
All persistent service data must reside under `/srv/services/<service>/`.
Standardize local mounts relative to the compose file:
- `../data:/app/data` (mapped to `/srv/services/<service>/data`)
- `../keys:/app/keys` (mapped to `/srv/services/<service>/keys`)
- `../backups:/app/backups` (mapped to `/srv/services/<service>/backups`)

- All stateful data (databases, uploads, logs) **must** be mapped to host folders in the `../data/<service>` directory structure to ensure persistence across container restarts.
- **Logging**: All services must follow the [Logging Standard](LOGGING_STANDARD.md), mapping `../data/logs:/app/logs` and rotating files on restart.

All host data directories must be owned by `csky:csky`. Temporary files that do not need persistence must be written to `/tmp` inside the container.

### 6. Ports
Services should only expose ports internally to the `proxy` network via `VIRTUAL_PORT`. Do not bind ports to the host (e.g., `8080:80`) unless absolutely necessary for external non-HTTP access.

### 7. Logging
Use the default Docker json-file driver. Ensure applications log to `stdout` and `stderr` so `docker compose logs` functions correctly.

### 8. Naming Conventions
- Repositories: kebab-case (e.g., `user-service`).
- Container names: matching the repository name.
- **Test Environments**: Any ephemeral or testing service MUST be suffixed with `-test` (e.g., `csky-mc-test`).

### 9. Health Endpoints
Every backend service must expose a standard health endpoint.
- **Route**: `GET /health`
- **Response**: HTTP 200 OK with JSON `{"status": "ok"}`
This is mandatory for use in the [Deployment Verification Checklist](DEPLOYMENT_VERIFICATION.md).

### 10. Node + Prisma + Alpine Standard
When deploying Node.js services using Prisma on Alpine Linux, you must satisfy these compatibility requirements discovered in production:
- **OS Dependency**: Install `openssl` inside the Alpine Docker image (`apk add --no-cache openssl`).
- **Prisma Configuration**: Define `binaryTargets = ["native", "linux-musl-openssl-3.0.x"]` in your `schema.prisma`.
- **Docker Build**: Ensure Prisma client generation runs during the docker build stage after installing OpenSSL.

## Common Mistakes
- Placing `docker-compose.yml` at the root of the repository instead of `infra/`.
- Using Docker named volumes instead of bind mounts to `./data`.

## Troubleshooting
- If a service fails to route, verify `VIRTUAL_HOST` in the compose file and ensure the `proxy` network is attached.

## Related Documentation
- [Architecture](ARCHITECTURE.md)
- [Permissions](PERMISSIONS.md)
