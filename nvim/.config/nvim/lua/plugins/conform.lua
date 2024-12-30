return {
  'stevearc/conform.nvim',
  config = function ()
    require("conform").setup({
      formatters_by_ft = {
        sql = { "sqlfluff", lsp_format = "fallback" }
      }
    })
  end
}
