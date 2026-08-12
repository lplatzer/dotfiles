# Neovim config

[LazyVim](https://lazyvim.org) plus a thin personal layer. Stock LazyVim behavior is not
documented here — only the divergences. If something isn't listed below, assume LazyVim
defaults.

Deployed by chezmoi. Source of truth: `~/.local/share/chezmoi/dot_config/nvim` (repo
`lplatzer/dotfiles`). After editing files here, `chezmoi re-add ~/.config/nvim/<file>` and
commit in the dotfiles repo — otherwise the next `chezmoi apply` reverts the change.

## Layout

- `init.lua` — stock bootstrap, just requires `config.lazy`
- `lua/config/lazy.lua` — lazy.nvim setup + spec imports
- `lua/config/options.lua` — option divergences (see below)
- `lua/config/{keymaps,autocmds}.lua` — stock-empty; all custom keys live in plugin specs
- `lua/plugins/*.lua` — one plugin/concern per file, auto-imported by lazy.nvim
- `lazyvim.json` — enabled extras, written by `:LazyExtras`
- `lazy-lock.json` — pinned plugin commits, written by `:Lazy update`

## Divergences from stock LazyVim

### Extras enabled

Via `lazyvim.json` (`:LazyExtras`): `editor.mini-files`, `formatting.prettier`,
`linting.eslint`, `util.dot`, `util.mini-hipatterns`, and lang extras for ansible, docker,
dotnet, git, go, haskell, markdown, python, sql, svelte, tailwind, toml, yaml.

Hardcoded in `lua/config/lazy.lua`: `lang.typescript`, `lang.json`, `lang.rust`,
`lang.python` (python is listed in both places; harmless duplication).

### Options (`lua/config/options.lua`)

- 4-space indentation (`tabstop`/`softtabstop`/`shiftwidth` = 4, `expandtab`) — LazyVim
  defaults to 2
- `winbar = "%=%m %f"` — modified flag + file path, right-aligned
- `clipboard = "unnamedplus"` — explicit system-clipboard integration
- `vim.g.lazyvim_python_lsp = "basedpyright"` — see Python section

### Colorscheme

`catppuccin-latte` (light) — `lua/plugins/theme.lua`.

### File explorer: mini.files replaces the snacks explorer

- `lua/plugins/disabled.lua` disables the snacks.nvim explorer and frees `<leader>e` /
  `<leader>E`
- `lua/plugins/extend-mini-files.lua` makes mini.files the default explorer and binds:
  `<leader>e` (directory of current file), `<leader>E` (cwd), `<leader>fm` (LazyVim root)

### Word motions: nvim-spider (`lua/plugins/nvim-spider.lua`)

`w` / `e` / `b` remapped in normal, operator-pending, and visual modes to subword-aware
motions (stops inside camelCase and snake_case).

### Search & replace: grug-far.nvim (`lua/plugins/grug-far.lua`)

Added with default setup.

### Python LSP role split (`lua/plugins/python.lua`)

Three tools, deliberately non-overlapping to avoid duplicate completions and
double-reported type errors:

- **basedpyright** (selected over default pyright via `vim.g.lazyvim_python_lsp`) — owns
  IDE features: completion, auto-imports, hover, navigation. Its own type checking is
  off (`typeCheckingMode = "off"`).
- **ty** (Astral, alpha) — owns type diagnostics only (`disableLanguageServices = true`).
  Installed via `uv tool install ty`, not Mason (`mason = false`); provisioned by the
  dotfiles `run_once_install-tools.sh.tmpl`.
- **ruff** (from the `lang.python` extra) — linting + formatting.

## Adding a plugin

Create `lua/plugins/<name>.lua` returning a lazy.nvim spec table — lazy.nvim auto-imports
every file in `lua/plugins/`. Disable stock plugins the same way (see `disabled.lua`).
`example.lua` is inert reference material; leave it alone. Add any new divergence to the
inventory above.

## Updates

- Plugins: `:Lazy update`, verify things still work, keep the resulting `lazy-lock.json`
  (then `chezmoi re-add` + commit in dotfiles). Never edit the lockfile by hand.
- Extras: `:LazyExtras` (writes `lazyvim.json`).
- Lua formatting: `stylua .` using `stylua.toml` (2-space indent, 120 columns — Lua here
  uses 2 spaces even though editor defaults are 4).
