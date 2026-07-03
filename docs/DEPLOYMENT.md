# Deployment Workflow

## Why does this exist?
To document the standard operating procedure for deploying, updating, and rolling back CSky services.

## When should it be used?
During any manual deployment phase, or when configuring automated CI/CD.

## How does it work?
We treat the VPS as a collection of Git repositories. Deployments are executed by pulling the latest code and restarting the compose stack.

## Step-by-Step Instructions

### Deploying a New Service
1. SSH into the VPS as `deploy`.
2. `git clone <repo> /srv/services/<app-name>`
3. Set up `.env` inside `/srv/services/<app-name>/infra/` (must include PUID/PGID).
4. `cd /srv/services/<app-name>/infra && docker compose up -d`

### Updating a Service
```bash
cd /srv/services/<app-name>/infra
git pull
docker compose pull
docker compose up -d
```

### Rolling Back
```bash
cd /srv/services/<app-name>/infra
git checkout <previous-commit-hash>
docker compose up -d
```

### Viewing Logs
```bash
cd /srv/services/<app-name>/infra
docker compose logs -f
```

### Updating Docker Engine
```bash
sudo apt update && sudo apt upgrade docker-ce docker-compose-plugin -y
sudo systemctl restart docker
```

## Common Mistakes
- **Running `docker compose up` outside the `infra/` folder.**
- **Forgetting `docker compose pull`**: If you update `latest` in GHCR, you must pull it on the VPS before restarting.

## Troubleshooting
- **Restarting a container**: `docker compose restart <service-name>`
- **Checking health**: `docker ps`

## Related Documentation
- [Operations](OPERATIONS.md)
