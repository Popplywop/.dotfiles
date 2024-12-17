local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set('i', '<C-c>', "<Esc>")
vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('x', '<leader>p', [["_dP]])

vim.keymap.set('n', '<leader>ec', '<cmd>e ~/.dotfiles/nvim/.config/nvim/init.lua<CR>', { desc = 'Edit config files' })

-- inlay hints
vim.keymap.set('n', '<leader>H', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Show inlay hints' })
