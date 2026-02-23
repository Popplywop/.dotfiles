if vim.g.vscode then
  require('config.vscode_keymaps')
else
  require('config.options')
  require('config.lazy')
  require('config.keymaps')
  require('config.autocommands')
  require('config.diagnostics')
  require('config.dap_keymaps')

  vim.lsp.enable({
    'luals',
    'roslyn',
    'typescript',
    'html',
    'css',
    'clangd'
  })
end
