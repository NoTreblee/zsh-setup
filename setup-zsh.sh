#!/bin/bash
set -e

# ============================================
# DETECT ENVIRONMENT
# ============================================

IS_TERMUX=false
if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
fi

# Package manager detection with Alpine Linux support
PKG_MANAGER=""
if $IS_TERMUX; then
    PKG_MANAGER="termux"
elif command -v apk &>/dev/null; then
    PKG_MANAGER="apk"
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
    echo "  -> Installing $*..."
    case "$PKG_MANAGER" in
        termux) pkg install -y "$@" ;;
        apk)    sudo apk add "$@" ;;
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
        apk)    apk update ;;
        apt)    sudo apt-get update ;;
        dnf)    sudo dnf makecache ;;
        yum)    sudo yum makecache ;;
        pacman) sudo pacman -Sy ;;
        zypper) sudo zypper refresh ;;
        brew)   brew update ;;
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
    install_pkg zsh
    echo "ok ZSH installed"
else
    echo "ok ZSH already installed"
fi

ZSH_PATH=$(command -v zsh)

# ============================================
# OH MY ZSH
# ============================================

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "ok Oh My Zsh installed"
else
    echo "ok Oh My Zsh already installed"
fi

# ============================================
# PLUGINS
# ============================================

update_plugin() {
    local name="$1"
    local url="$2"
    local plugin_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

    if [ ! -d "$plugin_path" ]; then
        echo "Installing $name..."
        git clone "$url" "$plugin_path"
        echo "ok $name installed"
    else
        echo "Updating $name..."
        (cd "$plugin_path" && git pull --rebase && git submodule update --init --recursive) || echo "  ! Failed to update $name (non-fatal)"
    fi
}

echo "Installing ZSH plugins..."
update_plugin "zsh-autosuggestions"        "https://github.com/zsh-users/zsh-autosuggestions"
update_plugin "zsh-syntax-highlighting"    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
update_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search.git"

# ============================================
# FZF
# ============================================

if ! command -v fzf &>/dev/null; then
    echo "Installing fzf..."
    case "$PKG_MANAGER" in
        termux|apt|dnf|pacman|zypper) install_pkg fzf ;;
        yum|brew)
            if ! install_pkg fzf 2>/dev/null; then
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install --all --no-update-rc --no-bash --no-fish
            fi
            ;;
    esac
    echo "ok fzf installed"
else
    echo "ok fzf already installed"
fi

# ============================================
# MICRO
# ============================================

if ! command -v micro &>/dev/null; then
    echo "Installing micro..."
    case "$PKG_MANAGER" in
        termux|apt|dnf|pacman|zypper|brew) install_pkg micro ;;
        yum)
            curl https://getmic.ro | bash
            sudo mv micro /usr/local/bin/ 2>/dev/null || mv micro "$HOME/.local/bin/"
            ;;
    esac
    echo "ok micro installed"
else
    echo "ok micro already installed"
fi

# ============================================
# STARSHIP
# ============================================

if ! command -v starship &>/dev/null; then
    echo "Installing starship..."
    case "$PKG_MANAGER" in
        termux|apk|brew) install_pkg starship ;;
        *)
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
    esac
    echo "ok starship installed"
else
    echo "ok starship already installed"
fi
starship preset jetpack -o ~/.config/starship.toml


# ============================================
# BACKUP EXISTING .zshrc
# ===========================================

if [ -f "$HOME/.zshrc" ]; then
    BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP"
    echo "ok Backed up existing .zshrc -> $BACKUP"
    find "$HOME" -maxdepth 1 -name ".zshrc.backup.*" -type f -mtime +30 -delete 2>/dev/null || true
fi

# ============================================
# WRITE .zshrc
# ============================================
# NOTE: Heredoc uses quoted 'EOF' so bash does NOT expand anything inside.
# All $VAR / $() expressions are written literally and evaluated at zsh runtime.

echo "Writing .zshrc..."

cat > ~/.zshrc << 'EOF'
# ==============================================================================
# .zshrc -- generated by setup-zsh.sh
# ==============================================================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

