#!/bin/bash

echo "Starting software update in 15s..."
sleep 15

echo ${SUDO_PWD} | base64 -d | sudo -S apt update 2>/dev/null | tee update.log
sudo apt upgrade -y 2>/dev/null | tee -a update.log
has_updates=false
while IFS= read -r line; do
  if $has_updates; then
    has_updates=false
    sudo apt install -y "$(echo "$line" | xargs echo -n)"
    break
  fi

  if [[ "$line" = *'packages have been kept back'* ]]; then
    has_updates=true
  fi
done <update.log

sudo apt autoremove && sudo apt autoclean
rm update.log

sudo snap refresh
