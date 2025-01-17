return {
  "tpope/vim-dadbod",
  "kristijanhusak/vim-dadbod-ui",
  "kristijanhusak/vim-dadbod-completion",
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.vim_dadbod_completion_source_limits = {
      tables = 3000,
      columns = 50000,
    }
  end
}