DISABLE_UPDATE_PROMPT="true"
UPDATE_ZSH_DAYS=7
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_LS_COLORS="false"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Plugins -- zsh-syntax-highlighting MUST be last
plugins=(
    git
    sudo
    extract
    colored-man-pages
    command-not-found
    systemd
    docker
    docker-compose
    kubectl
    terraform
    fzf
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ==============================================================================
# AUTOSUGGESTIONS
# ==============================================================================

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a,bold"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
bindkey '^ ' autosuggest-accept    # Ctrl+Space -- accept suggestion
bindkey '^f'  autosuggest-execute  # Ctrl+F     -- execute suggestion

# ==============================================================================
# HISTORY SUBSTRING SEARCH
# ==============================================================================

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P'   history-substring-search-up
bindkey '^N'   history-substring-search-down
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=black,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=black,bold'
HISTORY_SUBSTRING_SEARCH_FUZZY=true

# ==============================================================================
# WORD NAVIGATION (Alt+Arrow)
# Different terminals send different escape sequences for Alt+Arrow.
# Binding all known variants ensures it works in Termux, Alacritty,
# xterm, iTerm2, and other VTE-based terminals.
# ==============================================================================

bindkey '\e[1;3C' forward-word
bindkey '\e[1;3D' backward-word
bindkey '\eC'     forward-word
bindkey '\eD'     backward-word
bindkey '\e[C'    forward-word
bindkey '\e[D'    backward-word
bindkey '\ef'     forward-word
bindkey '\eb'     backward-word
bindkey '\e^?'    backward-delete-word
bindkey '\e[3;3~' delete-word
bindkey '\e[1;3H' beginning-of-line
bindkey '\e[1;3F' end-of-line

# ==============================================================================
# SYNTAX HIGHLIGHTING
# ==============================================================================

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[function]='fg=green'
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='none'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=magenta'
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

# ==============================================================================
# SHELL SETTINGS
# ==============================================================================

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

setopt AUTO_CD
setopt CORRECT
setopt CORRECT_ALL
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# ==============================================================================
# PATHS AND ENVIRONMENT
# ==============================================================================

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export SHELL="$(command -v zsh)"

export PYTHONDONTWRITEBYTECODE=1
[ -f "$HOME/.pythonrc" ] && export PYTHONSTARTUP="$HOME/.pythonrc"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]          && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

export GOPATH="$HOME/go"

# ==============================================================================
# ALIASES -- CORE
# ==============================================================================

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

#=== Safe operations (uncomment to enable) ===
#alias rm='rm -i'
#alias cp='cp -i'
#alias mv='mv -i'
#alias ln='ln -i'

alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias ports='ss -tulanp'
alias reload='source ~/.zshrc'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# ==============================================================================
# ALIASES -- EZA (modern ls)
# ==============================================================================

if command -v eza &>/dev/null; then
    alias ls='eza --color=auto --group-directories-first'
    alias ll='eza -lah --group-directories-first --git'
    alias la='eza -a --group-directories-first'
    alias l='eza -F --group-directories-first'
    alias lt='eza --tree --level=2'
    alias ltt='eza --tree --level=3'
    alias lttt='eza --tree --level=4'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah'
    alias la='ls -A'
    alias l='ls -CF'
fi

# ==============================================================================
# ALIASES -- BAT (modern cat)
# ==============================================================================

if command -v bat &>/dev/null; then
    alias cat='bat -pP'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif command -v batcat &>/dev/null; then
    alias cat='batcat'
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
fi

# ==============================================================================
# ALIASES -- FZF
# ==============================================================================

if command -v fzf &>/dev/null; then
    if command -v bat &>/dev/null; then
        alias fzfp='fzf --preview "bat --color=always {}"'
    elif command -v batcat &>/dev/null; then
        alias fzfp='fzf --preview "batcat --color=always {}"'
    else
        alias fzfp='fzf --preview "cat {}"'
    fi
    alias fzfh='history | fzf'

    export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border
        --color=fg:#c8d3f5,bg:#1a1b26,hl:#bb9af7
        --color=fg+:#c8d3f5,bg+:#24283b,hl+:#bb9af7
        --color=info:#7aa2f7,prompt:#7dcfff,pointer:#f7768e
        --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"
