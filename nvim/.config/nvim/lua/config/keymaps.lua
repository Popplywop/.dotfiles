local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set('i', '<C-c>', "<Esc>")
vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('x', '<leader>p', [["_dP]])
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- move current line down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- move current line up
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- jump one page down and center
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- jump one page up and center

------ Terminal -------
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})


-- inlay hints
vim.keymap.set('n', '<leader>H', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Show inlay hints' })

------- EDITING FILES --------

-- Very specific to editing my episode_info text files used to rename .mkv files that i take from my dvds
vim.keymap.set('n', '<leader>eei', [[:%s/e01/\=printf('e%02d', line('.'))/g<CR>]],
  { desc = 'Edit episode info text file' })

-- Edit neovim config
vim.keymap.set('n', '<leader>ec', '<cmd>e ~/.dotfiles/nvim/.config/nvim/init.lua<CR>', { desc = 'Edit config files' })
