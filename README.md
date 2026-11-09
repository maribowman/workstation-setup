# workstation-setup

CachyOS workstation bootstrap. Run on a fresh install:

```bash
curl -fsSL https://raw.githubusercontent.com/maribowman/workstation-setup/main/install/boot.sh | bash
```

This clones the repo to `~/Dev/workstation-setup` and runs the full installer. To install from a
branch other than `main`, pipe into `WS_BRANCH=<branch> bash` instead of `bash`.

The installer is re-entrant (`task install` re-runs it) and pauses once for secrets:

1. **Resilio Sync**: when prompted, open http://127.0.0.1:8888 and add the `credentials` folder
   (folder key from another device) at `~/Sync/credentials`. The installer waits until the
   KeePass vault (`*.kdbx`) has synced.
2. **KeePass**: enter the master password once. `keepassxc-cli` exports the GitHub SSH key
   (`~/.ssh/id_ed25519`), an optional separate NAS key (`~/.ssh/id_nas`) and the restic password
   (`~/.config/restic/password`). Entry names are set at the top of `scripts/secrets.sh` and can
   be overridden via environment variables (`GH_SSH_ENTRY`, `RESTIC_ENTRY`, `NAS_SSH_ENTRY`, ...).
3. With the SSH key in place, the private dotfiles submodule is cloned and stowed. Existing files
   that would block stow (e.g. the default `~/.zshrc`) are moved to `~/.dotfiles-backup/<timestamp>/`.

## What gets installed

| Category   | Tools                                                                                                                 |
| ---------- | --------------------------------------------------------------------------------------------------------------------- |
| Shell      | zsh                                                                                                                   |
| Editor     | neovim                                                                                                                |
| Terminal   | atuin, bat, ghostty, herdr, yazi                                                                                      |
| Dev        | go, uv , docker, lazygit, kubectl, krew, kubelogin, helm, k9s, sofka, hurl, distrobox, pass-cli, nono                 |
| Utilities  | ripgrep, fd, fzf, stow, jq, yq, luarocks                                                                              |
| Evaluation | eza, glow, zoxide                                                                                                     |
| Apps       | brave, keepassxc, vlc, vesktop, tradingview, ledger live, resilio-sync, bambu studio, protonvpn, proton pass, bottles |
| Backup     | restic (NAS), snapper (local BTRFS snapshots)                                                                         |

## Daily maintenance

```bash
task update          # packages + dotfiles + pending migrations
task update-packages # paru (repos + AUR) + flatpak only
task update-dotfiles # pull dotfiles repo and restow all packages
task migrate         # run pending one-off migrations (migrations/*.sh)
task drift           # installed-but-undeclared / declared-but-missing packages
task lint            # shellcheck + verify every declared package exists
task backup          # restic backup to Synology NAS (also runs daily via restic-backup.timer)
task snapshots       # list restic snapshots
```

## Keeping software up to date

Every tool is declared in one of `packages/pacman.txt`, `packages/aur.txt` or
`packages/flatpak.txt`, and `task update` refreshes all three plus the dotfiles. Anything not
available in the official repos or on Flathub is packaged from the AUR rather than dropped in
by hand, so `paru -Syu` stays the single update path and nothing has to be tracked manually.

Tools that ship their own self-updater have it disabled, so it cannot fight the package
manager over a file the package manager owns — see `PROTON_PASS_NO_UPDATE_CHECK` in
`dotfiles/zsh/.zshrc`.

## First-time backup setup

The restic password comes from KeePass (see above). Initialise the repository on the NAS once
before the first backup; afterwards the `restic-backup.timer` systemd user timer backs up daily:

```bash
task backup-init
```

## Dotfiles

Dotfiles live in a private git submodule at `dotfiles/` and are managed with GNU Stow. Each subdirectory is a stow package mirroring the `$HOME` tree:

```
dotfiles/
├── ghostty/.config/ghostty/
├── git/.gitconfig
├── herdr/.config/herdr/
├── k9s/.config/k9s/
└── zsh/.zshrc
```

To add a new dotfile package, create a directory named after the tool with the config files mirroring the `$HOME` tree, then run `task update-dotfiles`. No configuration changes needed — all directories in `dotfiles/` are stowed automatically.
