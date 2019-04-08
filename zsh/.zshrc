export TERM="xterm-256color"

# =============================================================================
#                                   Functions
# =============================================================================
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

# =============================================================================
#                                   Variables
# =============================================================================
[[ -e /usr/libexec/java_home ]] && export JAVA_HOME="$(/usr/libexec/java_home)"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export FZF_DEFAULT_OPTS='--height 40% --reverse --border --inline-info --color=dark,bg+:235,hl+:10,pointer:5'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export CLICOLOR="YES" # Equivalent to passing -G to ls.
export LSCOLORS="exgxdHdHcxaHaHhBhDeaec"
export ENHANCD_FILTER="fzf:peco:percol"
export ENHANCD_COMMAND='c'
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
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Miscellaneous commands
zplug "k4rthik/git-cal",  as:command
zplug "peco/peco",        as:command, from:gh-r
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf, \
    use:"*${(L)$(uname -s)}*amd64*"
zplug "junegunn/fzf", use:"shell/*.zsh", as:plugin

# Enhanced cd
#zplug "b4b4r07/enhancd", use:init.sh

# Bookmarks and jump
#zplug "jocelynmallon/zshmarks"

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
zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
#zplug "romkatv/powerlevel10k", use:powerlevel10k.zsh-theme

#zplug "plugins/common-aliases",    from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/colorize",          from:oh-my-zsh
#zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/copydir",           from:oh-my-zsh
zplug "plugins/copyfile",          from:oh-my-zsh
zplug "plugins/cp",                from:oh-my-zsh
zplug "plugins/dircycle",          from:oh-my-zsh
#zplug "plugins/encode64",          from:oh-my-zsh
zplug "plugins/extract",           from:oh-my-zsh
zplug "plugins/history",           from:oh-my-zsh
#zplug "plugins/tmux",              from:oh-my-zsh
#zplug "plugins/tmuxinator",        from:oh-my-zsh
#zplug "plugins/urltools",          from:oh-my-zsh
#zplug "plugins/web-search",        from:oh-my-zsh
#zplug "plugins/z",                 from:oh-my-zsh
#zplug "plugins/fancy-ctrl-z",      from:oh-my-zsh
zplug "MichaelAquilina/zsh-emojis"
zplug "b4b4r07/httpstat", as:command, use:'(*).sh', rename-to:'$1'
zplug "caarlos0/open-pr"
zplug "MikeDacre/careful_rm"
zplug "urbainvaes/fzf-marks"

if [[ $OSTYPE = (darwin)* ]]; then
    zplug "lib/clipboard",         from:oh-my-zsh
    zplug "plugins/osx",           from:oh-my-zsh
    #zplug "plugins/brew",          from:oh-my-zsh, if:"(( $+commands[brew] ))"
fi

zplug "plugins/git",               from:oh-my-zsh, if:"(( $+commands[git] ))"
zplug "wfxr/forgit"
#zplug "plugins/golang",            from:oh-my-zsh, if:"(( $+commands[go] ))"
#zplug "plugins/svn",               from:oh-my-zsh, if:"(( $+commands[svn] ))"
#zplug "plugins/node",              from:oh-my-zsh, if:"(( $+commands[node] ))"
#zplug "plugins/npm",               from:oh-my-zsh, if:"(( $+commands[npm] ))"
#zplug "plugins/bundler",           from:oh-my-zsh, if:"(( $+commands[bundler] ))"
#zplug "plugins/gem",               from:oh-my-zsh, if:"(( $+commands[gem] ))"
#zplug "plugins/rbenv",             from:oh-my-zsh, if:"(( $+commands[rbenv] ))"
#zplug "plugins/rvm",               from:oh-my-zsh, if:"(( $+commands[rvm] ))"
#zplug "plugins/pip",               from:oh-my-zsh, if:"(( $+commands[pip] ))"
zplug "plugins/sudo",              from:oh-my-zsh, if:"(( $+commands[sudo] ))"
zplug "plugins/gpg-agent",         from:oh-my-zsh, if:"(( $+commands[gpg-agent] ))"
#zplug "plugins/systemd",           from:oh-my-zsh, if:"(( $+commands[systemctl] ))"
#zplug "plugins/docker",            from:oh-my-zsh, if:"(( $+commands[docker] ))"
#zplug "plugins/docker-compose",    from:oh-my-zsh, if:"(( $+commands[docker-compose] ))"

