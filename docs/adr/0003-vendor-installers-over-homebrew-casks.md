---
status: accepted
date: 2026-11-16
---

# Vendor installers over Homebrew casks, mise for CLIs, Renovate for pins

On the hosts, each tool is installed the way its vendor recommends.
- **macOS GUI apps:** the vendor's signed .dmg, .pkg or .zip, fetched by `run_once_install-vendor-apps.sh.tmpl`.
- **CLIs on macOS:** mise, from one chezmoi-managed config with pinned versions.
- **mise, pnpm, Claude Code and Codex CLI:** each vendor's own installer.
- **Windows:** `winget configure`, whose repository rules require the vendor's own installer.
- **Homebrew:** only what is effectively brew-only on macOS: wget, luarocks, imagemagick, ghostscript, poppler, ffmpeg and AeroSpace.

Casks repackage vendor downloads with a lag, sometimes wrap a .pkg in unattended sudo prompts, and duplicate the apps' own updaters. `brew autoupdate` fired sudo prompts with no context, and casks are why one broken cask could stall the whole install.

## Consequences

- **Each vendor URL is ours to maintain.** The install-methods research lists the stable "latest" links and update feeds. Some apps have none (CleanShot X: we read Homebrew's public cask JSON only to find the vendor URL).
- **GUI apps aren't pinned.** They install the latest version once, then update themselves.
- **CLIs and runtimes are pinned,** in the mise config and `flake.lock`, and Renovate opens a weekly grouped PR to bump them.
- **Apps that need a sign-in or approval to download** (Affinity, Rex) become steps in the fresh-machine wizard rather than script entries.
