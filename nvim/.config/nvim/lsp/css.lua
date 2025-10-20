local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

return {
  cmd = { 'css-languageserver', '--stdio' },
  filetypes = { 'css', 'scss', 'less', 'html' },
  capabilities = capabilities,
  root_markers = { '.git' },
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
  end
}
