#!/bin/bash
# Restic backup of $HOME to the Synology NAS.
#   restic_backup.sh          backup + prune + check
#   restic_backup.sh init     initialise the repository (once)
#   restic_backup.sh <args>   any other restic command against the repo, e.g. snapshots
set -eEo pipefail

NAS_HOST="10.0.40.10"
export RESTIC_REPOSITORY="sftp:mari@$NAS_HOST:/volume1/backups/workstation/restic"
export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-$HOME/.config/restic/password}"

# Separate NAS key exported by scripts/secrets.sh, if there is one.
SFTP_OPTS=()
if [ -f "$HOME/.ssh/id_nas" ]; then
  SFTP_OPTS=(-o "sftp.args=-i $HOME/.ssh/id_nas")
fi

if [ ! -f "$RESTIC_PASSWORD_FILE" ]; then
  echo "!!  $RESTIC_PASSWORD_FILE missing — run scripts/secrets.sh first" >&2
  exit 1
fi

case "${1:-backup}" in
backup)
  EXCLUDE_LIST=(
    "$HOME/.cache"
    "$HOME/.thumbnails"
    "$HOME/.local/share/Trash"
    "$HOME/Desktop"
  )
  EXCLUDE_FLAGS=()
  for path in "${EXCLUDE_LIST[@]}"; do
    EXCLUDE_FLAGS+=(--exclude "$path")
  done

  echo "==> Starting backup of $HOME to $RESTIC_REPOSITORY"
  restic "${SFTP_OPTS[@]}" backup "${EXCLUDE_FLAGS[@]}" "$HOME"

  echo "==> Pruning old snapshots..."
  restic "${SFTP_OPTS[@]}" forget \
    --keep-daily 5 \
    --keep-monthly 3 \
    --keep-yearly 1 \
    --prune

  echo "==> Verifying repository integrity..."
  restic "${SFTP_OPTS[@]}" check

  echo "==> Backup complete"
  ;;
*)
  restic "${SFTP_OPTS[@]}" "$@"
  ;;
esac
