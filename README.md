# workstation-setup

CachyOS workstation bootstrap. Run on a fresh install:

```bash
curl -fsSL https://raw.githubusercontent.com/maribowman/workstation-setup/main/install/boot.sh | bash
```

This clones the repo to `~/Dev/workstation-setup`, initialises the dotfiles submodule, and runs the full installer.

## What gets installed

| Category   | Tools                                                                                                                 |
| ---------- | --------------------------------------------------------------------------------------------------------------------- |
| Shell      | zsh                                                                                                                   |
| Editor     | neovim                                                                                                                |
| Terminal   | atuin, bat, ghostty, herdr, yazi                                                                                      |
| Dev        | go, uv , docker, lazygit, kubectl, helm, k9s, hurl, distrobox, pass-cli                                               |
| Utilities  | ripgrep, fd, fzf, stow, jq, yq, luarocks                                                                              |
| Evaluation | eza, glow, zoxide                                                                                                     |
| Apps       | brave, keepassxc, vlc, vesktop, tradingview, ledger live, resilio-sync, bambu studio, protonvpn, proton pass, bottles |
| Backup     | restic (NAS), snapper (local BTRFS snapshots)                                                                         |

## Daily maintenance

```bash
task update          # update all packages + dotfiles
task update-packages # pacman + paru + flatpak only
task update-dotfiles # pull dotfiles repo and restow all packages
task backup          # restic backup to Synology NAS
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

Initialise the restic repository on the NAS once before the first backup:

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
