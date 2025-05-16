if vim.g.vscode then
  require('config.vscode_keymaps')
else
  require('config.options')
  require('config.lazy')
  require('config.keymaps')
end
