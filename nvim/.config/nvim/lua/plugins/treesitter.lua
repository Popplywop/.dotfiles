return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local configs = require("nvim-treesitter.config")

      configs.setup({
        ignore_install = {},
        auto_install = true,
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "javascript",
          "html",
          "c_sharp",
          "sql"
        },
        sync_install = false,
        modules = {
          "highlight",
          "incremental_selection",
          "indent",
        },
        highlight = {
          enable = true
        },
        indent = { enable = true },
      })
    end,
  },
  {
    -- Show code context (fixing scope lines to the top)
    "nvim-treesitter/nvim-treesitter-context",
  },
}
