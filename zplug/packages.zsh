# Enhanced cd
zplug "babarot/enhancd", use:init.sh
zplug "babarot/history", use:init.sh
# zplug "babarot/zsh-history-ltsv"
# zplug "zsh-users/zsh-history-substring-search", as:plugin

# Enhanced dir list with git features
zplug "supercrabtree/k"

# Jump back to parent directory
zplug "tarrasch/zsh-bd"

# Directory colors
zplug "seebi/dircolors-solarized", ignore:"*", as:plugin

# Deer file navigator
zplug "vifon/deer", use:deer

# # Load theme
zplug "romkatv/powerlevel10k", use:powerlevel10k.zsh-theme

zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/colorize",          from:oh-my-zsh
zplug "plugins/copypath",          from:oh-my-zsh
zplug "plugins/copyfile",          from:oh-my-zsh
zplug "plugins/cp",                from:oh-my-zsh
zplug "plugins/dircycle",          from:oh-my-zsh
zplug "plugins/extract",           from:oh-my-zsh
zplug "plugins/git",               from:oh-my-zsh, if:"(( $+commands[git] ))"
zplug "plugins/sudo",              from:oh-my-zsh, if:"(( $+commands[sudo] ))"
zplug "plugins/gpg-agent",         from:oh-my-zsh, if:"(( $+commands[gpg-agent] ))"
zplug "plugins/docker",            from:oh-my-zsh, if:"(( $+commands[docker] ))"
zplug "plugins/docker-compose",    from:oh-my-zsh, if:"(( $+commands[docker-compose] ))"
zplug "plugins/httpie",            from:oh-my-zsh, if:"(( #+commands[http] ))"
zplug "lib/clipboard",             from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/macos",             from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

zplug "b4b4r07/httpstat", as:command, use:'(*).sh', rename-to:'$1'
zplug "urbainvaes/fzf-marks"
zplug "so-fancy/diff-so-fancy", as:command, use:diff-so-fancy
zplug "wfxr/forgit"
zplug "aloxaf/fzf-tab", defer:2

zplug "hlissner/zsh-autopair", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions, defer:3"

# zsh-syntax-highlighting must be loaded after executing compinit command
# and sourcing other plugins
zplug "zdharma/fast-syntax-highlighting", defer:3
