# Filesystem Permissions (PUID/PGID)

## Why does this exist?
To explain the mechanism we use to prevent Docker bind-mount permission errors without compromising security.

## When should it be used?
Refer to this when configuring a new container or troubleshooting `Permission Denied` errors in logs.

## How does it work?
By default, Docker containers run as `root`. If a root container creates a file in a bind-mounted directory (e.g., `infra/data/`), that file is owned by `root` on the VPS host, meaning the `deploy` user cannot modify or back it up easily.

If we map the `user:` in compose to the `deploy` user's UID and GID (PUID/PGID), the container's process runs securely as that unprivileged user.

### Fail-Fast Implementation
We mandate `user: "${PUID}:${PGID}"`. We do **not** provide fallbacks (`${PUID:-1000}`). If the variables are missing, deployment fails instantly.

## Step-by-Step Instructions

1. Identify the `deploy` user's UID and GID on the VPS:
   ```bash
   id -u deploy # e.g. 1000
   id -g deploy # e.g. 1000
   ```
2. Create `.env` in the `infra/` directory:
   ```env
   PUID=1000
   PGID=1000
   ```
3. Use it in `infra/docker-compose.yml`:
   ```yaml
   services:
     app:
       image: my-app:latest
       user: "${PUID}:${PGID}"
       volumes:
         - ./data:/app/data
   ```

## Why we don't use Root or chmod 777
- **Root**: Massive security risk. A container escape yields root host access.
- **chmod 777**: Terrible security practice. Anyone can read, write, or execute files, violating the principle of least privilege.

## Common Mistakes
- Using `chmod 777 ./data` to "fix" permissions. Never do this.
- Hardcoding `user: 1000:1000` in the compose file. Use the variables.

## Troubleshooting
- **Error: missing mandatory variable**: Ensure the `.env` file exists in the directory where you run `docker compose up`.

## Related Documentation
- [Service Standard](SERVICE_STANDARD.md)
