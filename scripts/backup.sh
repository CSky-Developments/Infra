#!/usr/bin/env bash
set -euo pipefail

# CSKY Developments — Automated Production Backup Script
# Backs up all production PostgreSQL databases, licensing keys,
# and CodeHost user project storage.
#
# Schedule via crontab:
#   0 3 * * * /bin/bash /srv/infra/scripts/backup.sh >> /srv/backups/backup.log 2>&1

BACKUP_DIR="${BACKUP_DIR:-/srv/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"
echo ""
echo "============================================="
echo "[$(date -Iseconds)] Starting CSKY ecosystem backups..."
echo "============================================="

ERRORS=0

# ─── 1. CodeHost Database (PostgreSQL 15) ────────────────────────────
if docker ps --format '{{.Names}}' | grep -q '^codehost-db$'; then
  echo "[$(date -Iseconds)] Backing up codehost-db..."
  if docker exec codehost-db sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' | gzip > "$BACKUP_DIR/codehost_db_${TIMESTAMP}.sql.gz"; then
    SIZE=$(du -h "$BACKUP_DIR/codehost_db_${TIMESTAMP}.sql.gz" | cut -f1)
    echo "  ✓ codehost-db backed up successfully ($SIZE)"
  else
    echo "  ✗ ERROR: codehost-db backup failed!"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ⚠ codehost-db container not running, skipping."
fi

# ─── 2. Licensing Engine Database (PostgreSQL 16) ────────────────────
if docker ps --format '{{.Names}}' | grep -q '^licensing-engine-db$'; then
  echo "[$(date -Iseconds)] Backing up licensing-engine-db..."
  if docker exec licensing-engine-db sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' | gzip > "$BACKUP_DIR/licensing_db_${TIMESTAMP}.sql.gz"; then
    SIZE=$(du -h "$BACKUP_DIR/licensing_db_${TIMESTAMP}.sql.gz" | cut -f1)
    echo "  ✓ licensing-engine-db backed up successfully ($SIZE)"
  else
    echo "  ✗ ERROR: licensing-engine-db backup failed!"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ⚠ licensing-engine-db container not running, skipping."
fi

# ─── 3. Licensing Engine RSA Keys ────────────────────────────────────
if [ -d "/srv/services/licensing-engine/keys" ]; then
  echo "[$(date -Iseconds)] Backing up licensing-engine keys..."
  if tar -czf "$BACKUP_DIR/licensing_keys_${TIMESTAMP}.tar.gz" -C "/srv/services/licensing-engine" keys; then
    echo "  ✓ Licensing keys backed up successfully"
  else
    echo "  ✗ ERROR: Licensing keys backup failed!"
    ERRORS=$((ERRORS + 1))
  fi
fi

# ─── 4. CodeHost User Project Storage ────────────────────────────────
if [ -d "/srv/services/code-host/data/api_storage" ]; then
  echo "[$(date -Iseconds)] Backing up CodeHost user project storage..."
  if tar -czf "$BACKUP_DIR/codehost_storage_${TIMESTAMP}.tar.gz" -C "/srv/services/code-host/data" api_storage; then
    SIZE=$(du -h "$BACKUP_DIR/codehost_storage_${TIMESTAMP}.tar.gz" | cut -f1)
    echo "  ✓ CodeHost storage backed up successfully ($SIZE)"
  else
    echo "  ✗ ERROR: CodeHost storage backup failed!"
    ERRORS=$((ERRORS + 1))
  fi
fi

# ─── 5. Cleanup old backups ──────────────────────────────────────────
echo "[$(date -Iseconds)] Pruning backups older than ${RETENTION_DAYS} days..."
PRUNED=$(find "$BACKUP_DIR" -type f -name "*.gz" -mtime +"$RETENTION_DAYS" -print -delete | wc -l)
echo "  Pruned $PRUNED old backup file(s)."

# ─── Summary ─────────────────────────────────────────────────────────
echo "============================================="
if [ "$ERRORS" -gt 0 ]; then
  echo "[$(date -Iseconds)] ⚠ Backup finished with $ERRORS error(s)!"
  exit 1
else
  echo "[$(date -Iseconds)] ✓ All backups completed successfully."
fi
