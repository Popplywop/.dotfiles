vim.o.guifont = "JetBrainsMono:h14"

vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false

vim.o.breakindent = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.scrolloff = 8

vim.g.clipboard = "wl-copy"

vim.o.backspace = "2"
vim.o.showcmd = true
vim.o.laststatus = 2
vim.o.autowrite = true
vim.o.autoread = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.shiftround = true
vim.o.expandtab = true

vim.o.cindent = true
vim.o.wrap = false
vim.o.textwidth = 300
vim.o.softtabstop = -1

vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true
vim.o.swapfile = false
vim.o.signcolumn = "yes"

-- native LSP completion menu (see lua/lsp.lua)
vim.o.completeopt = "menuone,noselect,popup"
