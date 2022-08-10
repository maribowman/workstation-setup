#!/bin/bash

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

apt-cache policy docker-ce
sudo apt update && sudo apt install -y docker-ce

# execute docker without sudo
sudo usermod -aG docker $(USER)
su - $(USER)