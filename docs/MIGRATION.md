# Migration Guide

## Why does this exist?
To explain how older CSky services must migrate to the new platform standard without causing downtime or data loss.

## When should it be used?
Whenever an old service is being refactored to fit the new CSky Infrastructure v1 platform.

## How does it work?
We stop the legacy service, refactor its directory layout to match the `infra/` standard, inject PUID/PGID into its compose file, correct host data ownership, and restart it.

## Step-by-Step Instructions

1. **Identify Existing Ownership**
   Check who owns the current persistent data.
   ```bash
   ls -la /srv/services/<app-name>/data
   ```
2. **Stop Legacy Service**
   ```bash
   cd /srv/services/<app-name>
   docker compose down
   ```
3. **Refactor Directory Structure**
   Move the `docker-compose.yml`, `.env`, and `data` into a new `infra/` folder.
   ```bash
   mkdir infra
   mv docker-compose.yml .env data infra/
   ```
4. **Update Configuration**
   Edit `infra/docker-compose.yml` to include the standard user directive:
   ```yaml
   services:
     app:
       user: "${PUID}:${PGID}"
   ```
5. **Correct Host Permissions**
   Recursively `chown` the data directory to the `deploy` user.
   ```bash
   sudo chown -R deploy:deploy infra/data
   ```
6. **Restart Service**
   ```bash
   cd infra
   docker compose up -d
   ```

## Common Mistakes
- **Forgetting to stop the service first**: Trying to move directories while the database is actively writing to them will corrupt data.

## Troubleshooting
- If the app crashes with "Permission Denied" after migration, verify that `.env` inside `infra/` actually contains the correct `PUID/PGID` values.

## Related Documentation
- [Permissions](PERMISSIONS.md)
- [Service Standard](SERVICE_STANDARD.md)
