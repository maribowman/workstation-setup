#!/bin/bash

# Setup
install_dir="$HOME/Downloads/manual_installations"
mkdir -p "$install_dir"
cd "$install_dir"

# Download
# K9S
curl --location --remote-name https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb
# Hurl
hurl_version=$(curl -s https://api.github.com/repos/Orange-OpenSource/hurl/releases/latest | jq -r '.tag_name')
curl --location --remote-name "https://github.com/Orange-OpenSource/hurl/releases/download/$hurl_version/hurl_${hurl_version}_amd64.deb"

# Install
sudo apt install ./*.deb

# Clean-up
rm -rf "$install_dir"
