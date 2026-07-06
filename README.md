# CSky Infrastructure Wiki

> The single source of truth for CSky's production infrastructure.

## Repository Overview
This repository contains the configuration, orchestration, and documentation for the entire CSky infrastructure platform. It governs how the VPS is provisioned, how the proxy routes traffic, and strictly defines the standards every application must follow.

## Architecture Overview
```mermaid
graph TD
    Internet((Internet)) --> Proxy[Nginx Proxy Network]
    Proxy --> Nginx[Nginx Proxy :80/443]
    Proxy --> Acme[ACME Companion]
    
    subgraph /srv/services
        Nginx --> App1[App 1 Container]
        Nginx --> App2[App 2 Container]
    end
    
    subgraph /srv/infra
        Nginx
        Acme
    end
```

## Folder Structure
```text
/
├── proxy/          # Core reverse proxy (nginx-proxy + acme-companion)
├── scripts/        # Utility and backup scripts
├── docs/           # Internal Engineering Wiki
└── ...
```

## Quick Start
1. **New to the project?** Start with [Getting Started](docs/setup/GETTING_STARTED.md).
2. **Setting up a new server?** See [VPS Setup](docs/setup/VPS_SETUP.md).
3. **Deploying a new service?** Read the [Service Standard](docs/architecture/SERVICE_STANDARD.md) and [Deployment Guide](docs/operations/DEPLOYMENT.md).

## Documentation Index

### Core Architecture
- [Platform Architecture](docs/architecture/ARCHITECTURE.md)
- [CSky Service Standard](docs/architecture/SERVICE_STANDARD.md)
- [Permissions & Ownership](docs/architecture/PERMISSIONS.md)
- [Reverse Proxy Layer](docs/architecture/REVERSE_PROXY.md)

### Setup & State
- [VPS Setup Guide](docs/setup/VPS_SETUP.md)
- [Getting Started](docs/setup/GETTING_STARTED.md)
- [Infrastructure State (Checklist)](docs/setup/STATE.md)

### Operations
- [Deployment Workflow](docs/operations/DEPLOYMENT.md)
- [Test Environments (MC/Discord)](docs/operations/TEST_ENVIRONMENTS.md)
- [CI/CD Standard](docs/operations/CI_CD.md)
- [Daily Operations](docs/operations/OPERATIONS.md)
- [Local Agent Operations](docs/agents/AGENT_OPERATIONS.md)
- [Migration Guide](docs/setup/MIGRATION.md)

### Support
- [Troubleshooting](docs/operations/TROUBLESHOOTING.md)
- [Disaster Recovery](docs/operations/DISASTER_RECOVERY.md)
- [Changelog Guide](docs/operations/CHANGELOG_GUIDE.md)
