#!/bin/bash

wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# change default shell
#chsh -s `which zsh`
chsh -s $(which zsh)
# copy and replace config
cp ./dotfiles/.zshrc $(HOME)/
# restart
#sudo shutdown -r 0
