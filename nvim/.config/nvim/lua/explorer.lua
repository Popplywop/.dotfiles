-- Module is named "explorer", not "oil": a lua/oil.lua here shadows
-- oil.nvim's own module on the runtimepath, so `require("oil")` below would
-- re-enter this file instead of the plugin.
require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})

vim.keymap.set("n", "-", "<cmd>Oil<CR>", { silent = true, desc = "Open parent directory" })
