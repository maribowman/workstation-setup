#!/bin/bash
set -eEo pipefail

if ! sudo snapper list-configs | grep -q '^root'; then
  sudo snapper -c root create-config /
fi

# Pre/post pacman snapshots only (snap-pac); no timeline hoarding.
# Long-term history lives in restic backups, not snapshots.
sudo snapper -c root set-config \
  TIMELINE_CREATE=no \
  NUMBER_CLEANUP=yes \
  NUMBER_LIMIT=15 \
  NUMBER_LIMIT_IMPORTANT=5 \
  EMPTY_PRE_POST_CLEANUP=yes

sudo systemctl enable --now snapper-cleanup.timer
sudo systemctl disable --now snapper-timeline.timer 2>/dev/null || true
