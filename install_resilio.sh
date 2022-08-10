#!/bin/bash
# https://www.resilio.com/blog/official-linux-packages-for-sync-now-available

deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free
wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add -

sudo apt update && sudo apt install -y resilio-sync
sudo systemctl enable resilio-sync