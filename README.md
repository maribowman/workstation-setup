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
    - teams
    - tradingview
    - zoom
- azure cli
- [resilio-sync](https://www.resilio.com/)

## register cron jobs
- `@reboot cron/update.sh` 
