#!/bin/bash

sudo apt update && sudo apt upgrade -y

# essentials (assuming git is installed to clone this repo)
sudo apt install -y git-core curl kdiff3 vim zsh snapd cifs-utils
