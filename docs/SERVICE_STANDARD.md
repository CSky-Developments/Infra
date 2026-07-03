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
│   ├── .env
│   └── data/
├── src/
└── Dockerfile
```

### 2. Docker Compose File
Must be located at `infra/docker-compose.yml`.
Must define the `proxy` network and use the PUID/PGID model.

### 3. Permissions
Must enforce `user: "${PUID}:${PGID}"`. Never hardcode numeric UIDs like 1000, as the host deployment user's UID varies across VPS providers. See [PERMISSIONS.md](PERMISSIONS.md).

### 4. CI/CD
Must use GitHub Actions to build and push to GHCR. See [CI_CD.md](CI_CD.md).

### 5. Volumes & Data
All persistent data must be bind-mounted into `./data/` (relative to the compose file in the `infra/` directory).
Temporary files that do not need persistence must be written to `/tmp` inside the container.

### 6. Ports
Services should only expose ports internally to the `proxy` network via `VIRTUAL_PORT`. Do not bind ports to the host (e.g., `8080:80`) unless absolutely necessary for external non-HTTP access.

### 7. Logging
Use the default Docker json-file driver. Ensure applications log to `stdout` and `stderr` so `docker compose logs` functions correctly.

### 8. Naming Conventions
- Repositories: kebab-case (e.g., `user-service`).
- Container names: matching the repository name.

## Common Mistakes
- Placing `docker-compose.yml` at the root of the repository instead of `infra/`.
- Using Docker named volumes instead of bind mounts to `./data`.

## Troubleshooting
- If a service fails to route, verify `VIRTUAL_HOST` in the compose file and ensure the `proxy` network is attached.

## Related Documentation
- [Architecture](ARCHITECTURE.md)
- [Permissions](PERMISSIONS.md)
