# Getting Started

## Why does this exist?
To provide a complete, end-to-end journey for a new engineer starting with absolutely zero infrastructure, leading them to a fully operational platform.

## When should it be used?
Use this guide when onboarding new team members or completely rebuilding the company's infrastructure from scratch.

## How does it work?
This guide links together our more detailed, specialized documentation into a linear, step-by-step onboarding flow.

## Step-by-Step Instructions

1. **Understand the Architecture**
   Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand *why* we do things the way we do.
2. **Provision the Server**
   Follow [VPS_SETUP.md](VPS_SETUP.md) to configure the raw Ubuntu VPS, install Docker, secure SSH, and set up GitHub authentication.
3. **Deploy the Reverse Proxy**
   Follow [REVERSE_PROXY.md](REVERSE_PROXY.md) to bring the edge routing layer online.
4. **Learn the Service Standard**
   Read [SERVICE_STANDARD.md](SERVICE_STANDARD.md) and [PERMISSIONS.md](PERMISSIONS.md) to understand how applications are structured.
5. **Deploy the First App**
   Follow [DEPLOYMENT.md](DEPLOYMENT.md) to deploy your first containerized application behind the proxy.
6. **Learn Operations**
   Familiarize yourself with [OPERATIONS.md](OPERATIONS.md) for daily management commands.

## Common Mistakes
- **Skipping the architecture read**: Assuming standard Docker Compose tutorials apply here. We have strict standards (like PUID/PGID and `infra/` folders) that diverge from typical hobbyist setups.

## Troubleshooting
- If you get stuck anywhere, refer to [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Related Documentation
- [VPS Setup](VPS_SETUP.md)
- [Architecture](ARCHITECTURE.md)
