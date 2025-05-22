return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.opt.background = "dark"
      vim.cmd.colorscheme("catppuccin")
    end,
    opts = {
      flavor = "auto",
      background = {
        light = "latte",
        dark = "macchiato"
      },
      transparent_background = true,
      default_integrations = true,
      integrations = {
        which_key = true,
      }
    }
  }
}
