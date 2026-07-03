# Deployment Workflow

This repository relies on Docker Compose and `nginx-proxy` to manage services. 
Each service lives in its own directory on the server (or its own repository) with its own `docker-compose.yml`.

## Global Network

We use an external Docker network named `proxy` to connect applications to the reverse proxy. Each application should also define its own private internal network (often the default for compose) for communication between its own components (like a web app and its database).

## The CSky Permissions Standard

To eliminate bind-mount permission issues and ensure a secure, uniform environment, all CSky services must follow this official standard:

1. **Never run as root:** Application containers must not run as the root user.
2. **Dynamic User Mapping:** Do not hardcode UIDs/GIDs in Dockerfiles. Instead, use the native Docker Compose `user:` directive to pass the host user's UID and GID dynamically.
3. **Environment Variables:** Use `PUID` and `PGID` variables in your `.env` file to map the host deployment user to the container.

By mapping the container's executing user directly to the host's `deploy` user, the container natively owns the files it creates in the bind-mounted directories. No `chmod 777`, no entrypoint chown scripts, and no manual post-deployment fix-ups are required.

## Deploying a New Service

1. Clone your application's Git repository into the services directory (e.g., `/srv/services/my-app`):
```bash
git clone <your-repo-url> /srv/services/my-app
```
2. Ensure the `docker-compose.yml` inside that repository is configured to be picked up by the proxy:

```yaml
version: '3.8'
services:
  app:
    image: my-app:latest
    user: "${PUID:-1000}:${PGID:-1000}"
    networks:
      - proxy
      - default # internal
    environment:
      - VIRTUAL_HOST=app.mydomain.com
      - LETSENCRYPT_HOST=app.mydomain.com
      # - VIRTUAL_PORT=3000 # Uncomment if your app doesn't listen on port 80

networks:
  proxy:
    external: true
```

4. Start or update the service:
```bash
cd /srv/services/my-app
git pull  # if updating an existing deployment
docker compose up -d
```

The `nginx-proxy` will automatically detect the new container, generate a Let's Encrypt certificate for `app.mydomain.com` (assuming DNS is configured), and start routing traffic to it.

## Updating the Infrastructure

To update the reverse proxy or infrastructure scripts, pull the latest changes in the infrastructure repository:

```bash
cd /srv/infra
git pull
cd proxy
docker compose up -d
```
