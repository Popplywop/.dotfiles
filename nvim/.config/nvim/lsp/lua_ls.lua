-- Neovim 0.11+ picks up files in the `lsp/` folder automatically and passes
-- the returned table straight to the LSP client.
--
-- Requires lua-language-server on $PATH (Arch: `pacman -S lua-language-server`).

return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	settings = {
		Lua = {
			-- Neovim embeds LuaJIT, not vanilla Lua 5.1.
			runtime = { version = "LuaJIT" },
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
		},
	},
}
