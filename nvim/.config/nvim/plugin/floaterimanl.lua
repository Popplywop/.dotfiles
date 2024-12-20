vim.keymap.set('t', '<C-t>', '<c-\\><c-n>')

local state = {
  floating = {
    buf = -1,
    win = -1
  }
}
local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or 0.8
  local height = opts.height or 0.8

  local win_width = math.floor(vim.o.columns * width)
  local win_height = math.floor(vim.o.lines * height)
  local row = math.floor((vim.o.lines - win_height) / 2)
  local col = math.floor((vim.o.columns - win_width) / 2)

  local buf = nil

  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded'
  })

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= "terminal" then
      vim.cmd.term()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set({ 'n', 't' }, '<space>tt', toggle_terminal)
