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
# Path to oh-my-zsh installation
export ZSH="\$HOME/.oh-my-zsh"

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

# Plugins (remember that zsh-syntax-highlighting must be last!)
plugins=(
    git
    sudo
    extract
    docker
    docker-compose
    zsh-autosuggestions
    zsh-history-substring-search
    fzf
    zsh-syntax-highlighting  # MUST BE LAST!
)

# Load Oh My Zsh
source \$ZSH/oh-my-zsh.sh

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
bindkey '^[[A' history-substring-search-up    # Up arrow
bindkey '^[[B' history-substring-search-down  # Down arrow
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
export SHELL=${ZSH_PATH}

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

# System
alias update='sudo apt update && sudo apt upgrade -y'  # for Debian/Ubuntu
# For other distributions:
# alias update='sudo dnf upgrade'        # Fedora
# alias update='sudo yum update'         # CentOS/RHEL
# alias update='sudo pacman -Syu'        # Arch
alias clean='sudo apt autoremove && sudo apt autoclean'
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
alias path='echo -e \${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

# FZF
alias fzfp='fzf --preview "bat --color=always {}"'
alias fzfh='history | fzf'

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
    mkdir -p "\$1" && cd "\$1"
}

# Find file
ff() {
    find . -type f -name "*\$1*"
}

# Find directory
fd() {
    find . -type d -name "*\$1*"
}

# Count lines in files
countlines() {
    find . -name "*.\$1" | xargs wc -l
}

# Display public IP
myip() {
    curl -s ifconfig.me
    echo
}

# Weather
weather() {
    curl -s "wttr.in/\${1:-Warsaw}?0"
}

# Encrypt file
encrypt() {
    if [ -f "\$1" ]; then
        gpg -c "\$1"
        echo "File \$1.gpg created"
    else
        echo "Please provide a valid filename"
    fi
}

# Decrypt file
decrypt() {
    if [ -f "\$1" ]; then
        gpg -d "\$1" > "\${1%.gpg}"
        echo "File \${1%.gpg} decrypted"
    else
        echo "Please provide a valid filename"
    fi
}

# ============================================
# PATHS AND ENVIRONMENT VARIABLES
# ============================================

# Add directories to PATH
export PATH="\$HOME/.local/bin:\$PATH"
export PATH="\$HOME/bin:\$PATH"
export PATH="/usr/local/bin:\$PATH"
export PATH="/usr/local/sbin:\$PATH"

# Language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Python
export PYTHONSTARTUP="\$HOME/.pythonrc"
export PYTHONDONTWRITEBYTECODE=1

# Node.js
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"  # Load nvm
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"  # Load nvm completion

# Go
export GOPATH="\$HOME/go"
export PATH="\$GOPATH/bin:\$PATH"

# Rust
export PATH="\$HOME/.cargo/bin:\$PATH"

# Starship Prompt (if installed)
if command -v starship &> /dev/null; then
    eval "\$(starship init zsh)"
fi

# ============================================
# FINALIZATION
# ============================================

# Load local configuration if exists
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

EOF

# Set ZSH as default shell
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Setting ZSH as default shell..."
    chsh -s $ZSH_PATH
    echo "✓ ZSH set as default shell"
    echo "Please log out and log back in to see changes."
fi

clear
echo " _      ____ _____ ____  _____ ____  _     _____ _____";
echo "/ \\  /|/  _ Y__ __Y  __\\/  __//  _ \\/ \\   /  __//  __/";
echo "| |\\ ||| / \\| / \\ |  \\/||  \\  | | //| |   |  \\  |  \\  ";
echo "| | \\||| \\_/| | | |    /|  /_ | |_\\\\| |_/\\|  /_ |  /_ ";
echo "\\_/  \\|\\____/ \\_/ \\_/\\_\\\\____\\\\____/\\____/\\____\\\\____\\";
echo "                                                      ";
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

