#!/bin/bash
# curl | bash entry point. Wrapped in main() so bash reads the whole script
# before running anything, and the installer gets the real terminal on stdin.
set -eEo pipefail

main() {
  local repo="https://github.com/maribowman/workstation-setup"
  local install_dir="$HOME/Dev/workstation-setup"
  local branch="${WS_BRANCH:-main}"

  echo "==> Installing git..."
  sudo pacman -S --noconfirm --needed git

  mkdir -p "$HOME/Dev"

  if [ -d "$install_dir/.git" ]; then
    echo "==> Updating existing installation..."
    git -C "$install_dir" pull --ff-only
  else
    echo "==> Cloning workstation-setup ($branch)..."
    git clone --branch "$branch" "$repo" "$install_dir"
  fi

  # The dotfiles submodule is private (SSH). It is initialised by install.sh
  # after the secrets phase has restored the SSH key.

  echo "==> Running installer..."
  bash "$install_dir/install/install.sh" </dev/tty
}

main "$@"
