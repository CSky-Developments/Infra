# Infrastructure

A simple, clean, and production-ready infrastructure repository for a single VPS deployment.

## Purpose

This repository contains the foundational infrastructure for deploying multiple containerized services on a single Ubuntu VPS. It uses `nginx-proxy` and `acme-companion` to provide automated routing and free SSL certificates (via Let's Encrypt) to any Docker container.

The goal is to keep things minimal and easy to understand without over-engineering.

## Folder Structure

```
infra/
├── proxy/          # Nginx proxy & SSL termination setup
├── scripts/        # Utility scripts (backups, restores, etc.)
├── docs/           # Documentation (setup, deployment)
├── .gitignore
├── .editorconfig
├── LICENSE
└── README.md
```

## Getting Started

1. **Server Setup**: Provision a fresh Ubuntu VPS and follow the [VPS Setup Guide](docs/VPS_SETUP.md).
2. **Start the Proxy**:
   ```bash
   cd /srv/infra/proxy
   cp .env.example .env
   # Edit .env and set ACME_DEFAULT_EMAIL
   docker compose up -d
   ```
3. **Deploy Services**: Follow the [Deployment Workflow](docs/DEPLOYMENT.md) to add services.
4. **Updates**: All updates are managed via Git. Simply `git pull` the latest changes and run `docker compose up -d` in the affected directory.

## How to Add a New Service

To expose a new service via the proxy, just add the `VIRTUAL_HOST` and `LETSENCRYPT_HOST` environment variables to its Docker container. 

Example `docker-compose.yml` for a new service:
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    environment:
      - VIRTUAL_HOST=example.yourdomain.com
      - LETSENCRYPT_HOST=example.yourdomain.com
```

When you start this service, the proxy will automatically route `example.yourdomain.com` to it and secure it with SSL.
