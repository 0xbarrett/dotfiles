#!/usr/bin/env zsh

[[ ! -d $HOME/.config ]] && mkdir $HOME/.config
[[ ! -d $HOME/.config/colorls ]] && mkdir $HOME/.config/colorls
[[ ! -d $HOME/.config/p10k ]] && mkdir $HOME/.config/p10k

# zsh
ln -sf $PWD/zsh/.zshrc $HOME/.zshrc
ln -sf $PWD/zsh/.zsh_aliases $HOME/.zsh_aliases
ln -sf $PWD/zsh/zlogin.zsh $HOME/.zlogin
ln -sf $PWD/zsh/.p10k.zsh $HOME/.config/p10k/.p10k.zsh

# zplug
[ ! -d ~/.zplug ] && git clone https://github.com/zplug/zplug ~/.zplug
ln -sf $PWD/zplug/packages.zsh ~/.zplug_packages.zsh

# git
ln -sf $PWD/git/.gitconfig $HOME/.gitconfig
ln -sf $PWD/git/.gitignore_global $HOME/.gitignore_global

# tig
ln -sf $PWD/tig/.tigrc $HOME/.tigrc

# ruby
ln -sf $PWD/ruby/irbrc $HOME/.irbrc

# asdf
ln -sf $PWD/asdf/.default-gems $HOME/.default-gems
ln -sf $PWD/asdf/.default-npm-packages $HOME/.default-npm-packages
ln -sf $PWD/asdf/.default-python-packages $HOME/.default-python-packages

#other
ln -sf $PWD/gruvbox_256palette_osx.sh $HOME/.config/
ln -sf $PWD/colorls/dark_colors.yaml $HOME/.config/colorls/dark_colors.yaml
ln -sf $PWD/imgcat $HOME/.local/bin/imgcat

if [[ $(uname) == "Linux" ]]; then
  sudo apt install fd-find bat
  sudo ln -sf /usr/bin/batcat /usr/bin/bat
else
  brew install fd bat
fi
