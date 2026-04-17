#!/bin/bash
set -eEo pipefail

REPO="https://github.com/maribowman/workstation-setup"
INSTALL_DIR="$HOME/Dev/workstation-setup"

echo "==> Installing git..."
sudo pacman -S --noconfirm --needed git

mkdir -p "$HOME/Dev"

if [ -d "$INSTALL_DIR" ]; then
  echo "==> Updating existing installation..."
  git -C "$INSTALL_DIR" pull
else
  echo "==> Cloning workstation-setup..."
  git clone "$REPO" "$INSTALL_DIR"
fi

echo "==> Initialising dotfiles submodule..."
git -C "$INSTALL_DIR" submodule update --init --recursive

echo "==> Running installer..."
bash "$INSTALL_DIR/install/install.sh"
