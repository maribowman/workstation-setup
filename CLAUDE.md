# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

CachyOS (Arch-based) workstation bootstrap. A `curl | bash` script clones this repo to `~/.local/share/workstation-setup`, initialises a private dotfiles git submodule, and runs the full installer. The Taskfile is the daily maintenance driver.

## Structure

- **`install/boot.sh`** — `curl | bash` entry point; installs git, clones repo, inits submodule, calls `install.sh`
- **`install/install.sh`** — main orchestrator (`set -eEo pipefail`); runs all phases in order, logs to `~/workstation-install.log`
- **`packages/pacman.txt`** — pacman packages, one per line
- **`packages/aur.txt`** — AUR packages installed via paru
- **`packages/flatpak.txt`** — Flatpak app IDs
- **`scripts/paru.sh`** — bootstraps the paru AUR helper from source
- **`scripts/docker.sh`** — enables Docker service, adds user to docker group
- **`scripts/restic_backup.sh`** — backs up `$HOME` to Synology NAS (`192.168.0.3`) via SFTP; daily/monthly/yearly retention
- **`dotfiles/`** — git submodule (`git@github.com:maribowman/dotfiles`); every top-level directory is a stow package, all are stowed automatically

## Common commands

```bash
# Run full install
bash install/install.sh

# Daily update (packages + dotfiles)
task update

# Pull dotfiles and restow everything
task update-dotfiles

# Backup to NAS
task backup
```

## Adding packages

- pacman: add to `packages/pacman.txt`
- AUR: add to `packages/aur.txt`
- Flatpak: add to `packages/flatpak.txt`

## Dotfiles submodule

The `dotfiles/` submodule must have at least one commit on the remote before it can be checked out. To wire it up after the remote has commits:

```bash
git submodule add git@github.com:maribowman/dotfiles dotfiles
```

All top-level directories in the submodule are discovered and stowed automatically — no hardcoded list.

## Key details

- NAS IP is hardcoded as `192.168.0.3` in `scripts/restic_backup.sh`
- `task backup-init` must be run once to initialise the restic repo before first backup
- Snapper is configured for the root BTRFS subvolume during install
- Go and uv are installed via pacman (`extra` repo) — no manual version pinning
