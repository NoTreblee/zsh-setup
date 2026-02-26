#!/bin/bash
# Check if ZSH is installed
if ! command -v zsh &> /dev/null; then
    echo "ZSH is not installed. Installing..."
    
    # For different distributions
    if command -v apt-get &> /dev/null; then
        sudo apt update
        sudo apt install -y zsh
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zsh
    elif command -v yum &> /dev/null; then
        sudo yum install -y zsh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zsh
    elif command -v brew &> /dev/null; then
        brew install zsh
    else
        echo "Package manager not found. Please install ZSH manually."
        exit 1
    fi
fi

# Get the path to ZSH
ZSH_PATH=$(which zsh)

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# Install plugins
echo "Installing plugins..."

# Zsh Autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "✓ Zsh Autosuggestions installed"
else
    echo "✓ Zsh Autosuggestions already installed"
fi

# Zsh Syntax Highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "✓ Zsh Syntax Highlighting installed"
else
    echo "✓ Zsh Syntax Highlighting already installed"
fi

# Zsh History Substring Search (optional, but recommended)
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search.git \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    echo "✓ Zsh History Substring Search installed"
else
    echo "✓ Zsh History Substring Search already installed"
fi

# FZF (fuzzy finder) - optional, but very useful
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf" ]; then
    git clone https://github.com/junegunn/fzf.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf/install --all --no-update-rc
    echo "✓ FZF installed"
else
    echo "✓ FZF already installed"
fi

# Create backup of existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✓ Created .zshrc backup"
fi

# Configure .zshrc
echo "Configuring .zshrc..."
cat > ~/.zshrc << EOF
# ============================================
# .zshrc - Zsh Configuration
# ============================================
# Author: [NoTreblee]
# Description: Feature-rich zsh configuration with Oh My Zsh, plugins, and custom functions
# Repository: https://github.com/NoTreblee/zsh-setup
# ============================================

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme name (empty means "robbyrussell")
ZSH_THEME=""

# Update automatically without asking
DISABLE_UPDATE_PROMPT="true"

# Auto-update (in days)
UPDATE_ZSH_DAYS=7

# Enable command signatures
DISABLE_MAGIC_FUNCTIONS="true"

# Enable colored ls
DISABLE_LS_COLORS="false"

# Auto-correct
ENABLE_CORRECTION="true"

# Show red dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# ============================================
# PLUGINS
# ============================================
# Remember that zsh-syntax-highlighting must be last!
# Install plugins with:
#   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#   git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# ============================================

