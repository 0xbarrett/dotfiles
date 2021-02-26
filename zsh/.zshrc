# =============================================================================
#                                   Functions
# =============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

powerlevel9k_random_color(){
    local code
    #for code ({000..255}) echo -n "$%F{$code}"
    #code=$[${RANDOM}%11+10]    # random between 10-20
    code=$[${RANDOM}%211+20]    # random between 20-230
    printf "%03d" $code
}

zsh_wifi_signal(){
    local signal=$(nmcli -t device wifi | grep '^*' | awk -F':' '{print $6}')
    local color="yellow"
    [[ $signal -gt 75 ]] && color="green"
    [[ $signal -lt 50 ]] && color="red"
    echo -n "%F{$color}\uf1eb" # \uf1eb is 
}

extip() {
    curl ipecho.net/plain; echo
}

function f {
    find . -type f | grep -v .svn | grep -v .git | grep -i $1
}

function fif() {
    find . -type f -name $1 -print0 | xargs -0 grep $2
}

function fi
{
    local pat=${1?'Usage: f ERE-pattern [path...]'}
    shift
    find ${@:-.} \( -path '*/.svn' -o -path '*/.git' -o -path '*/.idea' \) \
        -prune -o -print -follow | grep -iE "$pat"
}

function build() {
    make -f $1 -j8 RELEASE=N DEBUG=Y $2
}

function ndb() {
    npm run build --scripts-prepend-node-path && node --inspect $1
}

function manp() {
    man -t "$@" | open -f -a Preview;
}

function colorgrid() {
    iter=16
    while [ $iter -lt 52 ]
    do
        second=$[$iter+36]
        third=$[$second+36]
        four=$[$third+36]
        five=$[$four+36]
        six=$[$five+36]
        seven=$[$six+36]
        if [ $seven -gt 250 ];then seven=$[$seven-251]; fi

        echo -en "\033[38;5;$(echo $iter)m█ "
        printf "%03d" $iter
        echo -en "   \033[38;5;$(echo $second)m█ "
        printf "%03d" $second
        echo -en "   \033[38;5;$(echo $third)m█ "
        printf "%03d" $third
        echo -en "   \033[38;5;$(echo $four)m█ "
        printf "%03d" $four
        echo -en "   \033[38;5;$(echo $five)m█ "
        printf "%03d" $five
        echo -en "   \033[38;5;$(echo $six)m█ "
        printf "%03d" $six
        echo -en "   \033[38;5;$(echo $seven)m█ "
        printf "%03d" $seven

        iter=$[$iter+1]
        printf '\r\n'
    done
}

# Create a new directory and enter it
function mcd() {
  mkdir -p "$@" && cd "$_";
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
  local tmpFile="${@%/}.tar";
  tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

  size=$(
    stat -f"%z" "${tmpFile}" 2> /dev/null; # macOS `stat`
    stat -c"%s" "${tmpFile}" 2> /dev/null;  # GNU `stat`
  );

  local cmd="";
  if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
    # the .tar file is smaller than 50 MB and Zopfli is available; use it
    cmd="zopfli";
  else
    if hash pigz 2> /dev/null; then
      cmd="pigz";
    else
      cmd="gzip";
    fi;
  fi;

  echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
  "${cmd}" -v "${tmpFile}" || return 1;
  [ -f "${tmpFile}" ] && rm "${tmpFile}";

  zippedSize=$(
    stat -f"%z" "${tmpFile}.gz" 2> /dev/null; # macOS `stat`
    stat -c"%s" "${tmpFile}.gz" 2> /dev/null; # GNU `stat`
  );

  echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}

