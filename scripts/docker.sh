#!/bin/bash
set -eEo pipefail

echo "==> Configuring Docker..."

sudo systemctl enable --now docker

if ! groups "$USER" | grep -q docker; then
  sudo usermod -aG docker "$USER"
  echo "==> Added $USER to docker group (re-login required for effect)"
fi
