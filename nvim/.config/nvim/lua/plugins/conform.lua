return {
  'stevearc/conform.nvim',
  config = function()
    require("conform").setup({
      formatters = {
        sqlfluff = {
          command = vim.fn.expand("$HOME/.local/bin/sqlfluff")
        }
      }
    })
  end
}
