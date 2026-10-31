# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

CachyOS (Arch-based) workstation bootstrap. A `curl | bash` script clones this repo to `~/Dev/workstation-setup` and runs the full installer, which restores secrets from a Resilio-synced KeePass vault before initialising the private dotfiles git submodule. The Taskfile is the daily maintenance driver.

## Structure

- **`install/boot.sh`** — `curl | bash` entry point, wrapped in `main()`; installs git, clones repo (branch via `WS_BRANCH`), runs `install.sh` with stdin from `/dev/tty`. Does **not** init the submodule (no SSH key yet)
- **`install/install.sh`** — main orchestrator (`set -eEo pipefail`, ERR trap); re-entrant; logs to `~/workstation-install.log`. Phase order: paru → pacman → AUR → flatpak → secrets → dotfiles submodule (first checkout only) → docker → snapper → backup timer → oh-my-zsh → stow → default shell → migrations
- **`install/lib.sh`** — shared helpers sourced by every script: `WS_DIR`, `WS_STATE_DIR`, `log`, `warn`, `read_pkgs` (strips full-line and trailing `#` comments)
- **`scripts/secrets.sh`** — starts Resilio Sync, waits for the KeePass vault in `~/Sync/credentials`, unlocks it once and exports the GitHub SSH key, optional NAS key and restic password via `keepassxc-cli`; skips anything already present
- **`scripts/stow.sh`** — stows every dotfiles package with `stow -R`; moves conflicting real files to `~/.dotfiles-backup/<timestamp>/` first. Never use `--adopt` (it writes into `dotfiles/`)
- **`scripts/migrate.sh`** — runs `migrations/<unix-ts>.sh` not yet recorded in `~/.local/state/workstation-setup/migrations/`; `--mark-all` on fresh installs
- **`scripts/backup-timer.sh`** — installs the `restic-backup` systemd user service + daily timer
- **`scripts/drift.sh`**, **`scripts/lint.sh`** — back `task drift` and `task lint`
- **`packages/pacman.txt`** — pacman packages, one per line
- **`packages/aur.txt`** — AUR packages installed via paru
- **`packages/flatpak.txt`** — Flatpak app IDs
- **`scripts/paru.sh`** — installs paru from the CachyOS repos if missing
- **`scripts/docker.sh`** — enables Docker service, adds user to docker group
- **`scripts/snapper.sh`** — configures snapper root config (handles an existing `@snapshots` mount): pre/post pacman snapshots via snap-pac, ~15 snapshot cap, no timeline; enables `limine-snapper-sync` when installed
- **`scripts/restic_backup.sh`** — single source of the restic repo URL; no args = backup `$HOME` to Synology NAS (`10.0.40.10`) via SFTP with daily/monthly/yearly retention; any other args are passed to restic (`init`, `snapshots`, ...). Password from `~/.config/restic/password`
- **`migrations/`** — one-off changes for existing machines, see `migrations/README.md`
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

# Lint scripts and verify package lists
task lint
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

**Never modify anything under `dotfiles/`.** It is a separate repository
(`git@github.com:maribowman/dotfiles`) and its owner is the only writer. When a task requires a
dotfiles change, print the target file path and the exact diff, then stop — do not write the
file, and do not run `git add`, `git commit` or `git push` inside `dotfiles/`.

Why: `git submodule update` hard-resets `dotfiles/` to the pinned commit and detaches HEAD,
silently discarding uncommitted work there. This has destroyed the same change twice.

The parent-side pointer bump (`git add dotfiles` plus a `bump dotfiles: ...` commit) is the
owner's to run as well — never stage a submodule pointer change on their behalf.

## Key details

- NAS IP is hardcoded as `10.0.40.10` in `scripts/restic_backup.sh`
- Re-running the installer must never run `git submodule update` on an existing checkout — it hard-resets `dotfiles/` (see above); install.sh only inits it when `dotfiles/.git` is absent
- `task backup-init` must be run once to initialise the restic repo before first backup
- Snapper is configured for the root BTRFS subvolume during install; retention is bounded (NUMBER_LIMIT=15, NUMBER_LIMIT_IMPORTANT=5, timeline disabled) — snap-pac provides pre/post pacman snapshots, restic covers long-term history
- Go and uv are installed via pacman (`extra` repo) — no manual version pinning
- Proton Pass CLI comes from the AUR (`proton-pass-cli-bin`, Proton's official prebuilt binary) so `paru -Syu` keeps it current. Its zsh completions use `pass-cli completions zsh` — a hidden clap subcommand that is absent from Proton's docs and from `--help`, but present and stable. `PROTON_PASS_NO_UPDATE_CHECK=1` in `dotfiles/zsh/.zshrc` disables its built-in self-updater, which would otherwise try to rewrite the pacman-owned `/usr/bin/pass-cli`
