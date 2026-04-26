-- Plugin: nvim-mini/mini.nvim
-- Installed via store.nvim

return {
  "nvim-mini/mini.nvim",
  version = false,
  init = function()
    require('mini.surround').setup()
    require('mini.pairs').setup()
    require('mini.icons').setup()
    -- only use mini.notify if nvim-notify is not installed
    local ok = pcall(require, 'notify')
    if not ok then
      require('mini.notify').setup()
    end
  end
}
