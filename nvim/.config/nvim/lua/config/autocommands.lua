-- Range formatting function
local RangeFormat = function()
  local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
  local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
  vim.lsp.buf.format({
    range = {
      ["start"] = { start_row, 0 },
      ["end"] = { end_row, 0 },
    },
    async = true,
  })
end

-- Global LspAttach autocommand
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local keymap = function(mode, key, action, desc)
      vim.keymap.set(mode, key, action, { buffer = ev.buf, remap = false, desc = desc })
    end

    keymap("n", "gd", vim.lsp.buf.definition, "go to definition (LSP)")
    keymap("n", "gD", vim.lsp.buf.declaration, "go to declaration (LSP)")
    keymap("n", "gr", vim.lsp.buf.references, "go to [r]eferences (LSP)")
    keymap("n", "gi", vim.lsp.buf.implementation, "goto implementation (LSP)")
    keymap("n", "gK", vim.lsp.buf.hover, "show info (LSP)")
    keymap("n", "R", vim.lsp.buf.rename, "rename symbol (LSP)")
    keymap("n", "g=", vim.lsp.buf.format, "reformat (LSP)")
    keymap("v", "g=", RangeFormat, "reformat (LSP)")
    keymap("n", "<C-k>", vim.lsp.buf.signature_help, "signature help (LSP)")
    keymap("n", "<space>D", vim.lsp.buf.type_definition, "type definition (LSP)")
    keymap({ "n", "v" }, "<space>ca", function()
      vim.lsp.buf.code_action({ apply = true })
    end, "code action (LSP)")
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("CodeLensesRefresh", {}),
  callback = function()
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end
})
