# CLAUDE.md — project rules for lplatzer/dotfiles-chezmoi

This file is merged with the global `~/.claude/CLAUDE.md` when Claude Code runs inside this directory.

---

## Key invariants

- **chezmoi naming is load-bearing.** `dot_` prefix = `.` in `$HOME`. `.tmpl` suffix = rendered Go template, suffix stripped on deploy. `private_` = chmod 600. Rename files only when you understand the target path consequence.
- **Both OS branches must stay in sync.** When adding a tool to `run_once_install-tools.sh.tmpl`, add it to both branches (Darwin / pacman) unless it is genuinely OS-specific. Document why if you skip a branch.
- **Idempotency is non-negotiable.** `run_once_` is keyed on the *rendered script hash*, so every edit to a `run_once_*` script re-runs it in full on every machine — "once" means once per version, not once per machine. Every step must therefore guard against re-running (`command -v`, file existence check, etc.). For steps that are genuinely once-per-machine and can't self-detect (system upgrades, package-index refreshes, `killall Dock`), use the `once <id> -- <cmd...>` helper in `run_once_install-tools.sh.tmpl`, which marks `${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi-once/<id>` on success. Gate network version-resolution behind the installed check too, not just the download. `set -e` is intentionally absent — failures warn but don't abort.
- **No hardcoded home paths.** Use `$HOME` or chezmoi `~` expansion. Never `/Users/lplatzer/` or `/home/lplatzer/`.
- **Vendor installers for CLIs, pnpm for JS.** Install CLIs with the vendor's own installer (Claude Code, Codex and pnpm go through `vendor_clis` in `run_once_install-tools.sh.tmpl`); never `npm install -g`, never `sudo npm`. pnpm for JS projects. Node 24 via mise. Scripts are TypeScript run directly by Node (type stripping, so a `.ts` file).
- **No secrets in source.** Credentials route through 1Password. The `private_dot_ssh/config.tmpl` is the pattern for anything secrets-adjacent.

## Template variables

`.is_personal`, `.name`, `.email`, `.github_email`, `.azure_name`, `.azure_email`, `.chezmoi.os`, `.chezmoi.arch` — all from `.chezmoi.toml.tmpl`. Run `chezmoi data` to inspect current values.

## macOS-only files

Add to the ignore block in `.chezmoiignore` when adding any file that should not deploy on Linux/Windows:

```
{{ if ne .chezmoi.os "darwin" }}
your-new-file
{{ end }}
```

## Verify changes before declaring done

```bash
chezmoi diff          # preview deployment impact
chezmoi cat ~/.zshrc  # verify a specific file renders correctly
```
