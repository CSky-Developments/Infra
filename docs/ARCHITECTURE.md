# Architectural Decisions

This document records the major architectural decisions for the production VPS infrastructure and the reasoning behind them.

## 1. Directory Structure (`/srv` standard)
- **Decision**: All infrastructure configuration is deployed to `/srv/infra`, and all containerized applications are deployed to `/srv/services/<app-name>`.
- **Reasoning**: Standardization. `/srv` is the FHS standard for site-specific data served by the system. It cleanly separates our Docker services from generic system binaries (`/opt`) or user home directories.

## 2. Reverse Proxy Layer
- **Decision**: We use `nginx-proxy` and `acme-companion` as the shared edge router.
- **Reasoning**: It is simple, proven, and requires zero manual configuration for new services. It automatically routes traffic and generates Let's Encrypt certificates by reading Docker socket events. We chose this over Traefik or Caddy to minimize complexity and abstraction for a single-node VPS.

## 3. Network Isolation
- **Decision**: We use a dedicated external Docker network named `proxy` strictly for routing external traffic from the proxy to the applications.
- **Reasoning**: Explicit network boundaries. Instead of relying on the default Docker bridge, the `proxy` network connects only the edge router and frontend application containers. Backend services (like databases) remain on isolated internal networks (the default network generated per compose file) for maximum security.

## 4. Single-Node Focus
- **Decision**: No Kubernetes, Docker Swarm, or complex orchestration.
- **Reasoning**: Simplicity. The current scale only requires a single VPS. Adding orchestration would introduce massive operational overhead without providing immediate business value.
