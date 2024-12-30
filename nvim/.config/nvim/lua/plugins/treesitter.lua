return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ignore_install = {},
        auto_install = true,
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "javascript",
          "html",
          "c_sharp"
        },
        sync_install = false,
        modules = {
          "highlight",
          "incremental_selection",
          "indent",
          "rainbow",
        },
        highlight = {
          enable = true,
          disable = { "csv", }
        },
        indent = { enable = true },
      })

      local root_path = vim.fn.expand("$HOME/")

      if (vim.fn.has('win32')) then
        root_path = root_path .. "AppData/Local/nvim-data/tree-sitter-powershell"
      end

      local ts_parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
      ts_parser_configs["powershell"] = {
        install_info = {
          url = root_path,
          files = { "src/parser.c", "src/scanner.c" },
          branch = "master",
          generate_requires_npm = false,
          requires_generate_from_grammer = false,
        },
        filetype = "ps1",
      }
    end,
  },
  {
    -- Show delimiters in alternating colors
    "HiPhish/rainbow-delimiters.nvim",
  },
  {
    -- Show code context (fixing scope lines to the top)
    "nvim-treesitter/nvim-treesitter-context",
  },
}
