-- One deliberate exception to "no plugins": roslyn.nvim.
--
-- The Roslyn language server needs client-side logic that isn't reasonable
-- to hand-roll into a static lsp/roslyn.lua: solution/project target
-- selection, the project-init handshake, source-generated file support.
-- roslyn.nvim's own plugin/roslyn.lua registers the "roslyn" LSP config and
-- calls vim.lsp.enable("roslyn") itself once loaded — nothing else to do
-- here.
--
-- Installed with Neovim's built-in package manager (vim.pack), not a
-- plugin-manager framework.
vim.pack.add({
	"https://github.com/seblyng/roslyn.nvim",
})
