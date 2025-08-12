if vim.g.vscode then
  require('config.vscode_keymaps')
else
  require('config.options')
  require('config.lazy')
  require('config.keymaps')
  require('config.autocommands')
  require('config.diagnostics')

  vim.lsp.enable({ 'luals', 'rosyln' })
end
