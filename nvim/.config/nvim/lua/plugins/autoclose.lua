return {
  {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup({
        options = {
          disabled_filetypes = { "text", "xml" },
          pair_spaces = true
        },
      })
    end
  }
}
