local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

vim.lsp.config['clangd'] = {
  -- Command and arguments to start the server.
  cmd = { 'clangd', '--suggest-missing-includes', '--clang-tidy', '--fallback-style="llvm"' },
  -- Filetypes to automatically attach to.
  filetypes = { 'c' },
  -- Sets the "workspace" to the directory where any of these files is found.
  -- Files that share a root directory will reuse the LSP server connection.
  -- Nested lists indicate equal priority, see |vim.lsp.Config|.
  root_markers = { '.git', 'Makefile', 'CMakeLists.txt' },
  capabilities = capabilities
}
