return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavor = "auto",
        background = {
          light = "latte",
          dark = "mocha"
        },
        transparent_background = true,
        default_integrations = true,
        integrations = {
          which_key = true,
        }
      })
      vim.opt.background = "light"
      vim.cmd.colorscheme("catppuccin")
    end
  }
}
