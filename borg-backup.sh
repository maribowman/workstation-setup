#!/bin/bash

# INITIAL REPO SETUP
# borg init --encryption=none $PATH
# borg info --remote-path=/usr/local/bin/borg $USER@$HOST:$PATH

USERNAME="mari"
HOST="192.168.0.3"
REMOTE_PATH="/volume1/backups/ubuntu_backup_home/borg"
REPO="$USER@$HOST:$REMOTE_PATH"

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

echo "Starting backup of $BACKUP_SOURCE to $REPO"
borg create --remote-path=/usr/local/bin/borg --verbose --stats --compression lz4 --exclude-from <(printf '%s\n' "${EXCLUDE_LIST[@]}") "$REPO::$ARCHIVE_NAME" "$BACKUP_SOURCE"
borg prune --remote-path=/usr/local/bin/borg --list --keep-daily=5 --keep-monthly=3 --keep-yearly=1 "$REPO"

echo "Backup completed! Checking repository consistency"
borg check --remote-path=/usr/local/bin/borg --verify-data "$REPO"

exit 0

