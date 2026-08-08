-- Config for these two lives in lsp/lua_ls.lua and lsp/tsgo.lua, picked up
-- automatically from the `lsp/` folder on runtimepath.
-- roslyn enables itself (see lua/plugins.lua).
vim.lsp.enable({ "lua_ls", "tsgo" })

vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
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
