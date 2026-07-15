#!/bin/bash
set -eEo pipefail

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$HOME/workstation-install.log"

log() { echo "==> $*" | tee -a "$LOG"; }

exec > >(tee -a "$LOG") 2>&1

log "Starting workstation installation"
log "Install dir: $INSTALL_DIR"

# ── 1. paru ──────────────────────────────────────────────────────────────────
log "Installing paru..."
bash "$INSTALL_DIR/scripts/paru.sh"

# ── 2. pacman packages ───────────────────────────────────────────────────────
log "Installing pacman packages..."
grep -v '^\s*#' "$INSTALL_DIR/packages/pacman.txt" | grep -v '^\s*$' | \
  xargs sudo pacman -S --noconfirm --needed

# ── 3. AUR packages ──────────────────────────────────────────────────────────
log "Installing AUR packages..."
grep -v '^\s*#' "$INSTALL_DIR/packages/aur.txt" | grep -v '^\s*$' | \
  xargs paru -S --noconfirm --needed

# ── 4. Flatpak packages ──────────────────────────────────────────────────────
log "Installing Flatpak packages..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
grep -v '^\s*#' "$INSTALL_DIR/packages/flatpak.txt" | grep -v '^\s*$' | \
  xargs -I{} flatpak install -y flathub {}

# ── 5. Docker ────────────────────────────────────────────────────────────────
log "Configuring Docker..."
bash "$INSTALL_DIR/scripts/docker.sh"

# ── 6. Resilio Sync ──────────────────────────────────────────────────────────
log "Enabling Resilio Sync..."
systemctl --user enable --now rslsync

# ── 7. Snapper (BTRFS snapshots) ─────────────────────────────────────────────
log "Configuring Snapper..."
bash "$INSTALL_DIR/scripts/snapper.sh"

# ── 8. Dotfiles via stow ─────────────────────────────────────────────────────
log "Applying dotfiles..."
DOTFILES="$INSTALL_DIR/dotfiles"
(cd "$DOTFILES" && ls -d */ | xargs stow -t "$HOME")

# ── 9. Default shell ─────────────────────────────────────────────────────────
if [ "$SHELL" != "$(which zsh)" ]; then
  log "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

log ""
log "Installation complete!"
log ""
log "Next steps:"
log "  1. Re-login (or reboot) for group changes to take effect"
log "  2. Initialise restic backup repo (first time only):"
log "       restic -r sftp:mari@10.0.40.10:/volume1/backups/workstation/restic init"
log "  3. Run a backup:  task backup"
log "  4. Update system: task update"
