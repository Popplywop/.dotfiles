vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.guifont = "Monofur Nerd Font Regular:h14"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false

vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.scrolloff = 8

vim.g.clipboard = 'wl-copy'

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.autoread = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.cindent = true
vim.opt.wrap = false
vim.opt.textwidth = 300
vim.opt.softtabstop = -1

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.swapfile = false

vim.opt.directory = vim.fn.stdpath('data') .. 'tmp'
vim.opt.undodir = vim.fn.stdpath('data') .. 'undo'

vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'None' })
vim.opt.hlsearch = false

-- vim.highlight.create('WinSeparator', { guibg = none }, false)
vim.g['netrw_banner'] = 0
vim.g['netrw_liststyle'] = 3
vim.g['netrw_winsize'] = 25
