#!/bin/bash
# Stow every package in dotfiles/ into $HOME.
# Real files that would block stow (e.g. the distro's default ~/.zshrc) are moved
# to ~/.dotfiles-backup/<timestamp>/ first. Never uses --adopt: that would write
# into the dotfiles submodule.
set -eEo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../install/lib.sh"

DOTFILES="$WS_DIR/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$DOTFILES" ] || [ -z "$(ls -A "$DOTFILES")" ]; then
  warn "dotfiles submodule is empty — run: git -C $WS_DIR submodule update --init dotfiles"
  exit 1
fi

mapfile -t PACKAGES < <(cd "$DOTFILES" && find . -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf '%f\n' | sort)

moved=0
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES/$pkg/"}"
    target="$HOME/$rel"
    [ -e "$target" ] || [ -L "$target" ] || continue
    # Already stowed (directly or through a folded parent directory).
    [ "$(realpath -m "$target")" = "$(realpath -m "$src")" ] && continue

    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
    log "Backed up conflicting $target"
    moved=1
  done < <(find "$DOTFILES/$pkg" -type f -print0)
done

((moved)) && log "Conflicting files moved to $BACKUP_DIR"

log "Stowing: ${PACKAGES[*]}"
stow -d "$DOTFILES" -t "$HOME" -R "${PACKAGES[@]}"
