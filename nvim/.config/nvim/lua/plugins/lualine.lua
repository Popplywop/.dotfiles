return {
  {
    -- status line enhancements
    "nvim-lualine/lualine.nvim",
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    config = function()
      require("lualine").setup({
        options = { theme = "catppuccin" },
      })
    end,
  },
}
