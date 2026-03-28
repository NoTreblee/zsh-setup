#!/bin/bash
set -e

# ============================================
# DETECT ENVIRONMENT
# ============================================

IS_TERMUX=false
if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
fi

# Package manager detection
PKG_MANAGER=""
if $IS_TERMUX; then
    PKG_MANAGER="termux"
elif command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
elif command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
elif command -v zypper &>/dev/null; then
    PKG_MANAGER="zypper"
elif command -v brew &>/dev/null; then
    PKG_MANAGER="brew"
else
    echo "ERROR: Unsupported package manager. Exiting."
    exit 1
fi

# Wrapper for installing packages
install_pkg() {
    echo "  → Installing $*..."
    case "$PKG_MANAGER" in
        termux) pkg install -y "$@" ;;
        apt)    sudo apt-get install -y "$@" ;;
        dnf)    sudo dnf install -y "$@" ;;
        yum)    sudo yum install -y "$@" ;;
        pacman) sudo pacman -S --noconfirm "$@" ;;
        zypper) sudo zypper install -y "$@" ;;
        brew)   brew install "$@" ;;
    esac
}

# Update package lists
update_pkg_lists() {
    case "$PKG_MANAGER" in
        termux) pkg update -y ;;
        apt)    sudo apt-get update ;;
        dnf|yum|zypper|pacman|brew) ;; # not needed / handled by install
    esac
}

echo ""
echo "=== ZSH Setup Script ==="
echo "Detected package manager: $PKG_MANAGER"
echo ""

update_pkg_lists

# ============================================
# ZSH
# ============================================

if ! command -v zsh &>/dev/null; then
    echo "Installing ZSH..."
    case "$PKG_MANAGER" in
        termux) install_pkg zsh ;;
        apt)    install_pkg zsh ;;
        dnf)    install_pkg zsh ;;
        yum)    install_pkg zsh ;;
        pacman) install_pkg zsh ;;
        zypper) install_pkg zsh ;;
        brew)   install_pkg zsh ;;
    esac
    echo "✓ ZSH installed"
else
    echo "✓ ZSH already installed"
fi

ZSH_PATH=$(command -v zsh)

# ============================================
# OH MY ZSH
# ============================================

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed"
else
    echo "✓ Oh My Zsh already installed"
fi

# ============================================
# PLUGINS
# ============================================

echo "Installing ZSH plugins..."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    echo "✓ zsh-autosuggestions installed"
else
    echo "✓ zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    echo "✓ zsh-syntax-highlighting installed"
else
    echo "✓ zsh-syntax-highlighting already installed"
fi

# zsh-history-substring-search
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search.git \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"
    echo "✓ zsh-history-substring-search installed"
else
    echo "✓ zsh-history-substring-search already installed"
fi

# ============================================
# FZF
# ============================================

if ! command -v fzf &>/dev/null; then
    echo "Installing fzf..."
    case "$PKG_MANAGER" in
        termux) install_pkg fzf ;;
        apt)    install_pkg fzf ;;
        dnf)    install_pkg fzf ;;
        pacman) install_pkg fzf ;;
        zypper) install_pkg fzf ;;
        yum|brew)
            # fzf not always in yum repos; use git install as fallback
            if ! install_pkg fzf 2>/dev/null; then
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install --all --no-update-rc --no-bash --no-fish
            fi
            ;;
    esac
    echo "✓ fzf installed"
else
    echo "✓ fzf already installed"
fi

# ============================================
# MICRO
# ============================================

if ! command -v micro &>/dev/null; then
    echo "Installing micro..."
    case "$PKG_MANAGER" in
        termux) install_pkg micro ;;
        apt)    install_pkg micro ;;
        dnf)    install_pkg micro ;;
        pacman) install_pkg micro ;;
        zypper) install_pkg micro ;;
        brew)   install_pkg micro ;;
        yum)
            # micro not in standard yum repos; use official installer
            curl https://getmic.ro | bash
            sudo mv micro /usr/local/bin/ 2>/dev/null || mv micro "$HOME/.local/bin/"
            ;;
    esac
    echo "✓ micro installed"
