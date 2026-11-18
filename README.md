# dotfiles

Personal dotfiles managed by [chezmoi](https://chezmoi.io). Covers macOS (primary), Arch/CachyOS Linux, and Windows (in progress).

---

## What's included

| Category | Tools |
|---|---|
| **Shell** | zsh + [antidote](https://getantidote.github.io) + plugins |
| **Prompt** | [starship](https://starship.rs) (Catppuccin Mocha) |
| **Editor** | [Neovim](https://neovim.io) via [LazyVim](https://lazyvim.org) |
| **File listing** | [eza](https://eza.community) |
| **Directory jumping** | [zoxide](https://github.com/ajeetdsouza/zoxide) |
| **Fuzzy finder, shell history** | [fzf](https://github.com/junegunn/fzf) (Ctrl+R) |
| **Version manager** | [mise](https://mise.jdx.dev) (Node LTS, pnpm) |
| **JS runtime** | [bun](https://bun.sh) |
| **Git UI** | [lazygit](https://github.com/jesseduffield/lazygit) |
| **AI CLIs** | [Claude Code](https://claude.ai/code), [Codex](https://github.com/openai/codex) |
| **macOS only** | AeroSpace, LinearMouse, Alfred, and more |
| **Dev runtimes** | Go, Rust (rustup), .NET, Node (via mise) |

---

## Quick start

### macOS

> Requires macOS 13 Ventura or later. Apple Silicon and Intel both supported.

```bash
# 1. Install chezmoi and apply dotfiles in one shot
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/lplatzer/dotfiles-chezmoi.git
```

chezmoi will prompt for:

| Prompt | What it is |
|---|---|
| `Full name` | Used in `~/.gitconfig` |
| `Personal email` | Default git identity |
| `GitHub email` | Injected into `~/.gitconfig-github` |
| `Azure DevOps full name` | Injected into `~/.gitconfig-azure` |
| `Azure DevOps email` | Injected into `~/.gitconfig-azure` |
| `Is this a personal machine?` | Installs messaging apps, Figma, Affinity, 1Password, etc. |

After chezmoi applies the files, the `run_once_install-tools.sh` script runs automatically:

1. Installs Homebrew (if missing)
2. Runs `brew bundle` from `~/Brewfile`
3. Installs mise + Node LTS
4. Installs bun, Claude Code, Codex

The `run_once_configure-macos.sh` script also runs once to set sensible macOS system defaults (Finder, Dock, autocorrect, etc.).

### Arch Linux / CachyOS

```bash
# 1. Install chezmoi
sudo pacman -S chezmoi

# 2. Apply dotfiles
chezmoi init --apply git@github.com:lplatzer/dotfiles-chezmoi.git
```

The install script installs all tools via `pacman` + optional AUR (paru), then bootstraps mise, bun, Claude Code, and Codex. Personal machines also get Ollama, Telegram, Signal, WhatsApp, and Obsidian.

### Windows

The Windows host setup (winget configure, chezmoi on Windows) is being rebuilt. Dev tooling runs inside WSL.

> macOS-only configs (AeroSpace, LinearMouse, Brewfile) are excluded via `.chezmoiignore` on non-macOS machines.

---

## Personal vs. work machines

Set `is_personal = true` during the chezmoi prompt to unlock:

- **macOS**: 1Password, Little Snitch, JetBrains Toolbox, Figma, Affinity suite, Notion, Shapr3D, WhatsApp, Telegram, Signal, Qobuz
- **Linux**: 1Password CLI, Ollama, Telegram, Signal, WhatsApp, Obsidian
- **Git**: SSH commit signing via 1Password agent

Work machines get the lean set: dev tools, AI CLIs, editors — no personal apps.

---

## PAI (Personal AI Infrastructure)

The install scripts include an optional PAI bootstrap block (commented out by default):

```bash
# PAI_REPO="git@github.com:YOUR_USERNAME/pai.git"
# [[ ! -d "$HOME/.claude" ]] && git clone "$PAI_REPO" "$HOME/.claude"
```

Uncomment and set your PAI repo URL to automatically clone it into `~/.claude` on new machines.

---

## Re-applying after changes

```bash
# Pull latest and re-apply
chezmoi update

# Apply without pulling (local edits already in source dir)
chezmoi apply

# Preview what would change
chezmoi diff
```

---

## Repository structure

```
dotfiles/
├── .chezmoi.toml.tmpl          # chezmoi config — prompts for name, email, is_personal
├── .chezmoiignore              # skips macOS-only configs on Linux/Windows
├── Brewfile.tmpl               # Homebrew packages (macOS)
├── dot_zshrc.tmpl              # ~/.zshrc
├── dot_zsh_plugins.txt         # antidote plugin list
├── dot_gitconfig.tmpl          # ~/.gitconfig
├── dot_gitconfig-github.tmpl   # identity for github.com remotes
├── dot_gitconfig-azure.tmpl    # identity for dev.azure.com remotes
├── dot_gitignore_global        # global .gitignore
├── dot_aerospace.toml          # AeroSpace tiling WM (macOS only)
├── dot_config/
│   ├── linearmouse/            # mouse configuration (macOS only)
│   └── starship.toml           # prompt theme
├── .chezmoiexternal.toml       # ~/.config/nvim from github.com/lplatzer/nvim
├── private_dot_ssh/
│   └── config.tmpl             # SSH config (1Password agent on personal machines)
├── run_once_install-tools.sh.tmpl   # cross-platform tool bootstrap (macOS/Arch)
└── run_once_configure-macos.sh     # macOS system defaults
```

---

## Updating answers to chezmoi prompts

Answers to `promptStringOnce`/`promptBoolOnce` are cached in `~/.config/chezmoi/chezmoi.toml`. To change them:

```bash
chezmoi edit-config
```
