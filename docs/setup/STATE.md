# Infrastructure State Tracker

This document provides a high-level view of the current state of our production infrastructure setup.
It ensures we always know exactly what has been configured and what is pending.

## Completed

- [x] Ubuntu configured
- [x] Docker installed
- [x] Docker Compose installed
- [x] Docker network `proxy` created
- [x] Reverse proxy deployed
- [x] Let's Encrypt companion deployed
- [x] Infrastructure repository moved to `/srv/infra`
- [x] GitHub SSH authentication configured
- [x] Deploy services:
  - [x] `licensing-engine` (`api.csky.dev`)
  - [x] `discord-bot` (Community bot)
  - [x] `product-website` (`store.csky.dev`)
  - [x] `plugin-crafter` (`crafter.csky.dev`)
  - [x] `website` (`csky.dev`)

## Next

- [ ] Automated continuous backups monitoring and off-site replication
- [ ] Centralized metrics dashboard and alerting
