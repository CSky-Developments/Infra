# Disaster Recovery

## Why does this exist?
To outline the exact steps required to resurrect the CSky platform if the primary VPS is completely destroyed.

## When should it be used?
In the event of catastrophic server failure, data corruption, or compromised host OS.

## How does it work?
By treating our infrastructure as code and persistent data as simple flat files, we can rebuild the server in minutes rather than days.

## Server Rebuild Strategy

1. **Provision New VPS**: Follow [VPS_SETUP.md](VPS_SETUP.md).
2. **Restore Repositories**: Re-clone `/srv/infra` and all services in `/srv/services/`.
3. **Restore Data**: Copy the `infra/data/` directories from your offsite backup directly into the newly cloned service repositories.
4. **Restore Certificates**: The `proxy` will automatically reissue Let's Encrypt certificates once DNS is updated. You do not need to backup certificates unless avoiding rate limits.
5. **Restore CI/CD**: Update GitHub Secrets (`VPS_HOST`, `VPS_SSH_KEY`) to point to the new server's IP and keys.
6. **Update DNS**: Point domains to the new VPS IP.
7. **Start Stacks**: Run `docker compose up -d` in `/srv/infra/proxy` and each service's `infra/` folder.

## Backup Strategy
- **What to backup**: The `/srv/services/*/infra/data/` directories and `.env` files.
- **What NOT to backup**: The raw codebase (it's on GitHub) or Docker images (they're in GHCR).

## Common Mistakes
- Backing up `node_modules` or Docker overlay filesystems. Only backup the explicit `./data` bind mounts.

## Troubleshooting
- **DNS Propagation**: Let's Encrypt will fail if DNS hasn't propagated to the new IP. Wait 15 minutes and restart the `acme-companion` container.

## Related Documentation
- [VPS Setup](VPS_SETUP.md)