fi

# ==============================================================================
# ALIASES -- RIPGREP
# ==============================================================================

if command -v rg &>/dev/null; then
    alias rg='rg --color=auto --smart-case'
    alias rgf='rg --files-with-matches'
    alias rgi='rg --ignore-case'
fi

# ==============================================================================
# ALIASES -- FD
# ==============================================================================

if command -v fd &>/dev/null; then
    alias fd='fd --color=auto'
    alias fdf='fd --type f'
    alias fdd='fd --type d'
elif command -v fdfind &>/dev/null; then
    alias fd='fdfind --color=auto'
    alias fdf='fdfind --type f'
    alias fdd='fdfind --type d'
fi

# ==============================================================================
# ALIASES -- TLDR
# ==============================================================================

if command -v tldr &>/dev/null; then
    alias help='tldr'
elif command -v tlrc &>/dev/null; then
    alias help='tlrc'
fi

# ==============================================================================
# ALIASES -- MICRO EDITOR
# ==============================================================================

if command -v micro &>/dev/null; then
    alias nano='micro'
    export EDITOR='micro'
    export VISUAL='micro'
fi

# ==============================================================================
# ALIASES -- GIT
# ==============================================================================

alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit -am'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpu='git push -u origin HEAD'
alias gpl='git pull'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gst='git stash'
alias gsp='git stash pop'
alias gsl='git stash list'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grs='git restore'
alias grss='git restore --staged'
alias gcp='git cherry-pick'
alias gtag='git tag'

# ==============================================================================
# ALIASES -- DOCKER
# ==============================================================================

alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcr='docker compose restart'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dim='docker images'
alias dst='docker stats'
alias dlg='docker logs'
alias dlgf='docker logs -f'
alias dex='docker exec -it'
alias dprune='docker system prune -af --volumes'
alias dnet='docker network ls'
alias dvol='docker volume ls'

# ==============================================================================
# ALIASES -- KUBERNETES
# ==============================================================================

if command -v kubectl &>/dev/null; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgpa='kubectl get pods -A'
    alias kgs='kubectl get svc'
    alias kgsa='kubectl get svc -A'
    alias kgd='kubectl get deployments'
    alias kgda='kubectl get deployments -A'
    alias kgn='kubectl get nodes'
    alias kgns='kubectl get namespaces'
    alias kd='kubectl describe'
    alias kdp='kubectl describe pod'
    alias kds='kubectl describe svc'
    alias kdn='kubectl describe node'
    alias kl='kubectl logs'
    alias klf='kubectl logs -f'
    alias ke='kubectl exec -it'
    alias ka='kubectl apply -f'
    alias kdel='kubectl delete'
    alias kctx='kubectl config use-context'
    alias kns='kubectl config set-context --current --namespace'
    alias kcg='kubectl config get-contexts'
fi

# ==============================================================================
# ALIASES -- TERRAFORM
# ==============================================================================

if command -v terraform &>/dev/null; then
    alias tf='terraform'
    alias tfi='terraform init'
    alias tfp='terraform plan'
    alias tfa='terraform apply'
    alias tfaa='terraform apply -auto-approve'
    alias tfd='terraform destroy'
    alias tfda='terraform destroy -auto-approve'
    alias tfo='terraform output'
    alias tfv='terraform validate'
    alias tff='terraform fmt'
    alias tfwr='terraform workspace'
    alias tfwrl='terraform workspace list'
    alias tfwrs='terraform workspace select'
    alias tfst='terraform state list'
    alias tfsh='terraform show'
fi

# ==============================================================================
# ALIASES -- ANSIBLE
# ==============================================================================

