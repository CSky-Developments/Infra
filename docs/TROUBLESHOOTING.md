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

## Related Documentation
- [Disaster Recovery](DISASTER_RECOVERY.md)