zplug "hlissner/zsh-autopair", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"

# zsh-syntax-highlighting must be loaded after executing compinit command
# and sourcing other plugins
#zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zdharma/fast-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3

# =============================================================================
#                                   Options
# =============================================================================

export LESS="--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSOPEN="| bat %s 2>/dev/null" # Use `bat` to highlight files.

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

# Custom helper aliases
alias cp="cp -iv"
alias mv="mv -iv"
alias which="type -a"
alias cx="chmod +x"
alias make="make -j8"
alias please='sudo $(fc -ln -1)'
alias plz=please
alias cls="colorls"
alias clsa="colorls -al"
alias tiga="tig --all"
alias tm="tmux -2"

# Remove .DS_Store files from current directory, recursively
alias rmds="find . -name '*.DS_Store' -type f -delete"

# Additional git aliases
alias gsup="git sup"
alias gbcu="git bcu"
alias gbcup="gbcu"
alias gtree="git tree"
alias gdtl="git difftool --no-prompt"
alias gprl="hub pr list --state=all --limit=10 -f \"%sC%>(8)%i%Creset %<(40)%t %Cyellow$(print "\ue725") %<(35)%H %Cblue%U%n\""
alias gprls="hub pr list --state=all --limit=10 -f \"%sC%>(8)%i%Creset $(print "\ue725") %<(50)%t %Cblue%U%n\""
alias gprc="hub pull-request -o -c"
alias gre="git recent"
alias gmpr="git mpr"
alias gpc="git print-commit"

alias src='source ~/.zshrc'
alias wch='type -a'

# ls stuff
if (( $+commands[gls] )); then
  alias ls='gls -F --color --group-directories-first'
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
#zstyle ':completion:*' verbose yes
#zstyle ':completion:*:descriptions' format '%B%d%b'
#zstyle ':completion:*:messages' format '%d'
#zstyle ':completion:*:warnings' format 'No matches for: %d'
#zstyle ':completion:*' group-name ''

# case-insensitive (all), partial-word and then substring completion
zstyle ":completion:*" matcher-list \
  "m:{a-zA-Z}={A-Za-z}" \
  "r:|[._-]=* r:|=*" \
  "l:|=* r:|=*"

zstyle ":completion:*:default" list-colors ${(s.:.)LS_COLORS}

# =============================================================================
#                                   Startup
# =============================================================================

