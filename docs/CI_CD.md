# CI/CD Pipeline Standard

## Why does this exist?
To ensure all CSky services are built and deployed using a uniform, automated process, minimizing human error.

## When should it be used?
When configuring GitHub Actions for a new service repository.

## How does it work?
We use GitHub Actions to build Docker images and push them to GHCR. The deployment to the VPS is executed via SSH.

### Sequence Diagram
```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as GitHub Actions
    participant GHCR as GitHub Container Registry
    participant VPS as Ubuntu VPS

    Dev->>Git: Push to main
    Git->>Git: Build Docker Image
    Git->>GHCR: Push Image
    Git->>VPS: SSH: cd /srv/services/<app>/infra && git pull
    Git->>VPS: SSH: docker compose pull && docker compose up -d
    VPS->>GHCR: Pull latest image
    VPS->>VPS: Restart container
```

## Step-by-Step Instructions

1. **GitHub Secrets**: Add `VPS_SSH_KEY`, `VPS_HOST`, and `VPS_USER` to your repository secrets.
2. **GHCR Authentication**: Ensure the VPS `csky` user is authenticated to GHCR using a Personal Access Token (PAT).
3. **Action Workflow**: Place the standard workflow in `.github/workflows/deploy.yml`.

### Scaling to Multiple Services (Reusing Credentials)
When deploying a second service (e.g., `plugin-crafter`), you **do not** need to generate a new SSH key on the VPS. 

**Method A: GitHub Organization Secrets (Recommended)**
If all your repositories live under the same GitHub Organization, configure `VPS_SSH_KEY`, `VPS_HOST`, and `VPS_USER` as **Organization Secrets** instead of Repository Secrets. Every repository will automatically inherit them, requiring zero setup for new services.

**Method B: Retrieve Existing Key from VPS**
If you are using personal repositories, you must copy the existing SSH private key from the VPS into the new repository's secrets.
1. SSH into the VPS.
2. View the private key for the `csky` user:
   ```bash
   sudo cat /home/csky/.ssh/id_ed25519
   ```
   *(Note: If you named your CI/CD key something else, look for it in `ls -la /home/csky/.ssh/`)*
3. Copy the entire output (including `-----BEGIN OPENSSH PRIVATE KEY-----`) and paste it as `VPS_SSH_KEY` in the new repository.

## Common Mistakes
- **Image Tags**: Do not hardcode `latest` in the workflow without ensuring proper rolling updates. Use SHA-based tags for safety.
- **SSH Key**: Using a key with a passphrase. CI/CD SSH keys must be passwordless.

## Troubleshooting
- **GHCR Pull Fails on VPS**: The VPS `csky` user's PAT may have expired. Regenerate it and `docker login ghcr.io`.

## Related Documentation
- [Deployment Workflow](DEPLOYMENT.md)
