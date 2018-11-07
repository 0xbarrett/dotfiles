#!/usr/bin/env zsh

[[ ! -d ~/.config ]] && mkdir ~/.config

# zsh
ln -f ./zsh/.zshrc ~/.zshrc
ln -f ./zsh/.zsh_aliases ~/.zsh_aliases
ln -f ./zsh/zlogin.zsh ~/.zlogin

# git
ln -f ./git/.gitconfig ~/.gitconfig
ln -f ./git/.gitignore_global ~/.gitignore_global

#tig
ln -f ./tig/.tigrc ~/.tigrc

# vim
[[ ! -d ~/.config/nvim ]] && mkdir ~/.config/nvim
ln -f ./nvim/init.vim ~/.config/nvim/init.vim
[[ ! -d ~/.SpaceVim.d ]] && mkdir ~/.SpaceVim.d
ln -f ./spacevim/init.toml ~/.SpaceVim.d/init.toml

ln -f ./gruvbox_256palette_osx.sh ~/.config/
