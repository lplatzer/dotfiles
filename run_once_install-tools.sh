#!/usr/bin/env bash
set -e

OS="$(uname -s)"

# ── macOS ────────────────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then

  # Homebrew
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "$(uname -m)" == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
  brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"

  # mise: activate and install LTS node (mise itself installed via Brewfile)
  eval "$(mise activate bash)"
  mise use --global node@lts

  # bun
  if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
  fi

  # opencode
  if ! command -v opencode >/dev/null 2>&1 && [[ ! -f "$HOME/.opencode/bin/opencode" ]]; then
    curl -fsSL https://opencode.ai/install | sh
  fi

  # Claude Code (needs bun on PATH)
  if ! command -v claude >/dev/null 2>&1; then
    export PATH="$HOME/.bun/bin:$PATH"
    bun install --global @anthropic-ai/claude-code
  fi

# ── Arch Linux / CachyOS ─────────────────────────────────────────────────────
elif command -v pacman >/dev/null 2>&1; then

  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm --needed \
    git wget curl chezmoi mise \
    zellij eza zoxide atuin starship vivid \
    fzf fd ripgrep \
    neovim lazygit \
    luarocks imagemagick ghostscript \
    go rustup \
    python python-pip \
    nodejs npm pnpm \
    dotnet-sdk \
    base-devel

  # 1password-cli: chaotic-aur on CachyOS, otherwise AUR via paru
  if ! command -v op >/dev/null 2>&1; then
    if command -v paru >/dev/null 2>&1; then
      paru -S --noconfirm 1password-cli
    else
      echo "1password-cli not installed — install via AUR (paru -S 1password-cli) manually." >&2
    fi
  fi

  # Antidote (not in official repos)
  if [[ ! -d "$HOME/.antidote" ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
  fi

  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

  # rustup stable
  command -v rustup >/dev/null 2>&1 && rustup default stable 2>/dev/null || true

  # mise: install LTS node
  eval "$(mise activate bash)"
  mise use --global node@lts

  # bun
  if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
  fi

  # opencode
  if ! command -v opencode >/dev/null 2>&1 && [[ ! -f "$HOME/.opencode/bin/opencode" ]]; then
    curl -fsSL https://opencode.ai/install | sh
  fi

  # Claude Code
  if ! command -v claude >/dev/null 2>&1; then
    export PATH="$HOME/.bun/bin:$PATH"
    bun install --global @anthropic-ai/claude-code
  fi

# ── Debian / Ubuntu / WSL ────────────────────────────────────────────────────
elif command -v apt-get >/dev/null 2>&1; then

  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    git wget curl build-essential gpg \
    fzf fd-find ripgrep \
    neovim \
    python3 python3-pip

  # fd ships as fd-find on Debian/Ubuntu; shim it
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
  fi

  # eza
  if ! command -v eza >/dev/null 2>&1; then
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
      | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
      | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -qq && sudo apt-get install -y eza
  fi

  # starship
  command -v starship >/dev/null 2>&1 || curl -fsSL https://starship.rs/install.sh | sh -s -- -y

  # zoxide
  command -v zoxide >/dev/null 2>&1 || curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

  # atuin
  command -v atuin >/dev/null 2>&1 || curl -fsSL https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | bash

  # zellij
  if ! command -v zellij >/dev/null 2>&1; then
    ZELLIJ_VER=$(curl -fsSL https://api.github.com/repos/zellij-org/zellij/releases/latest | grep tag_name | cut -d'"' -f4)
    curl -fsSL "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VER}/zellij-x86_64-unknown-linux-musl.tar.gz" \
      | tar -xz -C "$HOME/.local/bin"
  fi

  # lazygit
  if ! command -v lazygit >/dev/null 2>&1; then
    LG_VER=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d'"' -f4 | sed 's/v//')
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_Linux_x86_64.tar.gz" \
      | tar -xz -C "$HOME/.local/bin" lazygit
  fi

  # go
  if ! command -v go >/dev/null 2>&1; then
    GO_VER=$(curl -fsSL https://go.dev/dl/?mode=json | python3 -c "import sys,json;print(json.load(sys.stdin)[0]['version'])")
    curl -fsSL "https://go.dev/dl/${GO_VER}.linux-amd64.tar.gz" | sudo tar -C /usr/local -xz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.profile"
  fi

  # mise (install via official script; no apt package)
  if ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.run | sh
  fi

  # mise: install LTS node + pnpm
  export PATH="$HOME/.local/bin:$PATH"
  eval "$(mise activate bash)"
  mise use --global node@lts
  mise use --global pnpm@latest

  # Antidote
  if [[ ! -d "$HOME/.antidote" ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
  fi

  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

  # bun
  if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
  fi

  # opencode
  if ! command -v opencode >/dev/null 2>&1 && [[ ! -f "$HOME/.opencode/bin/opencode" ]]; then
    curl -fsSL https://opencode.ai/install | sh
  fi

  # Claude Code
  if ! command -v claude >/dev/null 2>&1; then
    export PATH="$HOME/.bun/bin:$PATH"
    bun install --global @anthropic-ai/claude-code
  fi

else
  echo "Unsupported OS/package manager. Install tools manually." >&2
fi