if command -v ansible &>/dev/null; then
    alias ap='ansible-playbook'
    alias apv='ansible-playbook -v'
    alias apvv='ansible-playbook -vvv'
    alias ai='ansible-inventory'
    alias ail='ansible-inventory --list'
    alias aig='ansible-inventory --graph'
    alias av='ansible-vault'
    alias ave='ansible-vault encrypt'
    alias avd='ansible-vault decrypt'
    alias avg='ansible-galaxy'
    alias avgi='ansible-galaxy install'
    alias ac='ansible'
    alias acm='ansible -m'
fi

# ==============================================================================
# ALIASES -- SYSTEM
# ==============================================================================

alias update='_sysupdate'
alias clean='_sysclean'
alias sysinfo='_sysinfo'

# ==============================================================================
# FUNCTIONS
# ==============================================================================

_sysupdate() {
    if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
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

_sysclean() {
    if command -v apt-get &>/dev/null; then
        sudo apt-get autoremove -y && sudo apt-get autoclean
    elif command -v dnf &>/dev/null; then
        sudo dnf autoremove -y
    elif command -v pacman &>/dev/null; then
        sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "Nothing to clean."
    elif command -v brew &>/dev/null; then
        brew cleanup
    fi
}

_sysinfo() {
    echo "Hostname:  $(hostname)"
    echo "OS:        $(uname -srm)"
    echo "Shell:     $SHELL ($ZSH_VERSION)"
    echo "Uptime:    $(uptime -p 2>/dev/null || uptime)"
    echo "Memory:    $(free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}' || echo 'N/A')"
    echo "Disk (/):  $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
}

mkcd() {
    mkdir -p "$1" && cd "$1"
}

ff() {
    if command -v fd &>/dev/null; then
        fd --type f "$1"
    elif command -v fdfind &>/dev/null; then
        fdfind --type f "$1"
    else
        find . -type f -name "*$1*"
    fi
}

fdir() {
    if command -v fd &>/dev/null; then
        fd --type d "$1"
    elif command -v fdfind &>/dev/null; then
        fdfind --type d "$1"
    else
        find . -type d -name "*$1*"
    fi
}

search() {
    if command -v rg &>/dev/null; then
        rg --smart-case "$@"
    else
        grep -r --color=auto "$@"
    fi
}

countlines() {
    find . -name "*.$1" | xargs wc -l
}

myip() {
    curl -s ifconfig.me
    echo
}

weather() {
    curl -s "wttr.in/${1:-Warsaw}?0"
}

encrypt() {
    [ -f "$1" ] && gpg -c "$1" && echo "Created $1.gpg" || echo "File not found: $1"
}

decrypt() {
    [ -f "$1" ] && gpg -d "$1" > "${1%.gpg}" && echo "Decrypted to ${1%.gpg}" || echo "File not found: $1"
}

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1"        ;;
            *.tar.gz)   tar xzf "$1"        ;;
            *.tar.xz)   tar xJf "$1"        ;;
            *.tar.zst)  tar --zstd -xf "$1" ;;
            *.bz2)      bunzip2 "$1"        ;;
            *.rar)      unrar x "$1"        ;;
            *.gz)       gunzip "$1"         ;;
            *.tar)      tar xf "$1"         ;;
            *.tbz2)     tar xjf "$1"        ;;
            *.tgz)      tar xzf "$1"        ;;
            *.zip)      unzip "$1"          ;;
            *.Z)        uncompress "$1"     ;;
            *.7z)       7z x "$1"           ;;
            *.zst)      unzstd "$1"         ;;
            *)          echo "Cannot extract '$1' -- unknown format." ;;
        esac
    else
        echo "File not found: $1"
    fi
}

tmpcd() {
    local dir
    dir=$(mktemp -d)
    echo "Created: $dir"
    cd "$dir"
}

watchfile() {
    if command -v bat &>/dev/null; then
        watch -n "${2:-2}" "bat --color=always $1"
    elif command -v batcat &>/dev/null; then
        watch -n "${2:-2}" "batcat --color=always $1"
    else
        watch -n "${2:-2}" cat "$1"
    fi
}

