# Reverse Proxy Layer

## Why does this exist?
To securely route HTTP/HTTPS traffic from the internet to internal Docker containers without manual configuration per app.

## When should it be used?
The proxy runs continuously in `/srv/infra/proxy`. Refer to this document when troubleshooting routing or SSL issues.

## How does it work?
We use `nginx-proxy` and `acme-companion`. They monitor the Docker daemon for container start/stop events. When a container starts with `VIRTUAL_HOST`, the proxy dynamically reloads Nginx configuration. `acme-companion` intercepts Let's Encrypt ACME challenges to issue free SSL certificates.

## Step-by-Step Instructions

### Adding a New Service
In your service's `infra/docker-compose.yml`:
```yaml
environment:
  - VIRTUAL_HOST=app.csky.com
  - LETSENCRYPT_HOST=app.csky.com
networks:
  - proxy
```

## Common Mistakes
- Forgetting to attach the `proxy` network to the container.
- DNS not pointing to the VPS before the container starts, causing Let's Encrypt to fail the challenge.

## Troubleshooting
- **502 Bad Gateway**: The container is crashing, or exposing the wrong port. Specify `VIRTUAL_PORT` if it doesn't listen on 80.
- **SSL Not Issuing**: Check `docker logs nginx-proxy-acme`. Usually a DNS mismatch.

## Related Documentation
- [Architecture](ARCHITECTURE.md)