plugins=(
    git
    sudo
    extract
    docker
    docker-compose
    zsh-autosuggestions
    zsh-history-substring-search
    fzf
    zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================
# KEY BINDINGS
# ============================================

# Navigation
bindkey '^[[1;3D' backward-word   # ALT+Left
bindkey '^[[1;3C' forward-word    # ALT+Right
bindkey '^[[1;3A' history-search-backward   # ALT+Up
bindkey '^[[1;3B' history-search-forward    # ALT+Down

# Alt navigation
bindkey '^[[1;5D' backward-word   # Ctrl+Left
bindkey '^[[1;5C' forward-word    # Ctrl+Right

# Home/End keys
bindkey '^[[H' beginning-of-line   # Home
bindkey '^[[F' end-of-line         # End
bindkey '^[[1~' beginning-of-line  # Home (alternative)
bindkey '^[[4~' end-of-line        # End (alternative)

# Delete keys
bindkey '^[[3~' delete-char        # Delete
bindkey '^H' backward-delete-char  # Backspace

# Line editing shortcuts
bindkey '^A' beginning-of-line      # Ctrl+A
bindkey '^E' end-of-line            # Ctrl+E
bindkey '^K' kill-line              # Ctrl+K
bindkey '^U' kill-whole-line        # Ctrl+U
bindkey '^W' backward-kill-word     # Ctrl+W
bindkey '^Y' yank                   # Ctrl+Y

# ============================================
# PLUGIN CONFIGURATION
# ============================================

# Zsh Autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a,bold"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
bindkey '^ ' autosuggest-accept  # Ctrl+Space - accept suggestion
bindkey '^f' autosuggest-execute # Ctrl+F - execute suggestion

# Zsh History Substring Search
bindkey '^P' history-substring-search-up      # Ctrl+P
bindkey '^N' history-substring-search-down    # Ctrl+N
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=green,fg=black,bold"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=red,fg=white,bold"

# Zsh Syntax Highlighting
# Must be set AFTER loading Oh My Zsh!
typeset -A ZSH_HIGHLIGHT_STYLES

# Basic styles
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green'
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[assign]='none'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[comment]='fg=black,bold'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=cyan'

# ============================================
# SHELL SETTINGS
# ============================================

# Set ZSH as default shell
export SHELL=/usr/bin/zsh

# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS      # Ignore duplicates
setopt HIST_IGNORE_SPACE     # Ignore commands starting with space
setopt HIST_FIND_NO_DUPS     # Don't show duplicates when searching
setopt HIST_REDUCE_BLANKS    # Remove unnecessary spaces
setopt INC_APPEND_HISTORY    # Add to history immediately
setopt SHARE_HISTORY         # Share history between sessions

# Convenience
setopt AUTO_CD               # Go to directories without 'cd'
setopt CORRECT               # Command correction
setopt CORRECT_ALL           # All arguments correction
setopt EXTENDED_GLOB         # Extended globbing
setopt NO_BEEP               # Disable beep
setopt INTERACTIVE_COMMENTS  # Allow comments in command line

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format '%BNo matches for: %d%b'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Create cache directory if not exists
[[ -d ~/.zsh/cache ]] || mkdir -p ~/.zsh/cache

# ============================================
# ALIASES
# ============================================

# Basic aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'
alias mkdir='mkdir -p'

# Git
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit -am'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gst='git stash'
alias gsp='git stash pop'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcr='docker-compose restart'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dim='docker images'
alias dst='docker stats'
alias dlg='docker logs'

# System - autodetect package manager
if command -v apt &> /dev/null; then
    alias update='sudo apt update && sudo apt upgrade -y'
    alias clean='sudo apt autoremove && sudo apt autoclean'
elif command -v dnf &> /dev/null; then
    alias update='sudo dnf upgrade'
elif command -v pacman &> /dev/null; then
    alias update='sudo pacman -Syu'
fi

alias reboot='sudo reboot'
alias shutdown='sudo shutdown -h now'
alias ports='netstat -tulanp'

# Safe operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Shortcuts
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

# FZF
alias fzfp='fzf --preview "bat --color=always {}"'
alias fzfh='history | fzf'

# FZF integration
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
    bindkey '^R' fzf-history-widget
fi

# Micro editor
if command -v micro &> /dev/null; then
    alias nano='micro'
    export EDITOR='micro'
    export VISUAL='micro'
fi

# ============================================
# FUNCTIONS
# ============================================

# Create directory and go to it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find file
ff() {
    find . -type f -name "*$1*"
}

# Find directory
fd() {
    find . -type d -name "*$1*"
}

# Count lines in files
countlines() {
    find . -name "*.$1" | xargs wc -l
}

# Display public IP
myip() {
    curl -s ifconfig.me
    echo
}

# Weather
weather() {
    curl -s "wttr.in/Warsaw?0"
}

# Encrypt file
encrypt() {
    if [ -f "$1" ]; then
        gpg -c "$1"
        echo "File $1.gpg created"
    else
        echo "Please provide a valid filename"
    fi
}

# Decrypt file
decrypt() {
    if [ -f "$1" ]; then
        gpg -d "$1" > "${1%.gpg}"
        echo "File ${1%.gpg} decrypted"
    else
        echo "Please provide a valid filename"
    fi
}

# ============================================
# FUZZY CD WITH FZF
# ============================================

# cd into directory with fzf
fcd() {
    local dir
    dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}

# cd into parent directory with fzf
fcd_up() {
    local dir
    dir=$(printf "%s\n" .. */ | fzf +m -q "$1") && cd "$dir"
}

# ============================================
# FZF FILE PREVIEW
# ============================================

# Edit file with fzf
fe() {
    local files
    IFS=$'\n' files=($(fzf --preview 'bat --color=always {}' --multi))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Open file with default app
fo() {
    local out file key
    IFS=$'\n' out=($(fzf --preview 'bat --color=always {}' --query="$1" --exit-0 --expect=ctrl-o,ctrl-e))
    key=$(head -1 <<< "$out")
    file=$(head -2 <<< "$out" | tail -1)
    if [ -n "$file" ]; then
        [ "$key" = ctrl-o ] && xdg-open "$file" || ${EDITOR:-vim} "$file"
    fi
}

# ============================================
# HISTORY SEARCH WITH FZF
# ============================================

fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/^\s+//' )
}

# ============================================
# PATHS AND ENVIRONMENT VARIABLES
# ============================================

# PATH setup
export PATH="$HOME/.local/bin"
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/bin:$PATH"

# Language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Python
export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONDONTWRITEBYTECODE=1

# Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Go
export GOPATH="$HOME/go"
export PATH="$HOME/go/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# ============================================
# CDPATH - EASIER NAVIGATION
# ============================================

# cdpath allows you to cd into subdirectories from anywhere
# Customize these paths to your needs
cdpath=(
    ~
    ~/projects
    ~/work
    ~/dev
    ~/Documents
    ~/Downloads
    ~/go/src
)

# ============================================
# TERMINAL TITLE
# ============================================

# Set terminal title to current command
precmd() {
    print -Pn "\e]0;%~\a"
}

preexec() {
    print -Pn "\e]0;%~: $1\a"
}

# ============================================
# AUTO LS AFTER CD
# ============================================

# Automatically list directory contents after cd
chpwd() {
    if [[ -t 1 ]] && [[ $(ls -1 | wc -l) -lt 50 ]]; then
        ls --color=auto
    fi
}

# ============================================
# HISTORY IGNORE
# ============================================

# Ignore these commands in history
HISTORY_IGNORE="(ls|ll|la|cd|pwd|exit|clear|history|reload|zshrc)"

# ============================================
# COMMAND TIMER
# ============================================

# Show command duration if > 5 seconds
preexec() {
    timer=${timer:-$SECONDS}
}

precmd() {
    if [ $timer ]; then
        duration=$(($SECONDS - $timer))
        if [ $duration -gt 5 ]; then
            echo -e "\033[1;33m⏱  Took ${duration}s\033[0m"
        fi
        unset timer
    fi
}

# ============================================
# COLORED MAN PAGES
# ============================================

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;34m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
export LESS_TERMCAP_ue=$'\e[0m'

# ============================================
# CLIPBOARD ALIASES
# ============================================

if command -v xclip &> /dev/null; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
elif command -v wl-copy &> /dev/null; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
fi

# ============================================
# QUICK ZSHRC EDITING
# ============================================

alias zshrc='$EDITOR ~/.zshrc'
alias reload='source ~/.zshrc && echo "✓ .zshrc reloaded"'

# ============================================
# STARSHIP PROMPT
# ============================================

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# ============================================
# SYSTEM INFO (pfetch)
# ============================================

if command -v pfetch &> /dev/null; then
    pfetch
fi

# ============================================
# FINALIZATION
# ============================================

# Load local configuration if exists
# Use ~/.zshrc.local for your private settings (API keys, custom aliases, etc.)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi


EOF

# Ask about changing default shell
echo ""
read -p "Do you want to change the default shell to ZSH? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        echo "Setting ZSH as default shell..."
        chsh -s $ZSH_PATH
        echo "✓ ZSH set as default shell"
        echo "You need to log out and log back in for this change to take effect."
    else
        echo "ZSH is already your default shell."
    fi
else
    echo "Shell change skipped. You can change it later with: chsh -s $(which zsh)"
fi

echo "-------- Configuration completed successfully! -------"
echo ""
echo ""
echo "Available commands:"
echo "  • zsh                - run ZSH"
echo "  • omz update         - update Oh My Zsh"
echo "  • omz plugin list    - list plugins"
echo "  • omz plugin enable  - enable plugin"
echo "  • omz plugin disable - disable plugin"
echo ""
echo "Next steps:"
echo "1. Log out and log back in or run: exec zsh"
echo "2. Check if plugins are working"
echo "3. Customize aliases in ~/.zshrc as needed"
echo ""
