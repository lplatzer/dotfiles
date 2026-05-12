# Plan: Chezmoi Dotfiles — Identity, Plugins, Cross-Platform Fixes

## Context

The chezmoi repo has a solid macOS skeleton but three critical gaps make it non-functional on a
fresh machine: (1) no `dot_gitconfig.tmpl` means every machine needs manual `git config --global`;
(2) `antidote load` is wired but `.zsh_plugins.txt` doesn't exist so it loads nothing silently;
(3) the Linux pacman block installs only 6 dotfile tools and misses every LazyVim system prerequisite.

A FirstPrinciples audit of the LazyVim config revealed that `node`/`npm` is the single highest-impact
missing runtime — ts_ls, pyright, prettier, and eslint_d all install via npm, and Mason marks them as
failed silently when node is absent.

---

## Files to Create

### 1. `.chezmoi.toml.tmpl` (NEW)
Template for the chezmoi config file — defines all personal data variables.
Uses `promptStringOnce` so values are prompted once and cached; repo stays PII-free.

```toml
[data]
    name         = {{ promptStringOnce . "name" "Full name" | quote }}
    email        = {{ promptStringOnce . "email" "Personal email (default git identity)" | quote }}
    github_email = {{ promptStringOnce . "github_email" "GitHub email" | quote }}
    azure_name   = {{ promptStringOnce . "azure_name" "Azure DevOps full name" | quote }}
    azure_email  = {{ promptStringOnce . "azure_email" "Azure DevOps email" | quote }}
```

### 2. `dot_gitconfig.tmpl` (NEW)
Full gitconfig template. Key decisions:
- `gpg.ssh.program` is platform-conditional: macOS `1Password.app` path vs Linux `/usr/bin/op-ssh-sign`
- `commit.gpgsign = true` (always on — current gitconfig has empty `[commit]` block, sign should be explicit)
- `core.editor = nvim`, `core.autocrlf = input`, `core.excludesFile = ~/.gitignore_global`
- `includeIf` for both GitHub and Azure unconditionally — git's own conditional activates them only on matching remotes
- `pull.rebase = false` preserved from current config

```gitconfig
[user]
    name  = {{ .name }}
    email = {{ .email }}
[gpg]
    format = ssh
[gpg "ssh"]
{{ if eq .chezmoi.os "darwin" -}}
    program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
{{- else if eq .chezmoi.os "linux" -}}
    program = /usr/bin/op-ssh-sign
{{- end }}
[commit]
    gpgsign = true
[core]
    editor       = nvim
    autocrlf     = input
    excludesFile = ~/.gitignore_global
[init]
    defaultBranch = main
[push]
    autoSetupRemote = true
[pull]
    rebase = false
[includeIf "hasconfig:remote.*.url:https://github.com/**"]
    path = ~/.gitconfig-github
[includeIf "hasconfig:remote.*.url:https://dev.azure.com/**"]
    path = ~/.gitconfig-azure
[alias]
    lg = log --oneline --graph --decorate --all
    st = status -sb
```

### 3. `dot_gitconfig-github` (NEW — NOT a .tmpl, uses chezmoi data vars)
Actually this CAN'T use chezmoi data without being a .tmpl. Make it `dot_gitconfig-github.tmpl`.

```gitconfig
[user]
    email = {{ .github_email }}
```

### 4. `dot_gitconfig-azure.tmpl` (NEW)
```gitconfig
[user]
    name  = {{ .azure_name }}
    email = {{ .azure_email }}
```

### 5. `dot_gitignore_global` (NEW)
Standard global gitignore for a developer machine.

```
# macOS
.DS_Store
.AppleDouble
.LSOverride

# IDE
.idea/
.vscode/
*.suo
*.user
*.swp
*.swo
.nova/

# Build artifacts
node_modules/
dist/
build/
out/
.next/
.nuxt/
target/

# Logs
*.log
npm-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.*.local

# OS
Thumbs.db
ehthumbs.db
```

### 6. `dot_zsh_plugins.txt` (NEW)
Antidote plugin list. antidote's static loading model means startup cost is low even with 6-7 plugins.

