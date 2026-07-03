# Nginx Proxy & ACME Companion

This directory contains the core routing and SSL termination layer for the server.

It uses [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) and [acme-companion](https://github.com/nginx-proxy/acme-companion) to automatically route traffic to Docker containers and provision Let's Encrypt SSL certificates.

## Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
2. Update `.env` with your email address for Let's Encrypt expiry notifications.
3. Start the proxy network:
   ```bash
   docker compose up -d
   ```

## Adding a Service

To route traffic to a new Docker container, add the following environment variables to its `docker-compose.yml`:

```yaml
environment:
  - VIRTUAL_HOST=sub.yourdomain.com
  - LETSENCRYPT_HOST=sub.yourdomain.com
```

Ensure the service container exposes the port it listens on, or specify it explicitly if not port 80:
```yaml
environment:
  - VIRTUAL_PORT=8080
```
