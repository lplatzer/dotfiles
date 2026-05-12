#!/usr/bin/env bash

case "$(uname -s)" in
  Darwin)
    command -v antidote >/dev/null 2>&1 || brew install antidote
    ;;
  Linux)
    if [[ ! -d "$HOME/.antidote" ]]; then
      git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
    fi
    ;;
esac
