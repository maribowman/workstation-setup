#!/bin/bash

VERSION="2.7.3.1381"
FILENAME="resilio-sync_$VERSION-1_amd64.deb"
URL="https://download-cdn.resilio.com/$VERSION/Debian/$FILENAME"
DOWNLOADS="$HOME/Downloads/"

(cd "$DOWNLOADS" && curl -OL $URL) && sudo dpkg -i "$DOWNLOADS/resilio-sync_2.7.3.1381-1_amd64.deb"

sudo systemctl enable resilio-sync

sudo usermod -aG "$(id -gn)" rslsync
sudo usermod -aG rslsync "$USER"
sudo chmod g+rw "$HOME/Sync"
