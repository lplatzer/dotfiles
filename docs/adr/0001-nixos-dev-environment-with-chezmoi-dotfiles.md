---
status: accepted
date: 2026-11-16
---

# A NixOS dev environment, with chezmoi for dotfiles and no nix-darwin

All coding happens in one NixOS environment, defined by one flake. It runs as a VMware Fusion VM on the Macs, as NixOS-WSL on Windows, and as standalone home-manager on any other Linux. The hosts keep only GUI apps and a comfortable shell. This replaces the earlier model, where each OS branch of an install script tried to reach the same state imperatively. Those branches drifted apart, and every step needed hand-written idempotency guards.

Nix installs packages and builds the system. **chezmoi still manages the dotfiles everywhere, including inside NixOS.** home-manager doesn't manage dotfiles here. This mirrors the split mitchellh/nixos-config moved to in 2025. It also keeps one dotfile source that works on the Windows and macOS hosts, which Nix can't reach.

## Considered options

- **nix-darwin + home-manager on the Macs.** Rejected. Its `homebrew` module only generates a Brewfile and runs `brew bundle`, and neither project can install vendor .dmg or .pkg files. That works against [ADR 0003](0003-vendor-installers-over-homebrew-casks.md) and adds a second system to the hosts for little gain.
- **chezmoi only, with a Debian VM.** This remains the fallback if Nix is blocked on a machine. It gives up reproducibility and rollback.
- **OrbStack, Lima or Parallels instead of VMware Fusion.**
  - OrbStack needs a paid licence for work and shares one kernel across machines.
  - Lima doesn't run NixOS out of the box.
  - Parallels' standard licence wording is unclear for employer work.
  - Fusion is free for commercial use.

## Consequences

- The flake builds for both `aarch64-linux` (the Mac VM) and `x86_64-linux` (WSL, PCs).
- Vendor binaries that download themselves (the Claude Code native installer, the VS Code server, Mason tools) need `programs.nix-ld.enable`.
- Until the VM exists on a machine, the host carries the dev runtimes through mise as a stopgap.
