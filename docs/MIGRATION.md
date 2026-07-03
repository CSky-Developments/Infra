# Permission Standard Migration Plan

This document outlines the migration plan for updating existing CSky services to the official PUID/PGID deployment standard without breaking existing persistent data.

## Goal
Transition all existing services to use the `user: "${PUID:-1000}:${PGID:-1000}"` directive in Docker Compose, ensuring containers no longer run as root or use hardcoded UIDs, and permanently fixing bind-mount permissions.

## Why this is better than hardcoded UIDs or root
- **Security**: Containers no longer run as root, drastically reducing the impact of container escapes.
- **Simplicity**: Avoids complex entrypoint scripts (like `s6-overlay`) that perform recursive `chown` on every startup, which slows down boot times. It also avoids insecure `chmod 777` band-aids.
- **Maintainability**: The host and container share exact permission parity seamlessly. Backups, restores, and host-level operations on the data can be performed by the standard `deploy` user on the VPS without requiring `sudo`. It keeps the Dockerfile clean and portable across different environments.

## Migration Steps per Service

1. **Identify Existing Ownership**
   First, identify who currently owns the existing persistent data on the host. 
   ```bash
   ls -la /srv/services/<app-name>/data
   ```
   If it's owned by `root` (because the container ran as root), we must fix it on the host before migrating.

2. **Stop the Service**
   ```bash
   cd /srv/services/<app-name>
   docker compose down
   ```

3. **Update the Configuration**
   Update the service's `docker-compose.yml` to include the standard user directive on any container that mounts host volumes:
   ```yaml
   services:
     app:
       # ... other config ...
       user: "${PUID:-1000}:${PGID:-1000}"
   ```
   Add a `.env` file if it doesn't exist, setting `PUID` and `PGID` to match the `deploy` user (usually 1000:1000). You can verify the host user's ID by running `id -u` and `id -g`.

4. **Correct Host Permissions**
   Recursively chown the application's bind-mounted directories to the `deploy` user so the newly unprivileged container can write to them.
   ```bash
   sudo chown -R deploy:deploy /srv/services/<app-name>/data
   ```

5. **Restart the Service**
   ```bash
   docker compose up -d
   ```

6. **Verify**
   Check the container logs to ensure the application starts correctly without permission denied errors, and verify new files are created as the `deploy` user on the host.