else
    echo "✓ micro already installed"
fi

# ============================================
# STARSHIP
# ============================================

if ! command -v starship &>/dev/null; then
    echo "Installing starship..."
    case "$PKG_MANAGER" in
        termux) install_pkg starship ;;
        brew)   install_pkg starship ;;
        *)
            # Official installer works on all Linux distros
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
    esac
    echo "✓ starship installed"
else
    echo "✓ starship already installed"
fi

# ============================================
# BACKUP EXISTING .zshrc
# ============================================

if [ -f "$HOME/.zshrc" ]; then
    BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP"
    echo "✓ Backed up existing .zshrc → $BACKUP"
fi

# ============================================
# WRITE .zshrc
# ============================================

echo "Writing .zshrc..."

cat > ~/.zshrc << EOF
# Path to oh-my-zsh installation
export ZSH="\$HOME/.oh-my-zsh"

# Theme — set to empty string to let Starship handle the prompt.
# Change to e.g. "robbyrussell" if not using Starship.
ZSH_THEME=""

# Auto-update Oh My Zsh without asking
DISABLE_UPDATE_PROMPT="true"
UPDATE_ZSH_DAYS=7

# Disable magic functions (prevents unwanted URL escaping on paste)
DISABLE_MAGIC_FUNCTIONS="true"

# Colored ls output
DISABLE_LS_COLORS="false"

# Auto-correct commands and arguments
ENABLE_CORRECTION="true"

# Show dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Plugins — zsh-syntax-highlighting MUST be last
plugins=(
    git
    sudo
    extract
    docker
    docker-compose
    fzf
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
)

source \$ZSH/oh-my-zsh.sh

# ============================================
# PLUGIN CONFIGURATION
# ============================================

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a,bold"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
bindkey '^ ' autosuggest-accept   # Ctrl+Space — accept suggestion
bindkey '^f'  autosuggest-execute # Ctrl+F     — execute suggestion

# zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P'   history-substring-search-up
bindkey '^N'   history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=green,fg=black,bold"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=red,fg=white,bold"

# zsh-syntax-highlighting styles
typeset -A ZSH_HIGHLIGHT_STYLES
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

export SHELL=${ZSH_PATH}

# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Convenience
setopt AUTO_CD
setopt CORRECT
setopt CORRECT_ALL
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

# Completion (OMZ already calls compinit — just configure styles)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# ============================================
# PATHS AND ENVIRONMENT VARIABLES
# ============================================

export PATH="\$HOME/.local/bin:\$PATH"
export PATH="\$HOME/bin:\$PATH"
export PATH="/usr/local/bin:\$PATH"
export PATH="/usr/local/sbin:\$PATH"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Python
export PYTHONDONTWRITEBYTECODE=1
[ -f "\$HOME/.pythonrc" ] && export PYTHONSTARTUP="\$HOME/.pythonrc"

# Node.js (nvm)
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ]             && source "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ]    && source "\$NVM_DIR/bash_completion"

# Go
export GOPATH="\$HOME/go"
export PATH="\$GOPATH/bin:\$PATH"

# Rust
export PATH="\$HOME/.cargo/bin:\$PATH"

# ============================================
# ALIASES
# ============================================

# Core
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

# cat → bat (only if bat/batcat is available)
if command -v bat &>/dev/null; then
    alias cat='bat'
elif command -v batcat &>/dev/null; then
    alias cat='batcat'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Safe operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# System update — picks the right package manager automatically
alias update='_sysupdate'
alias clean='_sysclean'

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
alias dc='docker compose'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcr='docker compose restart'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dim='docker images'
alias dst='docker stats'
alias dlg='docker logs'

