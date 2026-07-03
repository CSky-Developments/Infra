# Infrastructure State Tracker

This document provides a high-level view of the current state of our production infrastructure setup. 
It ensures we always know exactly what has been configured and what is pending.

## Completed
- [x] Initial repository scaffolding
- [x] Reverse Proxy configuration (`nginx-proxy` + `acme-companion`)
- [x] Path standardization (`/srv/infra`, `/srv/services`)
- [x] Basic backup/restore scripts created
- [x] VPS Setup documentation created
- [x] Security Hardening: Documented SSH restrictions and Fail2Ban

## Pending / Next Steps
- [ ] Configure automatic security updates (unattended-upgrades) for the VPS
- [ ] Create a `docker network` specifically for the proxy so services can easily attach to it
- [ ] Scaffold the first actual application