portcheck() {
    if [ -z "$1" ]; then echo "Usage: portcheck <port>"; return 1; fi
    ss -tulanp | grep ":$1 "
}

genpass() {
    local len="${1:-24}"
    tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "$len"; echo
}

denter() {
    local name="$1"
    local shell="${2:-sh}"
    local id
    id=$(docker ps --filter "name=$name" --format "{{.ID}}" | head -1)
    if [ -z "$id" ]; then
        echo "No running container matching: $name"
        return 1
    fi
    docker exec -it "$id" "$shell"
}

kswitch() {
    if command -v kubectl &>/dev/null; then
        kubectl config set-context --current --namespace="$1"
        echo "Switched to namespace: $1"
    fi
}

# ==============================================================================
# ZOXIDE INIT (smart cd)
# ==============================================================================

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
    alias cdi='zi'
fi

# ==============================================================================
# STARSHIP PROMPT
# ==============================================================================

if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ==============================================================================
# LOCAL OVERRIDES
# ==============================================================================

if [ ! -f "$HOME/.zshrc.local" ]; then
    cat > "$HOME/.zshrc.local" << 'LOCALEOF'
# ~/.zshrc.local -- Your custom settings
# ============================================
# Add your own aliases, PATH modifications, functions, etc.
# This file is sourced at the end of the main .zshrc

# Example:
# export MY_CUSTOM_VAR="value"
# alias myalias="my command"
# myfunc() { echo "Hello from local!" }
LOCALEOF
fi

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# ==============================================================================
# FZF OPTIONAL INTEGRATION
# ==============================================================================

if command -v fzf &>/dev/null; then
    [ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
fi

# ==============================================================================
# DIRENV OPTIONAL INTEGRATION
# ==============================================================================

if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# ==============================================================================
# NVIM OPTIONAL INTEGRATION (EDITOR override)
# ==============================================================================

if command -v nvim &>/dev/null; then
    export EDITOR='nvim'
    export VISUAL='nvim'
    alias vi='nvim'
    alias vim='nvim'
fi

# ==============================================================================
# GIT CONFIGURATION CHECK
# ==============================================================================

if command -v git &>/dev/null; then
    if ! git config --global user.name &>/dev/null; then
        echo "! git user.name not configured. Run: git config --global user.name \"Your Name\""
    fi
    if ! git config --global user.email &>/dev/null; then
        echo "! git user.email not configured. Run: git config --global user.email \"you@example.com\""
    fi
fi

EOF

echo "ok .zshrc written"

# ============================================
# CHANGE DEFAULT SHELL
# ============================================

echo ""
if [[ "${CI:-false}" == "true" ]]; then REPLY="n"; else read -rp "Change default shell to ZSH? [y/N] " -n 1; fi
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        if $IS_TERMUX; then
            chsh -s zsh 2>/dev/null || echo "  ! In Termux run: chsh -s zsh manually if needed."
        else
            chsh -s "$ZSH_PATH"
        fi
        echo "ok Default shell changed to ZSH"
        echo "  Log out and back in (or run: exec zsh) for it to take effect."
    else
        echo "ZSH is already your default shell."
    fi
else
    echo "Skipped. To change later: chsh -s $(command -v zsh)"
fi

# ============================================
# OPTIONAL EXTRAS (eza, bat, fd, rg, zoxide)
# ============================================

if [[ "${EXTRAS:-}" == "1" || "${EXTRAS:-}" == "true" ]]; then
    echo ""
    echo "=== Installing optional extras ==="

    command -v eza     &>/dev/null || install_pkg eza
    command -v bat     &>/dev/null || install_pkg bat
    command -v fd      &>/dev/null || install_pkg fd
    command -v rg      &>/dev/null || install_pkg ripgrep
    command -v zoxide  &>/dev/null || install_pkg zoxide

    echo "ok Optional extras installed"
    echo "  Run: source ~/.zshrc to enable aliases"
fi

# ============================================
# DONE
# ============================================

echo ""
echo "-------- Setup complete! --------"
echo ""
echo "Run:  exec zsh"
echo ""
