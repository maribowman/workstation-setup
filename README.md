# workstation-setup

## enable passwordless sudo
- `sudo vim /etc/sudoers`
- add `${username} ALL=(ALL) NOPASSWD: ALL` below the line `includedir /etc/sudoers.d`


## install software
- [git](https://git-scm.com/downloads) (manual installation)
    - `.gitconfig`
- [zsh](https://ohmyz.sh/)
    - `.zshrc`
- [docker](https://www.docker.com/)
- [go](https://go.dev/)
- [snap](https://snapcraft.io/)
    - goland
    - pycharm
    - kubectl
    - helm
    - obsidian
    - httpie
    - k9s
    - keepassxc
    - discord
    - tradingview
    - zoom
- [resilio-sync](https://www.resilio.com/)


## register cron jobs
- `@reboot cron/update.sh` 


## neovim
### install [nerd font](https://www.nerdfonts.com/font-downloads)
```bash
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip \
&& cd ~/.local/share/fonts \
&& unzip JetBrainsMono.zip \
&& rm JetBrainsMono.zip \
&& fc-cache -fv
```

## gnome
### load extensions settings
```bash
dconf load /org/gnome/shell/extensions/ < gnome-extensions.toml
```

### dump extensions settings
```bash
dconf dump /org/gnome/shell/extensions/ > gnome-extensions.toml
```

