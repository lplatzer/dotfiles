# CLAUDE.md — project rules for lplatzer/dotfiles-chezmoi

This file is merged with the global `~/.claude/CLAUDE.md` when Claude Code runs inside this directory.

---

## Key invariants

- **chezmoi naming is load-bearing.** `dot_` prefix = `.` in `$HOME`. `.tmpl` suffix = rendered Go template, suffix stripped on deploy. `private_` = chmod 600. Rename files only when you understand the target path consequence.
- **All three OS branches must stay in sync.** When adding a tool to `run_once_install-tools.sh.tmpl`, add it to all three branches (Darwin / pacman / apt-get) unless it is genuinely OS-specific. Document why if you skip a branch.
- **Idempotency is non-negotiable.** Every install step in `run_once_*` scripts must guard against re-running (`command -v`, file existence check, etc.). `set -e` is intentionally absent — failures warn but don't abort.
- **No hardcoded home paths.** Use `$HOME` or chezmoi `~` expansion. Never `/Users/lplatzer/` or `/home/lplatzer/`.
- **bun over npm.** Use `bun install --global` not `npm install -g`. Exception: Codex CLI currently requires npm (noted in-script).
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
