#!/bin/bash
set -e

# Simple backup script for Docker volumes and databases
BACKUP_DIR="/srv/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "Starting backup at $TIMESTAMP..."

# Example: Backup a specific volume
# tar -czf "$BACKUP_DIR/my_volume_$TIMESTAMP.tar.gz" -C /var/lib/docker/volumes/my_volume/_data .

# Example: Backup a Postgres database running in a container
# docker exec my_postgres pg_dump -U myuser mydb | gzip > "$BACKUP_DIR/mydb_$TIMESTAMP.sql.gz"

echo "Backup complete. Files saved to $BACKUP_DIR"
