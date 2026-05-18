# AGENTS.md — AI agent instructions for lplatzer/dotfiles-chezmoi

This file tells AI coding agents how this repository works, what conventions to follow, and what not to break.

---

## What this repository is

Dotfiles managed by [chezmoi](https://chezmoi.io). chezmoi translates files in this source directory into files deployed to `$HOME` on target machines. The naming conventions and `.tmpl` suffix are load-bearing — they control where files land and how templates are rendered.

---

## chezmoi naming conventions

| Source name | Target location | Notes |
|---|---|---|
| `dot_foo` | `~/.foo` | The `dot_` prefix becomes `.` |
| `dot_config/bar` | `~/.config/bar` | Nested paths work the same way |
| `dot_foo.tmpl` | `~/.foo` | `.tmpl` stripped; file is rendered as Go template |
| `private_dot_foo` | `~/.foo` | Same as dot_, but chezmoi sets chmod 600 |
| `run_once_*.sh` | Not deployed | Executed once on `chezmoi apply`; re-runs if content changes |
| `Brewfile.tmpl` | `~/Brewfile` | No `dot_` prefix — deploys to `$HOME/Brewfile` directly |

**Never rename files** without understanding the chezmoi convention. A rename of `dot_zshrc.tmpl` to `zshrc.tmpl` would deploy `~/zshrc` instead of `~/.zshrc`, silently breaking the shell.

---

## Template variables

All template variables come from `.chezmoi.toml.tmpl`. The prompts run once per machine and are cached in `~/.config/chezmoi/chezmoi.toml`.

| Variable | Type | Used for |
|---|---|---|
| `.name` | string | Full name in `~/.gitconfig` |
| `.email` | string | Default git identity |
| `.github_email` | string | `~/.gitconfig-github` identity |
| `.azure_name` | string | `~/.gitconfig-azure` identity |
| `.azure_email` | string | `~/.gitconfig-azure` identity |
| `.is_personal` | bool | Gates personal apps and commit signing |
| `.chezmoi.os` | builtin | `"darwin"` / `"linux"` / `"windows"` |
| `.chezmoi.arch` | builtin | `"amd64"` / `"arm64"` |

### Common template patterns

```
{{ if eq .chezmoi.os "darwin" }}...{{ end }}
{{ if ne .chezmoi.os "darwin" }}...{{ end }}
{{ if .is_personal }}...{{ end }}
{{ if and .is_personal (eq .chezmoi.os "darwin") }}...{{ end }}
{{ .name }}
{{ .email | quote }}
```

Always use `{{ ... }}` (no whitespace trimming) unless you understand when `{{- ... -}}` is needed. Malformed template syntax causes `chezmoi apply` to fail with a parse error.

---

## OS coverage

The install script (`run_once_install-tools.sh.tmpl`) handles three branches. When adding a tool, add it to all three unless it is genuinely OS-specific:

- `Darwin` — Homebrew + `brew bundle` (Brewfile.tmpl), then manual installers for things not in Homebrew
- `pacman` (Arch/CachyOS) — `pacman -S` for packaged tools, AUR via `paru` for the rest
- `apt-get` (Debian/Ubuntu/WSL) — apt + third-party repos + manual binary downloads

The `.chezmoiignore` file uses a template block to skip macOS-only source files on non-Darwin machines:

```
{{ if ne .chezmoi.os "darwin" }}
Brewfile
.hammerspoon
.aerospace.toml
{{ end }}
```

If you add a new macOS-only config file, add its basename to this block.

---

## Adding a new dotfile

1. Put the file in the source dir with the appropriate `dot_` prefix (and `.tmpl` suffix if it needs variables).
2. If the file contains secrets or should be `chmod 600`, use the `private_` prefix too.
3. If it is macOS-only, add it to the ignore block in `.chezmoiignore`.
4. Run `chezmoi diff` to verify the deployment target is correct before committing.

To add a file that already lives in `$HOME`:

```bash
chezmoi add ~/.config/somefile
```

To add it as a template (so you can inject variables):

```bash
chezmoi add --template ~/.config/somefile
```

---

## Brewfile changes

`Brewfile.tmpl` uses the `.is_personal` variable to gate personal casks:

```
{{ if .is_personal }}
cask "1password"
{{ end }}
```

Keep the non-personal section lean — it installs on all macOS machines including work laptops. Everything that is personal-only goes inside the `is_personal` block.

---

## `run_once` scripts

Scripts named `run_once_*` execute on `chezmoi apply` when their content changes (chezmoi hashes the file). They are idempotent by design — every install step guards with `command -v` or existence checks before running. Do not break idempotency.

- `run_once_install-tools.sh.tmpl` — cross-platform tool bootstrap
- `run_once_install-tools.ps1` — Windows-only tool bootstrap
- `run_once_configure-macos.sh` — macOS `defaults write` settings (exits immediately on non-Darwin)

The shell bootstrap sets `ErrorActionPreference = "Continue"` (PS) and omits `set -e` (bash) intentionally — optional installs failing should warn, not abort the entire setup session.

---

## What not to do

- Do not hardcode home directory paths as `/home/username/` or `/Users/username/` — use `$HOME` or chezmoi's `~` expansion.
- Do not introduce `npm`/`npx` — the user uses `bun`/`bunx` everywhere.
- Do not add Python scripts — TypeScript is the scripting language of choice.
- Do not add tools to only one OS branch without noting why it is intentionally omitted from the others.
- Do not add secrets, API keys, or credentials to any file — use the `private_dot_ssh/config.tmpl` pattern and route through 1Password where possible.
- Do not touch `Plans/` — it is excluded from deployment via `.chezmoiignore` and contains planning artifacts only.

---

## Testing changes

```bash
# Preview what chezmoi would change (dry run)
chezmoi diff

# Apply and watch for errors
chezmoi apply -v

# Verify a specific file renders correctly
chezmoi cat ~/.zshrc

# Check template variable values chezmoi sees
chezmoi data
```

For the install scripts, test each OS branch in an appropriate VM or container before committing. The Debian branch in particular has several third-party APT repo setups that can break when upstream key URLs change.

---

## Repo remote

```
git@github.com:lplatzer/dotfiles-chezmoi.git
```