# Determine size of a file or total size of a directory
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* ./*;
  fi;
}

function git-fatfiles() {
  git rev-list --all --objects | \
    sed -n $(git rev-list --objects --all | \
    cut -f1 -d' ' | \
    git cat-file --batch-check | \
    grep blob | \
    sort -n -k 3 | \
    tail -n40 | \
    while read hash type size; do
         echo -n "-e s/$hash/$size/p ";
    done) | \
    sort -n -k1
}

# =============================================================================
#                                   Variables
# =============================================================================
[[ -e /usr/libexec/java_home ]] && export JAVA_HOME="$(/usr/libexec/java_home)"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export FZF_DEFAULT_OPTS='--height 40% --reverse --border --inline-info --color=dark,bg+:235,hl+:10,pointer:5'
export FZF_DEFAULT_COMMAND='fd --type f --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export CLICOLOR="YES" # Equivalent to passing -G to ls.
export LSCOLORS="exgxdHdHcxaHaHhBhDeaec"
export HUB_PROTOCOL=https
export BAT_THEME="1337"
export GOPATH="$HOME/go"
export XDG_CONFIG_HOME="$HOME/.config"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='nano'
else
    export EDITOR='micro'
fi

export GIT_EDITOR=$EDITOR

# =============================================================================
#                                   Plugins
# =============================================================================
# Check if zplug is installed
[ ! -d ~/.zplug ] && git clone https://github.com/zplug/zplug ~/.zplug
source ~/.zplug/init.zsh

# zplug
# zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Miscellaneous commands
zplug "k4rthik/git-cal",  as:command
zplug "peco/peco",        as:command, from:gh-r
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf, \
    use:"*${(L)$(uname -s)}*amd64*"
zplug "junegunn/fzf", use:"shell/*.zsh", as:plugin

# Enhanced cd
zplug "b4b4r07/enhancd", use:init.sh

# Enhanced dir list with git features
zplug "supercrabtree/k"

# Jump back to parent directory
zplug "tarrasch/zsh-bd"

# Simple zsh calculator
zplug "arzzen/calc.plugin.zsh"

# Directory colors
zplug "seebi/dircolors-solarized", ignore:"*", as:plugin

# Deer file navigator
zplug "vifon/deer", use:deer

# Load theme
#zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
zplug "romkatv/powerlevel10k", use:powerlevel10k.zsh-theme

zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/colorize",          from:oh-my-zsh
zplug "plugins/copydir",           from:oh-my-zsh
zplug "plugins/copyfile",          from:oh-my-zsh
zplug "plugins/cp",                from:oh-my-zsh
zplug "plugins/dircycle",          from:oh-my-zsh
zplug "plugins/extract",           from:oh-my-zsh
zplug "plugins/history",           from:oh-my-zsh
zplug "plugins/git",               from:oh-my-zsh, if:"(( $+commands[git] ))"
zplug "plugins/sudo",              from:oh-my-zsh, if:"(( $+commands[sudo] ))"
zplug "plugins/gpg-agent",         from:oh-my-zsh, if:"(( $+commands[gpg-agent] ))"
zplug "plugins/docker",            from:oh-my-zsh, if:"(( $+commands[docker] ))"
zplug "plugins/docker-compose",    from:oh-my-zsh, if:"(( $+commands[docker-compose] ))"
zplug "plugins/httpie",            from:oh-my-zsh, if:"(( #+commands[http] ))"
zplug "lib/clipboard",         from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/osx",           from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

zplug "MichaelAquilina/zsh-emojis"
zplug "b4b4r07/httpstat", as:command, use:'(*).sh', rename-to:'$1'
zplug "urbainvaes/fzf-marks"
zplug "wfxr/forgit"
zplug "aloxaf/fzf-tab", at:b2aae4cc

zplug "hlissner/zsh-autopair", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"

zplug "zdharma/history-search-multi-word"

# zsh-syntax-highlighting must be loaded after executing compinit command
# and sourcing other plugins
zplug "zdharma/fast-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3

# =============================================================================
#                                   Options
# =============================================================================

export LESS="--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSOPEN="| bat %s 2>/dev/null" # Use `bat` to highlight files.

# Disable dumb indentation of right prompt
ZLE_RPROMPT_INDENT=0

# Set the max number of open files to 1024
ulimit -S -n 1024

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

setopt autocd                   # Allow changing directories without `cd`
setopt append_history           # Dont overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt share_history            # Share history between multiple shells
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_all_dups     # Remember only one unique copy of the command.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.
setopt hist_ignore_space        # Ignore commands that start with space.
setopt brace_ccl                # Make {a-c} expand to a b c

# Changing directories
setopt auto_pushd
setopt pushd_ignore_dups        # Dont push copies of the same dir on stack.
setopt pushd_minus              # Reference stack entries with "-".

setopt long_list_jobs
setopt extended_glob

setopt notify	                  # Report the status of backgrounds jobs immediately

# =============================================================================
#                                   Keybindings
# =============================================================================

bindkey "^[[3~" delete-char

# =============================================================================
#                                   Aliases
# =============================================================================

# Generic command adaptations
alias grep='() { $(whence -p grep) --color=auto $@ }'
alias egrep='() { $(whence -p egrep) --color=auto $@ }'
alias vim='NVIM_TUI_ENABLE_TRUE_COLOR=1 nvim'
alias upgrayedd='brew upgrade'

# Custom helper aliases
alias cp="cp -iv"
alias mv="mv -iv"
alias which="type -a"
alias cx="chmod +x"
alias make="make -j$(nproc)"
alias dmake="dmake -j$(nproc)"
alias please='sudo $(fc -ln -1)'
alias plz=please
alias cls="colorls"
alias clsa="colorls -al"
alias tiga="tig --all"
alias tm="tmux -2"
alias help="run-help"
alias tre="br"

# Remove .DS_Store files from current directory, recursively
alias rmds="find . -name '*.DS_Store' -type f -delete"

# Additional git aliases
alias gsup="git sup"
alias gbcu="git trim"
alias gbcup="gbcu"
alias gt="git tree"
alias gdtl="git difftool --no-prompt"
alias gprl="hub pr list --state=all --limit=10 -f \"%sC%>(8)%i%Creset %<(40)%t %Cyellow$(print "\ue725") %<(35)%H %Cblue%U%n\""
alias gprls="hub pr list --state=all --limit=10 -f \"%sC%>(8)%i%Creset $(print "\ue725") %<(50)%t %Cblue%U%n\""
alias gprc="hub pull-request -o -c"
alias gre="git recent"
alias gmpr="git mpr"
alias gpc="git print-commit"
alias gstt="git status --ignore-submodules"
alias gclean="git clean -fd"
alias grst="git restore"
alias grsts="git restore --staged"

alias src='source ~/.zshrc'
alias wch='type -a'

# ls stuff
if (( $+commands[lsd] )); then
  alias ls='lsd -F --group-dirs first'
elif (( $+commands[gls] )); then
  alias ls='gls -F --color --group-directories-first'
else
  alias ls='ls --color=auto --group-directories-first'
fi

alias lal='ls -al'
alias lla='ls -lAF'        # Show hidden all files
alias ll='ls -lF'          # Show long file information
alias la='ls -lAFh'        # #long list,show almost all,show type,human readable
alias lx='ls -lXB'         # Sort by extension
alias lk='ls -lSr'         # Sort by size, biggest last
alias lc='ls -ltcr'        # Sort by and show change time, most recent last
alias lu='ls -ltur'        # Sort by and show access time, most recent last
alias lt='ls -ltr'         # Sort by date, most recent last
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less' # Full recursive directory listing

alias d='dirs -v'
alias 1='pu'
alias 2='pu -2'
alias 3='pu -3'
alias 4='pu -4'
alias 5='pu -5'
alias 6='pu -6'
alias 7='pu -7'
alias 8='pu -8'
alias 9='pu -9'
alias pu='() { pushd $1 &> /dev/null; dirs -v; }'
alias po='() { popd &> /dev/null; dirs -v; }'

zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

# =============================================================================
#                                 Completions
# =============================================================================

zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' menu select # Use completion menu for completion when available.
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

# case-insensitive (all), partial-word and then substring completion
zstyle ":completion:*" matcher-list \
  "m:{a-zA-Z}={A-Za-z}" \
  "r:|[._-]=* r:|=*" \
  "l:|=* r:|=*"

zstyle ":completion:*:default" list-colors ${(s.:.)LS_COLORS}

# =============================================================================
#                                   Startup
# =============================================================================

# Install plugins if there are plugins that have not been installed
if ! zplug check; then
    printf "Install plugins? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

if zplug check "seebi/dircolors-solarized"; then
  which gdircolors &> /dev/null && alias dircolors='() { $(whence -p gdircolors) }'
  which dircolors &> /dev/null && \
      eval $(dircolors ~/.zplug/repos/seebi/dircolors-solarized/dircolors.256dark)
fi

if zplug check "zsh-users/zsh-history-substring-search"; then
    zmodload zsh/terminfo
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
    bindkey "^[[1;5A" history-substring-search-up
    bindkey "^[[1;5B" history-substring-search-down
fi

if zplug check "zsh-users/zsh-syntax-highlighting"; then
    #ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line)
    ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')

    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[cursor]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[globbing]='none'
    ZSH_HIGHLIGHT_STYLES[path]='fg=white'
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=grey'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[command]='fg=green'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=green'
    ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=cyan,bold'
    ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
    ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'
    ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow,bold'
fi

if zplug check "b4b4r07/enhancd"; then
    ENHANCD_FILTER="fzf:peco:percol"
    ENHANCD_COMMAND='cd'
    ENHANCD_DOT_SHOW_FULLPATH=0
    ENHANCD_DOT_ARG='...'
    ENHANCD_HYPHEN_ARG='--'
fi

if zplug check "b4b4r07/zsh-history-enhanced"; then
    ZSH_HISTORY_FILE="$HISTFILE"
    ZSH_HISTORY_FILTER="fzf:peco:percol"
    ZSH_HISTORY_KEYBIND_GET_BY_DIR="^r"
    ZSH_HISTORY_KEYBIND_GET_ALL="^r^a"
fi

if zplug check "vifon/deer"; then
    zle -N deer
    bindkey '\ek' deer
fi

if zplug check "zsh-users/zsh-autosuggestions"; then
    bindkey '^ ' autosuggest-accept
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

if zplug check "junegunn/fzf"; then
# Use fd for listing path candidates
  _fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}
fi

if zplug check "wfxr/forgit"; then
    forgit_log=gli
    forgit_diff=gdi
    forgit_add=gai
    forgit_ignore=gii
    forgit_checkout_file=gri
    forgit_clean=gci
    forgit_stash_show=gsti
    forgit_reset_head=guni
fi

if zplug check "romkatv/powerlevel10k"; then
  [[ -f ~/.config/p10k/.p10k.zsh ]] && source ~/.config/p10k/.p10k.zsh
fi

fpath=(/usr/local/share/zsh-completions $fpath)

# Then, source plugins and add commands to $PATH
zplug load

# Gruvbox colors
[[ -f ~/.config/gruvbox_256palette_osx.sh ]] && source ~/.config/gruvbox_256palette_osx.sh

# Source defined functions.
[[ -f ~/.zsh_functions ]] && source ~/.zsh_functions

# Source local customizations.
[[ -f ~/.zsh_rclocal ]] && source ~/.zsh_rclocal

# Source exports and aliases.
[[ -f ~/.zsh_exports ]] && source ~/.zsh_exports
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# Add junk to path that I probably don't need
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
[[ -d "/Applications/Araxis\ Merge.app/Contents/Utilities" ]] && export PATH="/Applications/Araxis\ Merge.app/Contents/Utilities:$PATH"
[[ -d "$HOME/Library/Android/sdk/platform-tools" ]] && export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
[[ -d "/usr/local/opt/go/libexec/bin" ]] && export PATH="$PATH:/usr/local/opt/go/libexec/bin"
[[ -d "$HOME/go/bin" ]] && export PATH="$PATH:$HOME/go/bin"
[[ -d "/usr/local/sbin" ]] && export PATH="$PATH:/usr/local/sbin"
[[ -d "/home/linuxbrew/.linuxbrew/bin" ]] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$PATH:$HOME/.local/bin"
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Load asdf
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# Other things
[[ -f ~/Library/Preferences/org.dystroy.broot/launcher/bash/br ]] && source ~/Library/Preferences/org.dystroy.broot/launcher/bash/br
[[ -e "/home/linuxbrew/.linuxbrew/bin/brew" ]] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# Remove duplicate entries in PATH
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

# Remove dumb alias of run-help to man and replace with useful run-help for builtins
autoload run-help
