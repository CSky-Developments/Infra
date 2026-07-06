# Deployment Verification Checklist

## Why does this exist?
To diagnose deployment issues in minutes instead of hours. Every engineer must perform this checklist immediately after deploying or updating a service.

## 1. Container Status
Verify the container is running and not restarting.
```bash
docker compose ps
# Expected: State should be "Up". If "Restarting", the application is crashing.
```

## 2. Container Health
Check the container's internal logs for startup errors.
```bash
docker compose logs --tail=50
# Expected: Successful boot messages, no unhandled exceptions or panic logs.
```

If the container offers a health endpoint, verify it responds correctly:
```bash
curl -s http://localhost:<port>/health
# Expected: HTTP 200 OK with JSON `{"status": "ok"}`
```

## 3. Reverse Proxy Routing
Verify that `nginx-proxy` has detected the container and updated its configuration.
```bash
docker exec nginx-proxy nginx -T | grep "your-service-domain"
# Expected: Nginx configuration blocks for your VIRTUAL_HOST domain.
```

## 4. HTTPS and Let's Encrypt
Verify that `acme-companion` successfully provisioned the SSL certificate.
```bash
docker logs acme-companion --tail=50
# Expected: "Creating/renewal your-service-domain.com certificates... Certificate successfully issued."

curl -I https://your-service-domain.com
# Expected: HTTP 200 OK or 3xx Redirect (not 502/503/526), and a valid SSL certificate.
```

## 5. Docker Networks
Verify the container is attached to the `proxy` network.
```bash
docker inspect <container-name> --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'
# Expected: Should output "proxy" and the default internal network.
```

## 6. Mounted Volumes
Verify that persistent data directories exist and have the correct ownership.
```bash
ls -la /srv/services/<service-name>/data
# Expected: Directory is owned by `csky:csky`, not `root`.
```

## 7. Environment Variables
Check that critical environment variables like `PUID` and `PGID` were correctly parsed by Compose.
```bash
docker inspect <container-name> --format '{{.Config.User}}'
# Expected: "1001:1001" (or your specific host UID:GID, NEVER root/empty).
```

## 8. Restart Policy
Ensure the container will survive a reboot.
```bash
docker inspect <container-name> --format '{{.HostConfig.RestartPolicy.Name}}'
# Expected: "unless-stopped" or "always".
```
