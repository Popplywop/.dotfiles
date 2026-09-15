-- Config for these lives in lsp/clangd.lua, lsp/lua_ls.lua and lsp/tsgo.lua, picked up
-- automatically from the `lsp/` folder on runtimepath.
-- roslyn enables itself (see lua/plugins.lua).
vim.lsp.enable({ "clangd", "lua_ls", "tsgo" })

vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
})

-- Diagnostics are pushed by the server (textDocument/publishDiagnostics) and
-- cached by vim.diagnostic, so navigating them is a local lookup -- no
-- request round-trip. These are global, not buffer-local on LspAttach:
-- vim.diagnostic is the shared sink for every producer, LSP or not.
--
-- Nvim already maps ]d/[d (any severity), ]D/[D (first/last) and <C-w>d
-- (float for the diagnostic under the cursor). Added here: the same motions
-- restricted to warnings and errors, and the two list views.
local at_least_warn = { severity = { min = vim.diagnostic.severity.WARN } }

vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump(vim.tbl_extend("error", at_least_warn, { count = vim.v.count1 }))
end, { desc = "next warning/error" })

vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump(vim.tbl_extend("error", at_least_warn, { count = -vim.v.count1 }))
end, { desc = "previous warning/error" })

-- Current buffer to the location list, every buffer to the quickfix list.
vim.keymap.set("n", "<leader>dd", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "buffer diagnostics (loclist)" })

vim.keymap.set("n", "<leader>dq", function()
	vim.diagnostic.setqflist({ open = true })
end, { desc = "all diagnostics (quickfix)" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf)
		end

		local keymap = function(mode, key, action, desc)
			vim.keymap.set(mode, key, action, { buffer = ev.buf, remap = false, desc = desc })
		end

		keymap("n", "gd", vim.lsp.buf.definition, "go to definition (LSP)")
		keymap("n", "gD", vim.lsp.buf.declaration, "go to declaration (LSP)")
		keymap("n", "gr", vim.lsp.buf.references, "go to [r]eferences (LSP)")
		keymap("n", "gi", vim.lsp.buf.implementation, "go to implementation (LSP)")
		keymap("n", "gK", vim.lsp.buf.hover, "show info (LSP)")
		keymap("n", "R", vim.lsp.buf.rename, "rename symbol (LSP)")
		keymap("n", "g=", vim.lsp.buf.format, "reformat (LSP)")
		keymap("v", "g=", function()
			local start_row = vim.api.nvim_buf_get_mark(0, "<")[1]
			local end_row = vim.api.nvim_buf_get_mark(0, ">")[1]
			vim.lsp.buf.format({
				range = { ["start"] = { start_row, 0 }, ["end"] = { end_row, 0 } },
				async = true,
			})
		end, "reformat range (LSP)")
		keymap("n", "<C-k>", vim.lsp.buf.signature_help, "signature help (LSP)")
		keymap("n", "<space>D", vim.lsp.buf.type_definition, "type definition (LSP)")
		keymap({ "n", "v" }, "<space>ca", function()
			vim.lsp.buf.code_action({ apply = true })
		end, "code action (LSP)")
	end,
})
