#!/bin/bash
# Full workstation install. Re-entrant: every phase skips work that is already done.
set -eEo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

INSTALL_DIR="$WS_DIR"
LOG="$HOME/workstation-install.log"

exec > >(tee -a "$LOG") 2>&1

trap 'echo; echo "✗ Install failed at ${BASH_SOURCE[0]}:$LINENO: $BASH_COMMAND"; echo "  Log: $LOG"; echo "  Fix the problem, then re-run: task install"' ERR

PHASE=0
phase() {
  PHASE=$((PHASE + 1))
  echo
  echo "━━ [$PHASE] $* ━━"
}

# A machine that has never recorded migrations is a fresh install: its end
# state already includes every migration, so they are only marked as done.
FRESH_INSTALL=0
[ -d "$WS_STATE_DIR/migrations" ] || FRESH_INSTALL=1

log "Starting workstation installation ($(date))"
log "Install dir: $INSTALL_DIR"

phase "paru"
bash "$INSTALL_DIR/scripts/paru.sh"

phase "pacman packages"
read_pkgs "$INSTALL_DIR/packages/pacman.txt" | xargs -r sudo pacman -S --noconfirm --needed

phase "AUR packages"
read_pkgs "$INSTALL_DIR/packages/aur.txt" | xargs -r paru -S --noconfirm --needed

phase "Flatpak packages"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
read_pkgs "$INSTALL_DIR/packages/flatpak.txt" | xargs -r sudo flatpak install -y --noninteractive flathub

phase "Secrets (Resilio Sync + KeePass)"
bash "$INSTALL_DIR/scripts/secrets.sh"

phase "Dotfiles submodule"
# Only on first checkout: `submodule update` hard-resets dotfiles/ and would
# discard uncommitted work there on a re-run.
if [ -e "$INSTALL_DIR/dotfiles/.git" ]; then
  log "dotfiles already checked out, leaving it untouched"
else
  git -C "$INSTALL_DIR" submodule update --init dotfiles
fi

phase "Docker"
bash "$INSTALL_DIR/scripts/docker.sh"

phase "Snapper (BTRFS snapshots)"
bash "$INSTALL_DIR/scripts/snapper.sh"

phase "Backup timer"
bash "$INSTALL_DIR/scripts/backup-timer.sh"

phase "Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  log "Oh My Zsh already installed, skipping"
else
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

phase "Dotfiles via stow"
bash "$INSTALL_DIR/scripts/stow.sh"

phase "Default shell"
ZSH_PATH="$(command -v zsh)"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]; then
  log "Setting zsh as default shell..."
  sudo chsh -s "$ZSH_PATH" "$USER"
else
  log "zsh already the default shell"
fi

phase "Migrations"
if ((FRESH_INSTALL)); then
  bash "$INSTALL_DIR/scripts/migrate.sh" --mark-all
  log "Fresh install: existing migrations marked as done"
else
  bash "$INSTALL_DIR/scripts/migrate.sh"
fi

echo
log "Installation complete!"
echo
log "Next steps:"
log "  1. Re-login (or reboot) for the docker group and zsh to take effect"
log "  2. Initialise the restic repo (first time only): task backup-init"
log "  3. Run a backup now (or let restic-backup.timer do it daily): task backup"
log "  4. Daily maintenance: task update"
