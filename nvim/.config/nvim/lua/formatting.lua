local M = {}

-- filetype -> shell command (stdin/stdout). Falls back to LSP formatting
-- when the binary isn't installed, so this is safe to leave populated even
-- before you've installed stylua/prettier.
M.formatters = {
	lua = "stylua -",
	javascript = "prettier --stdin-filepath %",
	typescript = "prettier --stdin-filepath %",
	typescriptreact = "prettier --stdin-filepath %",
	json = "prettier --stdin-filepath %",
}

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		local bufnr = args.buf
		local ft = vim.bo[bufnr].filetype
		local cmd = M.formatters[ft]
		local bin = cmd and cmd:match("^%S+")

		if cmd and vim.fn.executable(bin) == 1 then
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			local resolved = cmd:gsub("%%", bufname)

			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local input = table.concat(lines, "\n")
			local output = vim.fn.system(resolved, input)

			if vim.v.shell_error == 0 then
				local formatted = vim.split(output, "\n", { plain = true })
				if formatted[#formatted] == "" then
					table.remove(formatted)
				end
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
			end
		else
			for _, cl in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
				if cl:supports_method("textDocument/formatting") then
					vim.lsp.buf.format({ bufnr = bufnr, async = false })
					break
				end
			end
		end
	end,
})

return M
