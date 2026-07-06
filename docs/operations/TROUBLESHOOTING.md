# Troubleshooting Guide

## Why does this exist?
To preserve institutional knowledge of every failure mode we encountered while building v1, saving future engineers hours of debugging.

## Known Issues

### 1. Permission Denied (PUID/PGID)
- **Symptoms**: Container crashes immediately or logs show `EACCES: permission denied, mkdir '/app/data'`.
- **Root Cause**: The container user does not own the host directory.
- **Diagnosis**: Run `ls -la ./data` on the host. Compare ownership against `id -u`.
- **Resolution**: Ensure `.env` contains `PUID=<uid-of-csky>` and `PGID=<gid-of-csky>`. Run `sudo chown -R csky:csky ./data`.
- **Prevention**: Use our fail-fast standard (`user: "${PUID}:${PGID}"`) without defaults.

### 2. Missing .env Variables
- **Symptoms**: `docker compose up -d` throws `ERROR: Missing mandatory value for "env" option`.
- **Root Cause**: Fail-fast variables are empty.
- **Diagnosis**: Missing `.env` file or typos.
- **Resolution**: Create or populate `.env` in the `infra/` folder.
- **Prevention**: Always copy `.env.example` to `.env` upon deployment.

### 3. Proxy Not Routing (502/503)
- **Symptoms**: Visiting the domain returns 502 Bad Gateway.
- **Root Cause**: The container is crashing, not on the `proxy` network, or exposing the wrong port.
- **Diagnosis**: `docker ps` to see if it's running. `docker inspect <container>` to check networks.
- **Resolution**: Add `VIRTUAL_PORT=<port>` to the compose file if the app doesn't listen on 80.
- **Prevention**: Test apps locally on port 80 if possible.

### 4. Container Restart Loops
- **Symptoms**: `docker ps` shows `Restarting (1) 4 seconds ago`.
- **Root Cause**: Application crash on boot (often DB connection failed).
- **Diagnosis**: `docker compose logs -f`.
- **Resolution**: Fix the underlying app error or environment variables.
- **Prevention**: Implement healthchecks in compose.

### 5. GHCR Image Pull Failures
- **Symptoms**: `docker compose pull` says `unauthorized: authentication required`.
- **Root Cause**: The VPS is not logged into GHCR, or the PAT expired.
- **Diagnosis**: Try pulling manually `docker pull ghcr.io/...`.
- **Resolution**: `docker login ghcr.io -u <github-user> -p <PAT>`.
- **Prevention**: Use deploy tokens that don't expire quickly.

### 6. GitHub SSH Authentication Fails
- **Symptoms**: `git pull` prompts for a password.
- **Root Cause**: SSH key not added to GitHub or wrong key used.
- **Diagnosis**: `ssh -T git@github.com`.
- **Resolution**: Add `/home/csky/.ssh/id_ed25519.pub` to GitHub.

### 7. Prisma/OpenSSL Incompatibility
- **Symptoms**: Node app crashes with `Error loading shared library libssl.so.3` on Alpine.
- **Root Cause**: Alpine does not include OpenSSL by default, which Prisma requires.
- **Resolution**: Add `apk add --no-cache openssl` to the Dockerfile and configure `binaryTargets = ["native", "linux-musl-openssl-3.0.x"]` in `schema.prisma`.

### 8. HTTPS Certificate Generation Fails
- **Symptoms**: SSL certificate invalid or browser warns of insecure connection.
- **Root Cause**: Let's Encrypt could not verify domain ownership.
- **Resolution**: Ensure DNS A records point to the VPS IP. Verify `LETSENCRYPT_HOST` and `LETSENCRYPT_EMAIL` exist in the compose file. Check logs: `docker logs nginx-proxy-acme`.

### 9. Orphan Containers
- **Symptoms**: Warning `Found orphan containers` during `docker compose up`.
- **Root Cause**: A service was removed from the compose file, but the container is still running.
- **Resolution**: Run `docker compose up -d --remove-orphans`.

## Related Documentation
- [Disaster Recovery](DISASTER_RECOVERY.md)
