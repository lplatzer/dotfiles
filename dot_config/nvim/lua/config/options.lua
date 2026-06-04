-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use basedpyright (not the default pyright) as the Python language server.
-- ty (Astral) is added as a second server in lua/plugins/python.lua.
vim.g.lazyvim_python_lsp = "basedpyright"

vim.opt.winbar = "%=%m %f"

vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.clipboard = "unnamedplus"
