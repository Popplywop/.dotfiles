vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.have_nerd_font = true

require("options")
require("plugins")
require("colorscheme")
require("lsp")
require("completion")
require("explorer")
require("find")
require("grep")
require("autocommands")
require("formatting")
require("statusline")
require("keymaps")
