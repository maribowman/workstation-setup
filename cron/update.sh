#!/bin/bash

echo "Starting software update in 15s..."
rm update.log update_copy.log
sleep 15

echo {SUDO_PWD} | base64 -d | sudo -S apt update 2>&1 | tee update.log &
wait
sudo apt upgrade -y 2>&1 | tee -a update.log &
wait

has_updates=false
cp update.log update_copy.log

while IFS= read -r line; do
  if $has_updates; then
    has_updates=false
    sudo apt install -y $(echo "$line" | xargs echo -n) 2>&1 | tee -a update.log &
    wait
    break
  fi

  if [[ "$line" = *'packages have been kept back'* ]]; then
    has_updates=true
  fi
done <update_copy.log
rm update_copy.log

sudo apt autoremove | tee -a update.log && sudo apt autoclean | tee -a update.log

sudo snap refresh | tee -a update.log
