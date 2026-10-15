---@brief
---
--- https://github.com/microsoft/vscode-html-languageservice
---
--- Required by roslyn.nvim's Razor support: it opens a virtual HTML buffer per
--- .cshtml/.razor file and blocks (vim.wait, up to 5s) until a client named
--- "html" attaches to it. Without this config nvim freezes on every cshtml load.
--- Install with `npm install -g vscode-langservers-extracted`.

---@type vim.lsp.Config
return {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
	root_markers = { ".git" },
	init_options = { provideFormatter = false },
}
