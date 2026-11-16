#!/usr/bin/env bash
# macOS system defaults — runs once on new machine setup.
# No set -e: defaults write returns non-zero on some keys on certain macOS versions.

[[ "$(uname -s)" == "Darwin" ]] || exit 0

# Touch ID for sudo (Sonoma+ method)
if [[ ! -f /etc/pam.d/sudo_local ]] && [[ -f /etc/pam.d/sudo_local.template ]]; then
  sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template \
    | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

# Dock. Snapshot its prefs first: the Dock restarts at the end only if they changed.
DOCK_BEFORE=$(defaults export com.apple.dock - 2>/dev/null | shasum)
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
# Mission Control groups windows by app (AeroSpace recommends it: its windows
# otherwise show up tiny there).
defaults write com.apple.dock expose-group-apps -bool true

# Spaces: one Space across all displays ("Displays have separate Spaces" off), as
# AeroSpace recommends. Takes effect after logging out and in again.
defaults write com.apple.spaces spans-displays -bool true

# Windows: Ctrl+Cmd + drag anywhere in a window moves it (like Hyprland's mod+drag).
# AeroSpace re-tiles a tiled window where it is dropped.
defaults write NSGlobalDomain NSWindowShouldDragOnGesture -bool true

# Finder
defaults write com.apple.finder AppleShowAllFiles true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder NewWindowTarget PfHm
defaults write com.apple.finder FXPreferredViewStyle Nlsv
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Spelling / autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false

# Stop Photos opening on device connect
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Apply Dock changes. This script re-runs whenever its contents change (chezmoi
# keys run_once_ on the script hash) and every `defaults write` above is
# idempotent, but `killall Dock` blanks the Dock mid-session, so only restart it
# when the Dock prefs actually changed.
if [[ "$(defaults export com.apple.dock - 2>/dev/null | shasum)" != "$DOCK_BEFORE" ]]; then
  killall Dock
fi
