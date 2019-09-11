#!/usr/bin/env zsh
CUR_DIR=`pwd`

[[ ! -d $HOME/.config ]] && mkdir $HOME/.config
[[ ! -d $HOME/.config/colorls ]] && mkdir $HOME/.config/colorls
[[ ! -d $HOME/.config/nvim ]] && mkdir $HOME/.config/nvim
[[ ! -d $HOME/.SpaceVim.d ]] && mkdir $HOME/.SpaceVim.d
[[ ! -d $HOME/.history ]] && mkdir $HOME/.history
[[ ! -d $HOME/.config/p10k ]] && mkdir $HOME/.config/p10k

# zsh
ln -sf $CUR_DIR/zsh/.zshrc $HOME/.zshrc
ln -sf $CUR_DIR/zsh/.zsh_aliases $HOME/.zsh_aliases
ln -sf $CUR_DIR/zsh/zlogin.zsh $HOME/.zlogin
ln -sf $CUR_DIR/zsh/.p10k.zsh $HOME/.config/p10k/.p10k.zsh

# git
ln -sf $CUR_DIR/git/.gitconfig $HOME/.gitconfig
ln -sf $CUR_DIR/git/.gitignore_global $HOME/.gitignore_global

# tig
ln -sf $CUR_DIR/tig/.tigrc $HOME/.tigrc

# vim
ln -sf $CUR_DIR/nvim/init.vim $HOME/.config/nvim/init.vim
ln -sf $CUR_DIR/spacevim/init.toml $HOME/.SpaceVim.d/init.toml

# ruby
ln -sf $CUR_DIR/ruby/irbrc $HOME/.irbrc

# asdf
ln -sf $CUR_DIR/asdf/.default-gems $HOME/.default-gems
ln -sf $CUR_DIR/asdf/.default-npm-packages $HOME/.default-npm-packages
ln -sf $CUR_DIR/asdf/.default-python-packages $HOME/.default-python-packages

#other
ln -sf $CUR_DIR/gruvbox_256palette_osx.sh $HOME/.config/
ln -sf $CUR_DIR/colorls/dark_colors.yaml $HOME/.config/colorls/dark_colors.yaml
