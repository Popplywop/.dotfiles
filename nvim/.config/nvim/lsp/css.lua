local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

vim.lsp.config("css", {
  cmd = { 'css-languageserver', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  capabilities = capabilities,
  root_markers = { '.git' },
  on_attach = function(client, bufnr)
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
  end
})
