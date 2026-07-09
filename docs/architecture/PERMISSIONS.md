# Filesystem Permissions (PUID/PGID)

## Why does this exist?
To explain the mechanism we use to prevent Docker bind-mount permission errors without compromising security.

## When should it be used?
Refer to this when configuring a new container or troubleshooting `Permission Denied` errors in logs.

## Deployment User Standard
- Services run as the host deployment user (`csky`).
- Containers must consume `PUID` and `PGID` supplied by the infrastructure.
- Numeric UIDs must never be assumed.
- UID `1000` must never be hardcoded.
- Files under `/srv` must always be owned by `csky:csky`.
- Bind-mounted files must remain owned by `csky:csky`.
- Containers must never rely on root ownership for persistent data.
- Service repositories must inherit these standards from the Infrastructure Repository instead of redefining them.

## How does it work?
By default, Docker containers run as `root`. If a root container creates a file in a bind-mounted directory (e.g., `infra/data/`), that file is owned by `root` on the VPS host, meaning the `csky` user cannot modify or back it up easily.

If we map the `user:` in compose to the `csky` host deployment user's UID and GID (PUID/PGID), the container's process runs securely as that unprivileged user.

### Why we NEVER assume UID 1000
Modern Ubuntu cloud images automatically create a default `ubuntu` user as UID 1000. As a result, when we create our `csky` deployment user, it is frequently assigned UID 1001. Assuming UID 1000 is incorrect and not portable across VPS providers. The infrastructure must NEVER hardcode numeric UIDs. All persistent data under `/srv` must be owned by `csky:csky`, whatever those numeric IDs happen to be.

### Fail-Fast Implementation
We mandate `user: "${PUID}:${PGID}"`. We do **not** provide fallbacks (`${PUID:-1000}`). If the variables are missing, deployment fails instantly.

## Step-by-Step Instructions

1. Identify the host deployment user's (`csky`) UID and GID on the VPS:
   ```bash
   id csky
   id -u csky # e.g., 1001
   id -g csky # e.g., 1001
   ```
2. Populate `.env` in the `infra/` directory with those exact values:
   ```env
   PUID=1001
   PGID=1001
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

## Permanent Volume Fix (The SGID Bit)
When you deploy a new container without creating the `./data` folder manually, the Docker daemon (running as root) will auto-create the missing bind-mounted directory as `root:root`. This immediately locks the `csky` user out. 

To permanently prevent this across the entire `/srv/services/` directory, we use the Set-Group-ID (SGID) bit. Applying this forces all future files and folders created by Docker to inherit the `csky` group:

```bash
# 1. Take recursive ownership
sudo chown -R csky:csky /srv/services/

# 2. Grant the csky group write permissions
sudo find /srv/services/ -type d -exec chmod 775 {} +
sudo find /srv/services/ -type f -exec chmod 664 {} +

# 3. Apply the SGID bit to all directories
sudo find /srv/services/ -type d -exec chmod g+s {} +
```
Now, if Docker auto-creates a folder, it will be created as `root:csky`. Because the group is `csky` and has write permissions, your deployment user retains full access to the folder.

> [!TIP]
> **Pro-Tip: Pre-Create Volume Folders**
> Even with the SGID bit set, Docker's internal security rules (umask) will sometimes auto-create folders without giving the `csky` group write permissions (creating it as `rwxr-xr-x` instead of `rwxrwxr-x`). 
> To completely avoid permission denied errors when adding brand-new volume mounts, **manually pre-create the folder** on the VPS (e.g., `mkdir -p ../data/new_folder`) *before* you run `docker compose up`. If your `csky` deployment user creates the folder first, it will own it perfectly from the start!

## Why we don't use Root or chmod 777
- **Root**: Massive security risk. A container escape yields root host access.
- **chmod 777**: Terrible security practice. Anyone can read, write, or execute files, violating the principle of least privilege.

## Common Mistakes
- Using `chmod 777 ./data` to "fix" permissions. Never do this.
- Hardcoding `user: 1000:1000` in the compose file. Use the variables mapped to the host deployment user.

## Troubleshooting
- **Error: missing mandatory variable**: Ensure the `.env` file exists in the directory where you run `docker compose up`.
- **EACCES: permission denied**: The host data directory was likely auto-created by Docker as root. Stop the container, `sudo chown -R csky:csky ./data`, and start it again.

## Related Documentation
- [Service Standard](SERVICE_STANDARD.md)
