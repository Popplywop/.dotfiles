vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true
})

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostic for line" })
