# Test Environments & Ephemeral Servers

## Why does this exist?
To explain how to deploy temporary test environments—such as a Minecraft server for testing plugins, a paired Discord bot, or a staging website—while strictly adhering to the CSky Infrastructure standard.

## When should it be used?
When a developer needs to spin up a test instance without breaking the platform's security, routing, or permission rules.

## Strict Naming Convention
**Mandatory Rule**: Any ephemeral test repository or service deployed to the infrastructure MUST be suffixed with `-test`. For example: `csky-mc-test`, `discord-bot-test`, or `backend-api-test`. This ensures test environments are never confused with production services.

## Scenario: Minecraft, Discord, and Scripts

Test environments are not limited to websites and Discord bots; they can include Python scripts, background workers, databases, or anything else you need to containerize. Suppose you need to test a Minecraft plugin that communicates with a website, a Discord bot, and a custom background script. 

### 1. Repository Setup
Even for a temporary test server, you must follow the [Service Standard](SERVICE_STANDARD.md). Create a directory for it on the VPS:
```text
/srv/services/csky-mc-test/
├── infra/
│   ├── docker-compose.yml
│   ├── .env
│   └── data/
```

### 2. Configuration (`docker-compose.yml`)
Minecraft requires direct TCP/UDP ports rather than HTTP routing, while the paired website uses our reverse proxy. A Discord bot simply needs outbound internet access.

```yaml
version: '3.8'

services:
  # 1. The Minecraft Test Server
  mc-server:
    image: itzg/minecraft-server
    # The itzg image uses UID/GID env vars rather than the compose 'user' directive natively, 
    # but we still pass our host-derived IDs to keep file ownership consistent.
    environment:
      - UID=${PUID}
      - GID=${PGID}
      - EULA=TRUE
      - VERSION=1.20.4
      - TYPE=PAPER
    ports:
      - "25565:25565" # Minecraft needs a direct host port; it doesn't use the HTTP proxy
    volumes:
      - ./data/minecraft:/data
    networks:
      - default

  # 2. The Discord Bot (if applicable)
  discord-bot:
    image: my-discord-bot:latest
    user: "${PUID}:${PGID}"
    environment:
      - DISCORD_TOKEN=${DISCORD_TOKEN}
    volumes:
      - ./data/bot:/app/data
    networks:
      - default

  # 3. A Staging Website for the Server
  website:
    image: my-mc-website:latest
    user: "${PUID}:${PGID}"
    environment:
      - VIRTUAL_HOST=test-mc.csky.com
      - LETSENCRYPT_HOST=test-mc.csky.com
    networks:
      - proxy
      - default

  # 4. A Custom Standalone Script
  test-script:
    image: python:3.11-slim
    user: "${PUID}:${PGID}"
    volumes:
      - ./data/scripts:/app
    working_dir: /app
    command: ["python", "test_runner.py"]
    networks:
      - default

networks:
  proxy:
    external: true
```

### 3. The `.env` File
Always supply the [Deployment User Standard](PERMISSIONS.md) variables so files remain manageable by the `csky` user.
```env
PUID=<uid-of-csky>
PGID=<gid-of-csky>
DISCORD_TOKEN=your_bot_token_here
```

### 4. Deployment
Run the standard deployment flow:
```bash
cd /srv/services/csky-mc-test/infra
docker compose up -d
```

## How this adheres to the CSky Constitution
- **Filesystem**: The MC server, bot, script, and website all generate files as the `csky` user. All plugins, worlds, and bot databases generated in `./data/` are safely owned by `csky:csky`.
- **Isolation**: The MC server and Discord bot do not touch the `proxy` network since they don't serve HTTP traffic. Only the website connects to the proxy.
- **Cleanup**: When testing is complete, simply run `docker compose down` and delete the `/srv/services/csky-mc-test` directory. No lingering root-owned files will block deletion.

## Common Mistakes
- **Proxying Minecraft**: Do not put `VIRTUAL_HOST` on the Minecraft container. The `nginx-proxy` layer only handles HTTP/HTTPS traffic, not raw TCP/UDP Minecraft traffic.
- **Ignoring PUID/PGID on third-party images**: Some popular images (like `itzg/minecraft-server` or LinuxServer.io images) manage users internally via `UID`/`GID` or `PUID`/`PGID` environment variables instead of the compose `user:` directive. Always read the image documentation, but strictly pass your host-derived variables into them.

## Related Documentation
- [Service Standard](SERVICE_STANDARD.md)
- [Deployment Workflow](DEPLOYMENT.md)
