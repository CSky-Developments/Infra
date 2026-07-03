# Deployment Workflow

This repository relies on Docker Compose and `nginx-proxy` to manage services. 
Each service lives in its own directory on the server (or its own repository) with its own `docker-compose.yml`.

## Global Network

By default, `nginx-proxy` uses the standard bridge network. To make your services accessible to the proxy, they just need to be on the same Docker network as the proxy, or you can map the ports. However, `nginx-proxy` monitors the Docker socket, so it can route to any container exposing a port.

## Deploying a New Service

1. Create a directory for your service (e.g., `/srv/services/my-app`).
2. Create a `docker-compose.yml` in that directory.
3. Configure it to be picked up by the proxy:

```yaml
version: '3.8'
services:
  app:
    image: my-app:latest
    environment:
      - VIRTUAL_HOST=app.mydomain.com
      - LETSENCRYPT_HOST=app.mydomain.com
      # - VIRTUAL_PORT=3000 # Uncomment if your app doesn't listen on port 80
```

4. Start the service:
```bash
cd /srv/services/my-app
docker compose up -d
```

The `nginx-proxy` will automatically detect the new container, generate a Let's Encrypt certificate for `app.mydomain.com` (assuming DNS is configured), and start routing traffic to it.
