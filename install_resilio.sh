#!/bin/bash

# -> https://help.resilio.com/hc/en-us/articles/206178924-Installing-Sync-package-on-Linux

VERSION="2.7.3.1381-1"
FILENAME="resilio-sync_${VERSION}_amd64.deb"
URL="https://download-cdn.resilio.com/$VERSION/Debian/$FILENAME"
DOWNLOADS="$HOME/Downloads/"

(cd "$DOWNLOADS" && curl -OL $URL) && sudo dpkg -i "$DOWNLOADS/$FILENAME"

# run sync under current user
systemctl --user enable resilio-sync

# default sync service settings
# sudo systemctl enable resilio-sync
# sudo usermod -aG "$(id -gn)" rslsync
# sudo usermod -aG rslsync "$USER"
# sudo chmod g+rw "$HOME/Sync"
