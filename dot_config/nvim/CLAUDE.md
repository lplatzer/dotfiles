# CLAUDE.md — ~/.config/nvim (LazyVim + personal layer)

This is a LazyVim adaptation, not a from-scratch config. README.md holds the full
divergence inventory — read it before changing behavior.

## Edit conventions

- One plugin spec per file in `lua/plugins/<name>.lua`, returning a lazy.nvim spec table
  (see `nvim-spider.lua` or `python.lua` for the pattern). Disabling a stock plugin also
  goes in a spec file (`disabled.lua`).
- Do not reorganize the LazyVim structure (`lua/config/` + `lua/plugins/`), rename its
  files, or touch the `init.lua` / `lua/config/lazy.lua` bootstrap beyond spec imports.
- `lua/plugins/example.lua` is inert LazyVim reference material — leave it alone.
- Custom keymaps belong in plugin spec `keys` tables, not `lua/config/keymaps.lua`,
  unless they are plugin-independent.
- Format Lua with `stylua .` (config in `stylua.toml`: 2-space indent, 120 columns).

## Generated files — never edit by hand

- `lazy-lock.json` — written by `:Lazy update` / `:Lazy restore` only.
- `lazyvim.json` — written by `:LazyExtras` only.

## Invariants

- Python LSP roles are split on purpose (`lua/plugins/python.lua`): basedpyright = IDE
  features with type checking off; ty = type diagnostics only; ruff = lint/format.
  Don't re-enable overlapping capabilities without updating the others.
- ty is installed via `uv tool install ty` (dotfiles install script), not Mason — keep
  `mason = false` on its server entry.
- Every new divergence from stock LazyVim gets a line in README.md's inventory.

## chezmoi

This directory is a chezmoi target (source: `~/.local/share/chezmoi/dot_config/nvim`).
After editing files here, run `chezmoi re-add ~/.config/nvim/<file>` so the next
`chezmoi apply` doesn't revert them. Committing the dotfiles repo is the user's call.
