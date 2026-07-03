# Daily Operations

## Why does this exist?
To provide a quick-reference cheat sheet for standard operational commands on the CSky platform.

## When should it be used?
During routine maintenance, health checks, or minor troubleshooting.

## Command Reference

### Docker Status & Monitoring
- `docker ps`: List running containers.
- `docker system df`: Check Docker disk usage.
- `docker stats`: Live CPU/Memory usage per container.

### Docker Compose Operations (Run inside `infra/`)
- `docker compose logs -f`: Tail logs for the entire stack.
- `docker compose up -d`: Apply changes / start stack.
- `docker compose down`: Stop and remove stack containers.
- `docker compose pull`: Pull updated images.

### Cleanup & Pruning
- `docker image prune -a`: Remove unused images (saves disk space).
- `docker volume ls`: List volumes.
- `docker system prune -a --volumes`: **DANGER**. Removes all stopped containers, unused images, and unused volumes.

### Git Operations
- `git pull`: Update repository state.

## Common Mistakes
- Running `docker system prune` when a critical service is temporarily down, deleting its data volumes if they aren't explicitly bound. We mitigate this by using bind mounts to `./data`.

## Troubleshooting
- If a command hangs, check host memory using `htop` or `free -h`.

## Related Documentation
- [Troubleshooting](TROUBLESHOOTING.md)
