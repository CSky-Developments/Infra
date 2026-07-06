# Migration Guide

## Why does this exist?
To explain how older CSky services must migrate to the new platform standard, and to define the official production database migration workflow without causing downtime or data loss.

## When should it be used?
Whenever an old service is being refactored, or when applying Prisma database schema changes in production.

## Legacy Service Migrations
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
   Recursively `chown` the data directory to the `csky` deployment user.
   ```bash
   sudo chown -R csky:csky infra/data
   ```
6. **Restart Service**
   ```bash
   cd infra
   docker compose up -d
   ```

## Database Migrations
The official production migration workflow strictly separates development from production. Production servers must **never** generate migrations.

### Workflow:
1. **Developer**: Modifies `schema.prisma` and runs `prisma migrate dev` locally.
2. **Commit**: The generated SQL migrations are committed to the repository.
3. **Push**: Code is pushed to GitHub.
4. **Deploy**: GitHub Actions pulls the image to the VPS.
5. **Apply**: The production container runs `prisma migrate deploy` upon startup (or via a CI command) to strictly apply the pre-compiled migrations.

## Common Mistakes
- **Forgetting to stop the service first**: Trying to move directories while the database is actively writing to them will corrupt data.
- **Running `prisma migrate dev` in production**: This can wipe or corrupt production databases. Always use `prisma migrate deploy`.

## Troubleshooting
- If the app crashes with "Permission Denied" after migration, verify that `.env` inside `infra/` actually contains the correct `PUID/PGID` values.

## Related Documentation
- [Permissions](PERMISSIONS.md)
- [Service Standard](SERVICE_STANDARD.md)