# Load SSH and GPG agents via keychain.
setup_agents() {
  [[ $UID -eq 0 ]] && return

  if (( $+commands[keychain] )); then
    local -a ssh_keys gpg_keys
    for i in ~/.ssh/**/*pub; do test -f "$i(.N:r)" && ssh_keys+=("$i(.N:r)"); done
    gpg_keys=$(gpg -K --with-colons 2>/dev/null | awk -F : '$1 == "sec" { print $5 }')
    if (( $#ssh_keys > 0 )) || (( $#gpg_keys > 0 )); then
      alias run_agents='() { $(whence -p keychain) --quiet --eval --inherit any-once --agents ssh,gpg $ssh_keys ${(f)gpg_keys} }'
      #[[ -t ${fd:-0} || -p /dev/stdin ]] && eval `run_agents`
      unalias run_agents
    fi
  fi
}

#setup_agents
#unfunction setup_agents

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
    ENHANCD_DOT_SHOW_FULLPATH=1
    ENHANCD_DISABLE_HOME=0
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

if zplug check "wfxr/forgit"; then
    forgit_log=gli
    forgit_diff=gdi
    forgit_add=gai
    forgit_ignore=gii
    forgit_restore=
    forgit_clean=gci
    forgit_stash_show=gsti
fi

if zplug check "bhilburn/powerlevel9k"; then
    #gruvbox colors
    GRUVBOX_FG0=229
    GRUVBOX_FG1=223
    GRUVBOX_FG2=250
    GRUVBOX_FG3=248
    GRUVBOX_FG4=246
    GRUVBOX_BG0=235
    GRUVBOX_BG1=237
    GRUVBOX_BG2=239
    GRUVBOX_BG3=241
    GRUVBOX_BG4=243
    GRUVBOX_BG0_S=236

    # Easily switch primary foreground/background colors
    DEFAULT_FOREGROUND=$GRUVBOX_FG1
    DEFAULT_BACKGROUND=$GRUVBOX_BG0
    DEFAULT_ACCENT=$GRUVBOX_FG2
    DEFAULT_COLOR=$DEFAULT_FOREGROUND

    # powerlevel9k prompt theme
    #DEFAULT_USER=$USER

    POWERLEVEL9K_MODE="nerdfont-complete"
    #POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
    #POWERLEVEL9K_SHORTEN_STRATEGY="truncate_right"

    POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=false

    POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
    POWERLEVEL9K_ALWAYS_SHOW_USER=false

    POWERLEVEL9K_CONTEXT_TEMPLATE="\uF109 %u"

    POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND="$DEFAULT_BACKGROUND"

    POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR="\uE0B4"
    POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR="%F{$(( $DEFAULT_BACKGROUND - 2 ))}|%f"
    POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR="\uE0B6"
    POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR="%F{$(( $DEFAULT_BACKGROUND - 2 ))}|%f"

    POWERLEVEL9K_PROMPT_ON_NEWLINE=true
    POWERLEVEL9K_RPROMPT_ON_NEWLINE=false

    POWERLEVEL9K_STATUS_VERBOSE=true
    POWERLEVEL9K_STATUS_CROSS=true
    POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

    CONNECTOR_COLOR=$GRUVBOX_FG1
    FIRST_ARROW_COLOR=$GRUVBOX_FG1
    SECOND_ARROW_COLOR=$GRUVBOX_FG3
    THIRD_ARROW_COLOR=$GRUVBOX_FG4

    POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{CONNECTOR_COLOR}\u256D\u2500%f"
    POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{CONNECTOR_COLOR}\u2570%F{$FIRST_ARROW_COLOR}\uF0DA%F{$SECOND_ARROW_COLOR}\uF0DA%F{$THIRD_ARROW_COLOR}\uF0DA%f "

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(host root_indicator dir_writable dir vcs)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time background_jobs status)

    POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY=false

    POWERLEVEL9K_VCS_CLEAN_BACKGROUND="green"
    POWERLEVEL9K_VCS_CLEAN_FOREGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_VCS_MODIFIED_BACKGROUND="yellow"
    POWERLEVEL9K_VCS_MODIFIED_FOREGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND="magenta"
    POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND="$DEFAULT_BACKGROUND"

    POWERLEVEL9K_DIR_HOME_BACKGROUND="$GRUVBOX_FG2"
    POWERLEVEL9K_DIR_HOME_FOREGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND="$GRUVBOX_FG2"
    POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_DIR_DEFAULT_BACKGROUND="$GRUVBOX_FG2"
    POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_BACKGROUND="$GRUVBOX_FG2"
    POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND="$DEFAULT_BACKGROUND"

    POWERLEVEL9K_STATUS_OK_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_STATUS_OK_FOREGROUND="green"
    POWERLEVEL9K_STATUS_OK_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_STATUS_OK_BACKGROUND="$(( $DEFAULT_BACKGROUND + 3 ))"

    POWERLEVEL9K_STATUS_ERROR_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_STATUS_ERROR_FOREGROUND="red"
    POWERLEVEL9K_STATUS_ERROR_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_STATUS_ERROR_BACKGROUND="$(( $DEFAULT_BACKGROUND + 3 ))"

    POWERLEVEL9K_HISTORY_FOREGROUND="$DEFAULT_FOREGROUND"

    POWERLEVEL9K_TIME_FORMAT="%D{%T}"
    POWERLEVEL9K_TIME_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_TIME_BACKGROUND="$DEFAULT_BACKGROUND"

    POWERLEVEL9K_VCS_GIT_GITHUB_ICON=""
    #POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON=""
    #POWERLEVEL9K_VCS_GIT_GITLAB_ICON=""
    POWERLEVEL9K_VCS_GIT_ICON=""

    POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND="$(( $DEFAULT_BACKGROUND + 5 ))"
    POWERLEVEL9K_EXECUTION_TIME_ICON="\uF253"

    POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
    #POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0

    POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND="$DEFAULT_FOREGROUND"

    POWERLEVEL9K_USER_ICON="\uF415"
    POWERLEVEL9K_USER_DEFAULT_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_USER_DEFAULT_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_USER_ROOT_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_USER_ROOT_BACKGROUND="$DEFAULT_BACKGROUND"

    POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND="magenta"
    POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND="$(( $DEFAULT_BACKGROUND + 2 ))"
    POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND="$(( $DEFAULT_BACKGROUND - 2 ))"
    POWERLEVEL9K_ROOT_ICON=$'\uF198'

    POWERLEVEL9K_SSH_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_SSH_FOREGROUND="yellow"
    POWERLEVEL9K_SSH_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_SSH_BACKGROUND="$(( $DEFAULT_BACKGROUND + 2 ))"
    POWERLEVEL9K_SSH_BACKGROUND="$(( $DEFAULT_BACKGROUND - 2 ))"
    POWERLEVEL9K_SSH_ICON="\uF489"

    POWERLEVEL9K_HOST_LOCAL_FOREGROUND="$GRUVBOX_FG2"
    POWERLEVEL9K_HOST_LOCAL_BACKGROUND="$GRUVBOX_BG0"
    POWERLEVEL9K_HOST_REMOTE_FOREGROUND="$GRUVBOX_FG2"
    POWERLEVEL9K_HOST_REMOTE_BACKGROUND="$GRUVBOX_BG0"

    POWERLEVEL9K_HOST_ICON="\uF197"
    #POWERLEVEL9K_HOST_ICON="\uf6f5"
    POWERLEVEL9K_HOST_TEMPLATE=""

    POWERLEVEL9K_OS_ICON_FOREGROUND="$DEFAULT_FOREGROUND"
    POWERLEVEL9K_OS_ICON_BACKGROUND="$DEFAULT_BACKGROUND"

    POWERLEVEL9K_LOAD_CRITICAL_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_LOAD_WARNING_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_LOAD_NORMAL_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND="red"
    POWERLEVEL9K_LOAD_WARNING_FOREGROUND="yellow"
    POWERLEVEL9K_LOAD_NORMAL_FOREGROUND="green"
    POWERLEVEL9K_LOAD_CRITICAL_VISUAL_IDENTIFIER_COLOR="red"
    POWERLEVEL9K_LOAD_WARNING_VISUAL_IDENTIFIER_COLOR="yellow"
    POWERLEVEL9K_LOAD_NORMAL_VISUAL_IDENTIFIER_COLOR="green"

    POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND_COLOR="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_BATTERY_CHARGING_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_BATTERY_CHARGED_BACKGROUND="$DEFAULT_BACKGROUND"
    POWERLEVEL9K_BATTERY_DISCONNECTED_BACKGROUND="$DEFAULT_BACKGROUND"
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
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "/Applications/Araxis\ Merge.app/Contents/Utilities" ] && export PATH="$PATH:/Applications/Araxis\ Merge.app/Contents/Utilities"
[ -d "$HOME/Library/Android/sdk/platform-tools" ] && export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
[ -d "$HOME/Library/Python/2.7/bin" ] && export PATH="$PATH:$HOME/Library/Python/2.7/bin"
[ -d "$HOME/Library/Python/3.7/bin" ] && export PATH="$PATH:$HOME/Library/Python/3.7/bin"
[ -d "/usr/local/opt/go/libexec/bin" ] && export PATH="$PATH:/usr/local/opt/go/libexec/bin"
[ -d "$HOME/go/bin" ] && export PATH="$PATH:$HOME/go/bin"
[ -d "/usr/local/sbin" ] && export PATH="$PATH:/usr/local/sbin"
[ -d "/home/linuxbrew/.linuxbrew/bin" ] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Load asdf
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# Other things
# eval "$(hub alias -s)"
#eval "$(jump shell)"
eval "$(npm completion)"

[ -e "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# Remove duplicate entries in PATH
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"
