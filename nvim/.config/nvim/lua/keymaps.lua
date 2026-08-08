-- LSP keymaps live in lua/lsp.lua (buffer-local, on LspAttach).
-- Find/grep keymaps live in lua/find.lua and lua/grep.lua.

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "move selection up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- write / quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true })

-- redo
vim.keymap.set("n", "U", "<C-r>")

-- buffers
vim.keymap.set("n", "<leader>fb", ":buffers<CR>:buffer<Space>", { desc = "switch buffer" })

-- windows
vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "window swap" })
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "window split vertical" })
vim.keymap.set("n", "<leader>wq", "<C-w>q", { desc = "window quit" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "window down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "window up" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "window left" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "window right" })

-- terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "exit terminal mode" })

-- inlay hints
vim.keymap.set("n", "<leader>H", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "toggle inlay hints" })
