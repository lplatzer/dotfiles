-- Python language servers.
--
-- Stack (all via the LazyVim `lang.python` extra + this override):
--   * basedpyright — completion, auto-imports, hover, go-to-definition, refactors
--   * ty (Astral)  — fast type-check diagnostics (alpha)
--   * ruff         — linting + formatting (from the extra; hover disabled there)
--
-- basedpyright is selected in lua/config/options.lua via vim.g.lazyvim_python_lsp.
-- To avoid duplicate completion entries and double type errors, we split roles:
-- basedpyright owns IDE features, ty owns type diagnostics.

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- ty: installed via `uv tool install ty` (see run_once_install-tools.sh.tmpl),
        -- NOT Mason — so tell LazyVim to skip Mason for it. cmd defaults to `ty server`.
        ty = {
          mason = false,
          -- Only surface ty's type diagnostics; let basedpyright handle completion,
          -- hover, auto-import and navigation. Drop this to let ty do those too.
          settings = {
            ty = {
              disableLanguageServices = true,
            },
          },
        },

        -- basedpyright: full IDE features. Type-checking is delegated to ty, so its
        -- own type diagnostics are turned off to prevent double-reporting.
        -- Flip typeCheckingMode to "basic"/"standard" if you'd rather have both.
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "off",
                autoImportCompletions = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
      },
    },
  },
}
