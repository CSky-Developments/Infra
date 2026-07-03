#!/bin/bash
set -e

# Simple restore script
if [ -z "$1" ]; then
  echo "Usage: $0 <backup_file>"
  exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file not found."
  exit 1
fi

echo "Starting restore from $BACKUP_FILE..."

# Example: Restore a Postgres database
# gunzip -c "$BACKUP_FILE" | docker exec -i my_postgres psql -U myuser mydb

# Example: Restore a volume
# tar -xzf "$BACKUP_FILE" -C /var/lib/docker/volumes/my_volume/_data

echo "Restore complete."