# Shortcuts
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e \${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias ports='ss -tulanp'

# FZF shortcuts
if command -v fzf &>/dev/null; then
    if command -v bat &>/dev/null; then
        alias fzfp='fzf --preview "bat --color=always {}"'
    elif command -v batcat &>/dev/null; then
        alias fzfp='fzf --preview "batcat --color=always {}"'
    else
        alias fzfp='fzf --preview "cat {}"'
    fi
    alias fzfh='history | fzf'
fi

# Micro editor
if command -v micro &>/dev/null; then
    alias nano='micro'
    export EDITOR='micro'
    export VISUAL='micro'
fi

# ============================================
# FUNCTIONS
# ============================================

# System update — distro-aware
_sysupdate() {
    if [ -n "\$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
        pkg update && pkg upgrade
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get upgrade -y
    elif command -v dnf &>/dev/null; then
        sudo dnf upgrade -y
    elif command -v pacman &>/dev/null; then
        sudo pacman -Syu
    elif command -v zypper &>/dev/null; then
        sudo zypper update -y
    elif command -v yum &>/dev/null; then
        sudo yum update -y
    elif command -v brew &>/dev/null; then
        brew update && brew upgrade
    else
        echo "Unknown package manager."
    fi
}

# System clean — distro-aware
_sysclean() {
    if command -v apt-get &>/dev/null; then
        sudo apt-get autoremove -y && sudo apt-get autoclean
    elif command -v dnf &>/dev/null; then
        sudo dnf autoremove -y
    elif command -v pacman &>/dev/null; then
        sudo pacman -Rns \$(pacman -Qtdq) 2>/dev/null || echo "Nothing to clean."
    elif command -v brew &>/dev/null; then
        brew cleanup
    fi
}

# Create directory and cd into it
mkcd() {
    mkdir -p "\$1" && cd "\$1"
}

# Find file by name
ff() {
    find . -type f -name "*\$1*"
}

# Find directory by name (named _fdir to avoid colliding with the 'fd' binary)
_fdir() {
    find . -type d -name "*\$1*"
}

# Count lines in files by extension
countlines() {
    find . -name "*.\$1" | xargs wc -l
}

# Show public IP
myip() {
    curl -s ifconfig.me
    echo
}

# Quick weather (default: Warsaw)
weather() {
    curl -s "wttr.in/\${1:-Warsaw}?0"
}

# Encrypt a file with GPG
encrypt() {
    [ -f "\$1" ] && gpg -c "\$1" && echo "Created \$1.gpg" || echo "File not found: \$1"
}

# Decrypt a GPG file
decrypt() {
    [ -f "\$1" ] && gpg -d "\$1" > "\${1%.gpg}" && echo "Decrypted to \${1%.gpg}" || echo "File not found: \$1"
}

# ============================================
# STARSHIP PROMPT
# ============================================

if command -v starship &>/dev/null; then
    eval "\$(starship init zsh)"
fi

# ============================================
# LOCAL OVERRIDES
# ============================================

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

EOF

echo "✓ .zshrc written"

# ============================================
# CHANGE DEFAULT SHELL
# ============================================

echo ""
if [[ "${CI:-false}" == "true" ]]; then REPLY="n"; else read -p "Change default shell to ZSH? [y/N] " -n 1 -r; fi
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        if $IS_TERMUX; then
            chsh -s zsh 2>/dev/null || echo "  ⚠ In Termux run: chsh -s zsh manually if needed."
        else
            chsh -s "$ZSH_PATH"
        fi
        echo "✓ Default shell changed to ZSH"
        echo "  Log out and back in (or run: exec zsh) for it to take effect."
    else
        echo "ZSH is already your default shell."
    fi
else
    echo "Skipped. To change later: chsh -s $(command -v zsh)"
fi

# ============================================
# DONE
# ============================================

echo ""
echo "-------- Setup complete! --------"
echo ""
echo "Run:  exec zsh"
echo ""
