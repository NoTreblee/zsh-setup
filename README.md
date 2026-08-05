## zsh-setup

ZSH config for my personal usecase. One script, works on Termux, Alpine, Debian/Ubuntu,
Fedora, RHEL, Arch, openSUSE and macOS (Homebrew).

## Including

* **ZSH + Oh My Zsh**: installs both if not present

* **Powerlevel10k prompt** with instant prompt (needs a Nerd Font, e.g. MesloLGS NF).
  The configuration wizard runs on first start; re-run it with `p10k configure`.

* **Plugins**

  * `zsh-autosuggestions`
  * `zsh-syntax-highlighting`
  * `zsh-history-substring-search`
  * `zsh-completions`
  * `fzf-tab` — fzf-driven tab completion
  * `zsh-autopair` — auto-close quotes and brackets
  * `zsh-you-should-use` — reminds you when an alias exists
  * `forgit` — interactive git (`fga`, `fgd`, `fglo`, `fgco`, …)
  * `zsh-abbr` — inline abbreviations (`gpf`, `gca`, `gundo`, `please`)
  * Oh My Zsh built-ins: `git`, `sudo`, `extract`, `colored-man-pages`,
    `command-not-found`, `systemd`, `docker`, `docker-compose`, `kubectl`,
    `terraform`, `fzf`, `magic-enter`

* **CLI tools** (installed best-effort, every use is guarded by `command -v`)

  * `atuin` — Ctrl-R history search (Up arrow stays with substring search)
  * `delta` — git/diff pager, aliased to `diff`
  * `pay-respects` — `f` re-runs the last command with a suggested fix
  * `fzf`, `micro`

* **Keybindings**: Alt/Ctrl+Arrow word navigation across terminal escape variants,
  Alt+Backspace stops at path separators, Esc Esc toggles a `sudo` prefix,
  Ctrl+Space accepts an autosuggestion, Enter on an empty line runs
  `git status` in a repo or `eza --icons` elsewhere.

* **Comprehensive aliases**: git, docker, kubernetes, terraform, ansible,
  systemd/journal, navigation, and modern replacements (`eza`, `bat`, `rg`, `fd`).

* **Functions**: `mkcd`, `extract`, `genpass`, `portcheck`, `denter`, `tmpcd`,
  `watchfile`, `ff`, `fdir`, `search`, `weather`, `myip`, `encrypt`/`decrypt`,
  `update`/`clean`/`sysinfo`.

* **Backup system**: timestamped backup of any existing `~/.zshrc`
  (backups older than 30 days are pruned). Autocorrect is off by design.

* **`~/.zshrc.local`**: sourced last and never overwritten — machine-specific
  aliases, secrets, and host quirks belong there.

## Installation

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NoTreblee/zsh-setup/main/setup-zsh.sh)"
```

Or if you prefer to download and run manually:

```shell
curl -fsSL https://raw.githubusercontent.com/NoTreblee/zsh-setup/main/setup-zsh.sh -o setup-zsh.sh
chmod +x setup-zsh.sh
./setup-zsh.sh
```

Set `EXTRAS=1` to also install `eza`, `bat`, `fd`, `ripgrep` and `zoxide`:

```shell
EXTRAS=1 ./setup-zsh.sh
```

**The script replaces `~/.zshrc`.** It backs the old one up first, including when
the file is write-protected.

## License

This script is provided as-is. Feel free to modify it for your needs.
