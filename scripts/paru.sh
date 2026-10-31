#!/bin/bash
# paru ships in the CachyOS repos (and is usually preinstalled).
set -eEo pipefail

if command -v paru &>/dev/null; then
  echo "==> paru already installed, skipping"
  exit 0
fi

echo "==> Installing paru from the CachyOS repos..."
sudo pacman -S --noconfirm --needed paru
