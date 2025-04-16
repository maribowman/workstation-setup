#!/bin/bash

REPO="mari@192.168.0.1:/volume1/backups/ubuntu_backup_home/borg"
BORG_PASSPHRASE=""
BORG_RSH="ssh"
BACKUP_SOURCE="/home/$USER/"
ARCHIVE_NAME="{hostname}-{now:%Y%m%d_%H%M}"
EXCLUDE_LIST=(
    "$HOME/.cache"
    "$HOME/.thumbnails"
    "$HOME/.local/share/Trash"
)

export BORG_PASSPHRASE="$BORG_PASSPHRASE"

echo "Starting backup of $BACKUP_SOURCE to $REPO as archive $ARCHIVE_NAME"
borg create --verbose --stats --compression lz4 --exclude-from <(printf '%s\n' "${EXCLUDE_LIST[@]}") "$REPO::$ARCHIVE_NAME" "$BACKUP_SOURCE"
borg prune --list --keep-daily=5 --keep-monthly=3 --keep-yearly=1 "$REPO"
borg check --verify-data "$REPO"

exit 0

