# Agent Operations & Observability

## Why does this exist?
To document how AI DevOps agents operating locally can securely interact with the production VPS.

## Core Rule: Read-Only Observability
The AI agent is granted SSH access to the production VPS **strictly for observability and debugging**. 
It is explicitly forbidden from making direct mutations (writing files, restarting containers manually, or changing permissions) over SSH. 
If the AI detects an issue during observation, it must commit the fix to the Git repository so it can be deployed via the standard CI/CD workflow.

## Approved SSH Commands
The agent is encouraged to run commands like:
- `docker ps`
- `docker compose logs --tail=100 <service>`
- `cat /srv/services/<service>/infra/.env`
- `ls -la /srv/services/<service>/data`

## Connecting to the VPS
The agent should execute SSH commands using the local Windows PowerShell terminal:
```powershell
ssh -i C:\Users\ArshPathan\.ssh\id_rsa_agent csky@51.79.249.143 "docker ps"
```
*(Note: Replace `id_rsa_agent` with the actual key name if different).*
