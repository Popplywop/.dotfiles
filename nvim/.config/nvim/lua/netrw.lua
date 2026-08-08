-- netrw tuned to feel like oil.nvim: one directory per buffer, no banner,
-- `-` opens the parent directory in place of the current buffer.
vim.g.netrw_liststyle = 0 -- flat listing, not the nested tree view
vim.g.netrw_banner = 0 -- hide the top banner
vim.g.netrw_keepdir = 0 -- cwd follows the browsed directory
vim.g.netrw_browse_split = 0 -- open files in the previous window, not a new split
vim.g.netrw_altfile = 1 -- keep the alternate file correct

-- oil.nvim's signature keymap.
vim.keymap.set("n", "-", "<cmd>Explore<CR>", { silent = true, desc = "Open parent directory" })

-- netrw already has oil-equivalent buffer ops built in, worth knowing:
--   %  create file   d  create dir    D  delete (marked / under cursor)
--   R  rename        mf mark file     mc copy marked      mm move marked
--   o/v split-open   p  preview       s  change sort

-- netrw's built-in `%` opens new files in the netrw window instead of
-- respecting `netrw_browse_split`. Override it to open in the previous window.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.keymap.set("n", "%", function()
			local fname = vim.fn.input("Enter filename: ")
			if fname == "" then
				return
			end

			local dir = vim.b.netrw_curdir or vim.fn.getcwd()
			local path = dir .. "/" .. fname

			if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
				vim.notify("Already exists: " .. fname, vim.log.levels.WARN)
				return
			end

			if fname:match("/$") then
				vim.fn.mkdir(path, "p")
				vim.cmd("edit")
			else
				local f = io.open(path, "w")
				if not f then
					vim.notify("Failed to create: " .. fname, vim.log.levels.ERROR)
					return
				end
				f:close()

				local escaped = vim.fn.fnameescape(path)
				if vim.fn.winnr("#") == 0 then
					vim.cmd("edit " .. escaped)
				else
					vim.cmd("wincmd p")
					vim.cmd("edit " .. escaped)
				end
			end
		end, { buffer = true, silent = true, noremap = true, desc = "Create file in previous window" })
	end,
})
