#!/bin/bash
set -eEo pipefail

if command -v paru &>/dev/null; then
  echo "==> paru already installed, skipping"
  exit 0
fi

echo "==> Installing paru AUR helper..."

PARU_TMP="$(mktemp -d)"
trap 'rm -rf "$PARU_TMP"' EXIT

sudo pacman -S --noconfirm --needed git base-devel

git clone https://aur.archlinux.org/paru.git "$PARU_TMP/paru"
(cd "$PARU_TMP/paru" && makepkg -si --noconfirm)

echo "==> paru installed"
