#!/usr/bin/env bash
set -e
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lplatzer/dotfiles
