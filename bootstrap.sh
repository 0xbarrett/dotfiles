#!/usr/bin/env zsh
CUR_DIR=`pwd`

[[ ! -d ~/.config ]] && mkdir $HOME/.config

# zsh
ln -sf $CUR_DIR/zsh/.zshrc $HOME/.zshrc
ln -sf $CUR_DIR/zsh/.zsh_aliases $HOME/.zsh_aliases
ln -sf $CUR_DIR/zsh/zlogin.zsh $HOME/.zlogin

# git
ln -sf $CUR_DIR/git/.gitconfig $HOME/.gitconfig
ln -sf $CUR_DIR/git/.gitignore_global $HOME/.gitignore_global

#tig
ln -sf $CUR_DIR/tig/.tigrc $HOME/.tigrc

# vim
[[ ! -d $HOME/.config/nvim ]] && mkdir $HOME/.config/nvim
ln -sf $CUR_DIR/nvim/init.vim $HOME/.config/nvim/init.vim
[[ ! -d $HOME/.SpaceVim.d ]] && mkdir $HOME/.SpaceVim.d
ln -sf $CUR_DIR/spacevim/init.toml $HOME/.SpaceVim.d/init.toml

ln -sf $CUR_DIR/gruvbox_256palette_osx.sh $HOME/.config/
