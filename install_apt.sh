#!/bin/bash

sudo apt update && sudo apt upgrade -y

# essentials (assuming git is installed to clone this repo)
sudo apt install -y git-core curl kdiff3 vim zsh snapd cifs-utils
# docker
sudo apt install -y lsb-release apt-transport-https ca-certificates software-properties-common
