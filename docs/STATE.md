# Infrastructure State Tracker

This document provides a high-level view of the current state of our production infrastructure setup. 
It ensures we always know exactly what has been configured and what is pending.

## Completed
- [x] Initial repository scaffolding
- [x] Reverse Proxy configuration (`nginx-proxy` + `acme-companion`)
- [x] Path standardization (`/srv/infra`, `/srv/services`)
- [x] Basic backup/restore scripts created
- [x] VPS Setup documentation created
- [x] Created the external `proxy` Docker network on the VPS

## Pending / Planned Work
- [ ] Apply security hardening on the VPS (SSH restrictions and Fail2Ban)
- [ ] Configure automatic security updates (unattended-upgrades) for the VPS
- [ ] Scaffold the first actual application
