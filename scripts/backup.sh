#!/usr/bin/env bash
set -euo pipefail

# CSKY Developments — Automated Production Backup Script
BACKUP_DIR="${BACKUP_DIR:-/srv/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"
echo "[$(date -Iseconds)] Starting CSKY ecosystem backups..."

# 1. Product Website Database (PostgreSQL)
if docker ps --format '{{.Names}}' | grep -q '^csky-product-db$'; then
  echo "Backing up csky-product-db..."
  docker exec csky-product-db pg_dump -U "${POSTGRES_USER:-csky}" "${POSTGRES_DB:-csky_store}" | gzip > "$BACKUP_DIR/csky_store_${TIMESTAMP}.sql.gz"
fi

# 2. Licensing Engine Database (PostgreSQL)
if docker ps --format '{{.Names}}' | grep -q '^csky-licensing-db$'; then
  echo "Backing up csky-licensing-db..."
  docker exec csky-licensing-db pg_dump -U "${POSTGRES_USER:-csky}" "${POSTGRES_DB:-csky_licensing}" | gzip > "$BACKUP_DIR/csky_licensing_${TIMESTAMP}.sql.gz"
fi

# 3. Product Store Uploaded Assets & Media
if [ -d "/srv/services/product-website/data" ]; then
  echo "Backing up product assets..."
  tar -czf "$BACKUP_DIR/product_data_${TIMESTAMP}.tar.gz" -C "/srv/services/product-website" data
fi

# 4. Cleanup backups older than retention window
echo "Pruning backups older than ${RETENTION_DAYS} days..."
find "$BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS" -exec rm -f {} +

echo "[$(date -Iseconds)] Backup routine finished successfully."
