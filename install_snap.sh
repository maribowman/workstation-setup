#!/bin/bash
sudo apt update && sudo apt install -y snapd

# TODO test me
sudo snap refresh
sudo snap install goland --classic
sudo snap install helm --classic
sudo snap install kubectl --classic
sudo snap install postman
sudo snap install keepassxc
sudo snap install notion-snap
sudo snap install discord
sudo snap install teams
