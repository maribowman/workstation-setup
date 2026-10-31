#!/bin/bash
set -eEo pipefail

create_root_config() {
  # With a separate @snapshots subvolume mounted at /.snapshots (CachyOS layout),
  # `snapper create-config` fails because the directory exists. Standard
  # workaround: let snapper create its own subvolume, drop it, remount ours.
  if mountpoint -q /.snapshots; then
    echo "==> /.snapshots is a mounted subvolume, re-attaching it to snapper"
    sudo umount /.snapshots
    sudo rmdir /.snapshots
    sudo snapper -c root create-config /
    sudo btrfs subvolume delete /.snapshots
    sudo mkdir /.snapshots
    sudo mount /.snapshots
    sudo chmod 750 /.snapshots
  else
    sudo snapper -c root create-config /
  fi
}

if ! sudo snapper list-configs | awk -F'|' 'NR>2 {gsub(/ /,"",$1); print $1}' | grep -qx root; then
  create_root_config
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

# Bootable snapshots: CachyOS with Limine ships limine-snapper-sync.
if pacman -Q limine-snapper-sync &>/dev/null; then
  if systemctl list-unit-files limine-snapper-sync.service &>/dev/null; then
    sudo systemctl enable --now limine-snapper-sync.service
    echo "==> limine-snapper-sync enabled: snapshots appear in the boot menu"
  fi
else
  echo "==> limine-snapper-sync not installed: snapshots are not bootable from the boot menu"
fi
