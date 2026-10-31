#!/bin/bash
# Lint every script with shellcheck; on an Arch system also verify that each declared
# package exists, so typos fail here instead of halfway through a fresh install.
set -eEo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../install/lib.sh"

status=0

log "shellcheck"
shopt -s nullglob
shellcheck -x -P SCRIPTDIR "$WS_DIR"/install/*.sh "$WS_DIR"/scripts/*.sh "$WS_DIR"/migrations/*.sh || status=1
shopt -u nullglob

if command -v pacman &>/dev/null; then
  log "pacman packages"
  while read -r pkg; do
    pacman -Si "$pkg" &>/dev/null || pacman -Sg "$pkg" &>/dev/null || { warn "not in repos: $pkg"; status=1; }
  done < <(read_pkgs "$WS_DIR/packages/pacman.txt")
fi

if command -v paru &>/dev/null; then
  log "AUR packages"
  while read -r pkg; do
    paru -Si --aur "$pkg" &>/dev/null || { warn "not in AUR: $pkg"; status=1; }
  done < <(read_pkgs "$WS_DIR/packages/aur.txt")
fi

if command -v flatpak &>/dev/null; then
  log "Flatpak apps"
  while read -r app; do
    flatpak remote-info flathub "$app" &>/dev/null || { warn "not on Flathub: $app"; status=1; }
  done < <(read_pkgs "$WS_DIR/packages/flatpak.txt")
fi

exit "$status"
