# workstation-setup

CachyOS workstation bootstrap. Run on a fresh install:

```bash
curl -fsSL https://raw.githubusercontent.com/maribowman/workstation-setup/main/install/boot.sh | bash
```

This clones the repo to `~/Dev/workstation-setup`, initialises the dotfiles submodule, and runs the full installer.

## What gets installed

| Category | Tools |
|---|---|
| Shell | zsh |
| Editor | neovim |
| Terminal | alacritty, zellij, tmux |
| Dev | go, uv (Python), docker, lazygit, kubectl, helm, k9s, hurl, distrobox |
| Utilities | ripgrep, fd, fzf, stow, jq, luarocks |
| Apps | brave, keepassxc, vlc, vesktop, tradingview, ledger live, resilio-sync, bambu studio, protonvpn, proton pass, bottles |
| Backup | restic (NAS), snapper (local BTRFS snapshots) |

## Daily maintenance

```bash
task update          # update all packages + dotfiles
task update-packages # pacman + paru + flatpak only
task update-dotfiles # pull dotfiles repo and restow all packages
task backup          # restic backup to Synology NAS
```

## First-time backup setup

Initialise the restic repository on the NAS once before the first backup:

```bash
task backup-init
```

## Dotfiles

Dotfiles live in a private git submodule at `dotfiles/` and are managed with GNU Stow. Each subdirectory is a stow package mirroring the `$HOME` tree:

```
dotfiles/
├── alacritty/.config/alacritty/
├── git/.gitconfig
├── k9s/.config/k9s/
├── zellij/.config/zellij/
└── zsh/.zshrc
```

To add a new dotfile package, create a directory named after the tool with the config files mirroring the `$HOME` tree, then run `task update-dotfiles`. No configuration changes needed — all directories in `dotfiles/` are stowed automatically.
