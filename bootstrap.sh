#!/usr/bin/env zsh

ln -f .zshrc $HOME/.zshrc
ln -f .gitconfig $HOME/.gitconfig

[[ ! -d $HOME/.config ]] && mkdir $HOME/.config
[[ ! -d $HOME/.config/nvim ]] && mkdir $HOME/.config/nvim
ln -f ./.config/nvim/init.vim $HOME/.config/nvim/init.vim
