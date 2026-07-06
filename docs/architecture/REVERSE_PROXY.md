# Reverse Proxy Layer

## Why does this exist?
To securely route HTTP/HTTPS traffic from the internet to internal Docker containers without manual configuration per app.

## When should it be used?
The proxy runs continuously in `/srv/infra/proxy`. Refer to this document when troubleshooting routing or SSL issues.

## How does it work?
We use `nginx-proxy` and `acme-companion`. They monitor the Docker daemon for container start/stop events. When a container starts with `VIRTUAL_HOST`, the proxy dynamically reloads Nginx configuration. `acme-companion` intercepts Let's Encrypt ACME challenges to issue free SSL certificates.

## Step-by-Step Instructions

### Adding a New Service
Every public HTTP service must define these variables and join the shared proxy network. In your service's `infra/docker-compose.yml`:
```yaml
environment:
  - VIRTUAL_HOST=app.csky.com
  - VIRTUAL_PORT=8080
  - LETSENCRYPT_HOST=app.csky.com
  - LETSENCRYPT_EMAIL=admin@csky.com
networks:
  - proxy
```

## Verifying Successful Routing
To verify the proxy is correctly routing traffic to your container, execute:
```bash
curl -I https://app.csky.com
```
You should receive an HTTP 200 OK or 3xx redirect. If you receive a 502 Bad Gateway, the proxy sees the container but the container is not responding on the specified `VIRTUAL_PORT`.

## Common Mistakes
- Forgetting to attach the `proxy` network to the container.
- Missing `VIRTUAL_PORT` when the application does not listen on the default port 80.
- DNS not pointing to the VPS before the container starts, causing Let's Encrypt to fail the challenge.

## Troubleshooting
- **502 Bad Gateway**: The container is crashing, or exposing the wrong port. Specify `VIRTUAL_PORT` if it doesn't listen on 80.
- **SSL Not Issuing**: Check `docker logs nginx-proxy-acme`. Usually a DNS mismatch.

## Related Documentation
- [Architecture](ARCHITECTURE.md)
