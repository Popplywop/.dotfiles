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
vim.keymap.set("n", "<C-d>", "<C-d>zz")      -- jump one page down and center
vim.keymap.set("n", "<C-u>", "<C-u>zz")      -- jump one page up and center

-- remap <C-w>w to <leader>w
-- This may go back to normal when i get a split keyboard?
vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Window Swap" })
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Window Split Vertical" })
vim.keymap.set("n", "<leader>wq", "<C-w>q", { desc = "Window Quit" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Window Down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Window Up" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Window Left" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Window Right" })

-- inlay hints
vim.keymap.set('n', '<leader>H', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Show inlay hints' })

vim.keymap.set({ 'n', 't' }, '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })
