-- Plugin: junnplus/lsp-setup.nvim
-- Installed via store.nvim

return {
  "junnplus/lsp-setup.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim" -- optional
  },
  ---@type LspSetup.Options
  opts = {
    servers = {
      clangd = {},
      html = {},
      lua_ls = {},
      vtsls = {},
      gopls = {},
      zls = {},
      -- roslyn is managed by roslyn.nvim, NOT mason-lspconfig — do not add here
    }
  }
}
