## zsh-setup
ZSH config for my personal usecase

> [!CAUTION]
> This script assumes that you have Micro installed

## Including
*    ZSH Installation: Automatically installs ZSH if not present

*    Oh My Zsh: Sets up the popular Oh My Zsh framework

*    Essential Plugins:

      * zsh-autosuggestions

      * zsh-syntax-highlighting (must be loaded last)

      * zsh-history-substring-search

      * FZF (fuzzy finder)

*    Sensible Defaults: Pre-configured shell settings for productivity

*    Comprehensive Aliases: Git, Docker, system commands, and navigation shortcuts

*    Backup System: Creates timestamped backups of existing configurations

## Installation

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NoTreblee/zsh-setup/main/setup-zsh.sh)"
```

Or if you prefer to download and run manually:

```
curl -fsSL https://raw.githubusercontent.com/NoTreblee/zsh-setup/main/setup-zsh.sh -o setup-zsh.sh
chmod +x setup-zsh.sh
./setup-zsh.sh
```

## License

This script is provided as-is. Feel free to modify it for your needs.
