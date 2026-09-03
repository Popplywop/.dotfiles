---@brief
---
--- https://clangd.llvm.org
---
--- Requires clangd on $PATH (Arch: `pacman -S clang`).
---
--- clangd needs a compile_commands.json to know your flags. Generate it with
--- `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` (or `bear -- make` for plain
--- Makefiles) and either leave it in the build dir or symlink it to the root.
--- Without one, clangd falls back to guessed flags and gets headers wrong.

---@type vim.lsp.Config
return {
	cmd = {
		"clangd",
		-- clang-format style used when no .clang-format is found.
		"--fallback-style=LLVM",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--offset-encoding=utf-16",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git",
	},
	-- Lets `:LspClangdSwitchSourceHeader`-style jumps and clangd's own
	-- extensions work; harmless if unused.
	capabilities = {
		textDocument = {
			completion = {
				editsNearCursor = true,
			},
		},
		offsetEncoding = { "utf-8", "utf-16" },
	},
}
