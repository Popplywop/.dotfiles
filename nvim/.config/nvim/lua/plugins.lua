-- Two deliberate exceptions to "no plugins": roslyn.nvim and oil.nvim.
--
-- The Roslyn language server needs client-side logic that isn't reasonable
-- to hand-roll into a static lsp/roslyn.lua: solution/project target
-- selection, the project-init handshake, source-generated file support.
-- roslyn.nvim's own plugin/roslyn.lua registers the "roslyn" LSP config and
-- calls vim.lsp.enable("roslyn") itself once loaded — nothing else to do
-- here.
--
-- oil.nvim replaces netrw as the file explorer: a directory is an ordinary
-- editable buffer, so renaming, creating and deleting files are normal text
-- edits plus `:w`. netrw is disabled in init.lua. Configured in lua/explorer.lua.
--
-- Installed with Neovim's built-in package manager (vim.pack), not a
-- plugin-manager framework.
vim.pack.add({
	"https://github.com/seblyng/roslyn.nvim",
	"https://github.com/stevearc/oil.nvim",
})

-- Roslyn only analyzes open buffers by default. Widen to the whole solution so
-- unopened files' errors reach vim.diagnostic and <leader>dq (quickfix).
vim.lsp.config("roslyn", {
	settings = {
		["csharp|background_analysis"] = {
			dotnet_analyzer_diagnostics_scope = "fullSolution",
			dotnet_compiler_diagnostics_scope = "fullSolution",
		},
	},
})
