#!/bin/bash
set -eEo pipefail

REPO="sftp:mari@192.168.0.3:/volume1/backups/workstation/restic"
BACKUP_SOURCE="$HOME"
EXCLUDE_LIST=(
  "$HOME/.cache"
  "$HOME/.thumbnails"
  "$HOME/.local/share/Trash"
  "$HOME/Desktop"
)

# Build --exclude flags
EXCLUDE_FLAGS=()
for path in "${EXCLUDE_LIST[@]}"; do
  EXCLUDE_FLAGS+=(--exclude "$path")
done

echo "==> Starting backup of $BACKUP_SOURCE to $REPO"
restic -r "$REPO" backup "${EXCLUDE_FLAGS[@]}" "$BACKUP_SOURCE"

echo "==> Pruning old snapshots..."
restic -r "$REPO" forget \
  --keep-daily 5 \
  --keep-monthly 3 \
  --keep-yearly 1 \
  --prune

echo "==> Verifying repository integrity..."
restic -r "$REPO" check

echo "==> Backup complete"
