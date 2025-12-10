return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    init = function()
      vim.opt.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
    opts = {
      transparent_mode = true,
      contrast = "hard",
      integrations = {
        which_key = true,
      }
    }
  }
}