```
# Completions must load before compinit
zsh-users/zsh-completions kind:fpath path:src

# Core UX
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting   # classic — user confirmed over fast-syntax-highlighting

# Useful utilities
MichaelAquilina/zsh-you-should-use
ohmyzsh/ohmyzsh path:plugins/extract
ohmyzsh/ohmyzsh path:plugins/sudo
```

Note: No git plugin — starship already shows git status; `lazygit` covers the heavy lifting.
Note: No vi-mode — not in the user's current setup.

### 7. `dot_ssh/config.tmpl` (NEW)
Replace current plain `~/.ssh/config` (which is macOS-only) with a template.

```
Host *
{{ if eq .chezmoi.os "darwin" -}}
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
{{- else if eq .chezmoi.os "linux" -}}
    IdentityAgent "~/.1password/agent.sock"
{{- end }}
```

**Important:** `dot_ssh/config.tmpl` renders to `~/.ssh/config`. The directory `dot_ssh/` maps to `~/.ssh/`.
Chezmoi will NOT create `~/.ssh/` if it doesn't exist. The `run_once_install-tools.sh` should ensure
`mkdir -p ~/.ssh && chmod 700 ~/.ssh`. Add this to the Linux block.

---

## Files to Modify

### 8. `run_once_install-tools.sh` — Expand Linux block

Current Linux block installs only 6 tools. Replace with a comprehensive CachyOS-aware block:

```bash
Linux)
    if command -v pacman >/dev/null 2>&1; then
      sudo pacman -Syu --noconfirm

      # Core tools (official repos on CachyOS/Arch)
      sudo pacman -S --noconfirm --needed \
        git wget curl \
        zellij eza zoxide atuin starship vivid \
        fzf fd ripgrep \
        neovim lazygit \
        luarocks imagemagick ghostscript \
        go rustup \
        python python-pip \
        nodejs npm \
        base-devel \
        1password-cli

      # SSH dir (required before dot_ssh/config.tmpl renders)
      mkdir -p ~/.ssh && chmod 700 ~/.ssh

      # nvm (official install script — consistent with zshrc sourcing ~/.nvm)
      if [[ ! -d "$HOME/.nvm" ]]; then
        LATEST_NVM=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest \
          | grep '"tag_name"' | cut -d'"' -f4)
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${LATEST_NVM}/install.sh" | bash
      fi

      # rustup init (only if not already initialized)
      if command -v rustup >/dev/null 2>&1; then
        rustup default stable 2>/dev/null || true
      fi

    else
      echo "Unsupported Linux package manager — install tools manually." >&2
    fi
    ;;
```

**Notes:**
- `lazygit` IS in the Arch `extra` repo — no AUR needed
- `atuin`, `vivid`, `starship` are all in Arch official repos (or CachyOS repos)
- `1password-cli` is in AUR — on CachyOS with chaotic-aur it may be pre-built; if not, paru handles it
  - Guard it: `command -v op >/dev/null || { command -v paru && paru -S --noconfirm 1password-cli; }`
- `nodejs` + `npm` critical for LazyVim's Mason to install ts_ls, pyright, prettier
- `base-devel` critical for treesitter parser compilation
- `go` + `rustup` for LazyVim lang.go and lang.rust LSP support
- nvm installs to `~/.nvm` — consistent with existing zshrc sourcing

### 9. `Brewfile` — Add missing runtimes

Add to the `# Dev tools` section:
```
brew "go"
brew "rustup"
brew "nvm"
```

**Note on nvm via brew:** `brew install nvm` installs nvm but requires a manual source line.
The existing zshrc already has the NVM_DIR/nvm.sh sourcing, so just installing is enough.
After `brew install nvm`, the user needs to run `nvm install --lts` to get a Node version.
Add a `nvm install --lts` call to the macOS section of `run_once_install-tools.sh`.

### 10. `dot_zshrc.tmpl` — Fix Intel Mac Homebrew path

Current (broken on Intel Mac):
```bash
{{ if eq .chezmoi.os "darwin" -}}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{ end -}}
```

Replace with shell-level arch check (chezmoi template is compiled before the shell runs):
```bash
{{ if eq .chezmoi.os "darwin" -}}
if [[ "$(uname -m)" == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi
{{ end -}}
```

