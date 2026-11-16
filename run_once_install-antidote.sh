#!/usr/bin/env bash
# antidote (zsh plugin manager) — the project's recommended git clone, on every OS.
# ~/.zshrc sources it from ~/.antidote.
[[ -d "$HOME/.antidote" ]] || git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
