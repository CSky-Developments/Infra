# Architecture & Platform History

## Why does this exist?
To document the fundamental design philosophy of the CSky platform and preserve the history of major architectural decisions.

## When should it be used?
When proposing systemic changes, onboarding engineers, or resolving disputes about "the right way" to build a service.

## Platform History & Major Decisions

### 1. Separation of Infra and Services
- **Decision**: The `infra` repository manages the proxy and server-level scripts, while each application has its own isolated repository deployed in `/srv/services`.
- **Why**: Blast radius. An error in an application deployment should never take down the reverse proxy or affect the deployment of other services.

### 2. Standardization on `/srv`
- **Decision**: All configurations go to `/srv/infra` and apps to `/srv/services`.
- **Why**: FHS (Filesystem Hierarchy Standard) compliance. `/srv` is specifically intended for site-specific data served by the system, keeping our Docker data cleanly separated from OS binaries (`/opt`) and user data (`/home`).

### 3. External Proxy Network
- **Decision**: We use an external Docker network named `proxy`.
- **Why**: Security and isolation. Instead of dumping everything on the default bridge, the `proxy` network securely bridges the edge router to frontend containers, while databases stay on isolated internal compose networks.

### 4. CI/CD via GitHub Actions and GHCR
- **Decision**: Images are built via GitHub Actions and stored in GHCR (GitHub Container Registry).
- **Why**: Simplifies secret management and natively integrates with our source code. It prevents the VPS from wasting CPU cycles building images locally.

### 5. PUID/PGID Standardization
- **Decision**: All containers map host users via `user: "${PUID}:${PGID}"`.
- **Why**: It natively solves Docker bind-mount permissions without insecure `chmod 777` or complex entrypoint scripts. The container process reads and writes exactly as the `deploy` user. We "fail fast" without defaults.

### 6. Services Own Their `infra` Folder
- **Decision**: Every service repository contains an `infra/` directory holding its `docker-compose.yml` and `data/`.
- **Why**: Unifies the infrastructure-as-code pattern at the service level. An engineer can look at any repository and immediately know where the deployment configuration lives.

## Architecture Diagram
```mermaid
graph TD
    User((User)) --> Proxy[Nginx Reverse Proxy]
    Proxy --> AppA[Service A Frontend]
    Proxy --> AppB[Service B Frontend]
    
    subgraph Service A Network
        AppA --> DB_A[(Database A)]
    end
    
    subgraph Service B Network
        AppB --> DB_B[(Database B)]
    end
```

## Common Mistakes
- **Blurring the lines**: Trying to deploy an application's database inside the `infra` repository instead of the service's own `infra/` folder.

## Troubleshooting
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for architectural failure modes.

## Related Documentation
- [Service Standard](SERVICE_STANDARD.md)
- [Permissions](PERMISSIONS.md)
