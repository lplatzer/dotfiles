#!/usr/bin/env bash
set -e

OS="$(uname -s)"

case "$OS" in
  Darwin)
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
    # nvm: install via official script (brew nvm conflicts with ~/.nvm sourcing in .zshrc)
    if [[ ! -d "$HOME/.nvm" ]]; then
      NVM_INSTALL=$(mktemp)
      curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh -o "$NVM_INSTALL"
      bash "$NVM_INSTALL"
      rm -f "$NVM_INSTALL"
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
      nvm install --lts
    fi
    ;;
  Linux)
    if command -v pacman >/dev/null 2>&1; then
      sudo pacman -Syu --noconfirm

      sudo pacman -S --noconfirm --needed \
        git wget curl \
        zellij eza zoxide atuin starship vivid \
        fzf fd ripgrep \
        neovim lazygit \
        luarocks imagemagick ghostscript \
        go rustup \
        python python-pip \
        nodejs npm \
        dotnet-sdk \
        base-devel

      # 1password-cli: in chaotic-aur on CachyOS; fallback to paru on vanilla Arch
      if ! command -v op >/dev/null 2>&1; then
        if command -v paru >/dev/null 2>&1; then
          paru -S --noconfirm 1password-cli
        else
          echo "1password-cli not installed — install via AUR (paru -S 1password-cli) manually." >&2
        fi
      fi

      # SSH directory must exist before dot_ssh/config.tmpl renders
      mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

      # nvm: official install script (places nvm in ~/.nvm, consistent with .zshrc sourcing)
      if [[ ! -d "$HOME/.nvm" ]]; then
        NVM_INSTALL=$(mktemp)
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh -o "$NVM_INSTALL"
        bash "$NVM_INSTALL"
        rm -f "$NVM_INSTALL"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts
      fi

      # rustup: initialise stable toolchain
      if command -v rustup >/dev/null 2>&1; then
        rustup default stable 2>/dev/null || true
      fi

    else
      echo "Unsupported Linux package manager — install tools manually." >&2
    fi
    ;;
  *)
    echo "Unsupported OS: $OS" >&2
    ;;
esac