### 11. `run_once_install-tools.ps1` — Expand Windows block

Add to the existing `Install-Tool` calls:
```powershell
Install-Tool "BurntSushi.ripgrep.MSVC" "rg"
Install-Tool "sharkdp.fd"              "fd"
Install-Tool "jqlang.jq"              "jq"
Install-Tool "junegunn.fzf"           "fzf"
Install-Tool "Neovim.Neovim"          "nvim"
Install-Tool "JesseDuffield.lazygit"  "lazygit"
Install-Tool "Git.Git"                "git"
Install-Tool "OpenJS.NodeJS.LTS"      "node"
Install-Tool "GoLang.Go"              "go"
Install-Tool "Rustlang.Rustup"        "rustup"
```

---

## nvim / LazyVim Requirements Summary

From audit of `lazyvim.json` + `lazy-lock.json` + `lazy.lua`:

| Requirement | Why | macOS (Brewfile) | Linux (pacman) | Status |
|-------------|-----|-----------------|----------------|--------|
| `node` + `npm` | ts_ls, pyright, prettier, eslint | via `nvm` | `nodejs npm` | **MISSING** |
| `go` | gopls, goimports, gofumpt | `brew "go"` | `go` | **MISSING** |
| `rustup` | rust_analyzer (runtime), stylua build | `brew "rustup"` | `rustup` | **MISSING** |
| `python3` + `pip` | ansible-ls, debugpy | system python | `python python-pip` | **MISSING on Linux** |
| `base-devel` (gcc, make) | treesitter parser compilation | Xcode CLI (present) | `base-devel` | **MISSING on Linux** |
| `ripgrep` | telescope grep, grug-far | ✅ in Brewfile | **MISSING** | partial |
| `fd` | telescope file find | ✅ in Brewfile | **MISSING** | partial |
| `lazygit` | LazyVim git UI | ✅ in Brewfile | **MISSING** | partial |
| `imagemagick` | image preview | ✅ in Brewfile | **MISSING** | partial |
| `luarocks` | some plugins | ✅ in Brewfile | **MISSING** | partial |
| `dotnet-sdk` | OmniSharp at runtime | `brew "dotnet"` | `dotnet-sdk` | **ADDING** |
| `ghcup`/`haskell-ls` | lang.haskell | NOT added | NOT added | manual setup required |

**Intentionally excluded:** haskell toolchain only — too heavy and project-specific.
**Adding dotnet:** user confirmed lang.dotnet is actively used (omnisharp in lock file).

---

## File Order / Dependency Notes

chezmoi `run_once_*` scripts execute lexicographically:
1. `run_once_install-antidote.sh` — runs first (a < c < i)
2. `run_once_install-tools.sh` — runs second
3. `run_once_configure-macos.sh` — runs third

This is correct ordering: tools installed before macOS config that may depend on them.
The new `dot_ssh/config.tmpl` depends on `~/.ssh/` existing — the `mkdir -p ~/.ssh` in the Linux
block handles this. On macOS, `~/.ssh/` typically exists already.

---

## Verification Checklist

After `chezmoi apply` on a fresh machine:

1. `cat ~/.gitconfig` — shows name/email from template, nvim editor, gpgsign=true
2. `git clone git@github.com:user/repo && cd repo && cat .git/config` — confirm GitHub identity routes
3. `antidote load && typeset -f _zsh_autosuggest_start` — confirms autosuggestions loaded
4. `nvim` — LazyVim opens, Mason installs LSPs without error for ts, go, rust, python
5. `git commit --allow-empty -m "test signing"` — signed commit succeeds via 1Password
6. `which fd rg fzf lazygit nvim starship zoxide atuin` — all resolve on all platforms

---

## Out of Scope (deferred)

- `dot_config/starship.toml` — starship works with defaults; custom config is a separate task
- `dot_config/zellij/` — zellij works with defaults
- PowerShell profile for Windows — Windows coverage is incremental, not full-parity
- Testing the Linux path without a real CachyOS machine — add README note as future task
- `dot_gitconfig-azure.tmpl` conditional via chezmoi machine type — git's own `hasconfig:` handles it
