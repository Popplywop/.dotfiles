-- Minimal configuration to wire nvim-notify and noice.nvim together
-- Place this file in your runtime and require it from your init.lua:
--   require('noice_notify')

local M = {}

-- safe require helper
local function safe_require(name)
  local ok, mod = pcall(require, name)
  if not ok then
    return nil
  end
  return mod
end

-- Setup nvim-notify (if installed)
local notify = safe_require('notify')
if notify then
  notify.setup({
    -- sensible defaults
    timeout = 3000,
    max_width = 80,
    stages = 'fade',
    background_colour = "#000000",
  })
  -- route vim.notify to notify
  vim.notify = notify
else
  -- fallback: ensure vim.notify exists so other code can call it
  vim.notify = vim.notify or function(msg, level)
    vim.api.nvim_echo({ { tostring(msg) } }, true, {})
  end
end

-- Setup noice (if installed)
local noice = safe_require('noice')
if noice then
  noice.setup({
    cmdline = {
      enabled = true,
      view = 'cmdline',
    },
    messages = {
      -- capture messages and route to the configured view
      enabled = true,
      view = 'notify',
    },
    notify = {
      -- enable Noice integration with vim.notify
      enabled = true,
      view = 'notify',
    },
    presets = {
      long_message_to_split = true,
      lsp_doc_border = true,
      bottom_seach = false,
      command_palette = true
    },
    routes = {
      -- show multi-line messages in a split (helpful for long outputs)
      {
        filter = { event = 'msg_show', kind = '', find = '\n' },
        view = 'split',
        opts = { enter = false, win_options = { wrap = true } },
      },
    },
  })
end

-- Create a simple :Sh command that captures shell output and notifies using vim.notify
vim.api.nvim_create_user_command('Sh', function(opts)
  local cmd = table.concat(opts.fargs, ' ')
  if cmd == '' then
    vim.notify('Usage: :Sh <shell command>', vim.log.levels.WARN)
    return
  end

  local out = vim.fn.systemlist(cmd)
  local code = vim.v.shell_error
  local body = (#out == 0 and '<no output>' or table.concat(out, '\n'))
  local title = ('sh › %s'):format(cmd)

  if code == 0 then
    vim.notify(body, vim.log.levels.INFO, { title = title })
  else
    vim.notify(body, vim.log.levels.ERROR, { title = title })
  end
end, { nargs = '*' })

-- Async variant: :ShAsync <cmd...>
vim.api.nvim_create_user_command('ShAsync', function(opts)
  if #opts.fargs == 0 then
    vim.notify('Usage: :ShAsync <command...>', vim.log.levels.WARN)
    return
  end
  local cmd = opts.fargs
  local name = table.concat(cmd, ' ')
  local stdout = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if not data then return end
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(stdout, line)
        end
      end
    end,
    on_stderr = function(_, data)
      if not data then return end
      for _, line in ipairs(data) do
        if line ~= '' then
          vim.notify(line, vim.log.levels.ERROR, { title = 'sh › ' .. name })
        end
      end
    end,
    on_exit = function(_, code)
      local body = (#stdout == 0 and '<no output>' or table.concat(stdout, '\n'))
      local level = (code == 0) and vim.log.levels.INFO or vim.log.levels.ERROR
      vim.notify(body, level, { title = ('sh › %s'):format(name) })
    end,
  })
end, { nargs = '+' })

return M
