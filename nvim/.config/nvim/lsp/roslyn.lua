local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

local base_dll_path = vim.fn.stdpath("data") .. "/Microsoft.CodeAnalysis.LanguageServer/content/LanguageServer/"
local dll_path
local os_name = vim.loop.os_uname().sysname

if os_name == "Windows_NT" then
  dll_path = base_dll_path .. "win-x64/Microsoft.CodeAnalysis.LanguageServer.dll"
else
  dll_path = base_dll_path .. "linux-x64/Microsoft.CodeAnalysis.LanguageServer.dll"
end

-- Roslyn LSP configuration
if vim.fn.filereadable(dll_path) == 0 then
  print("Error: Roslyn DLL not found at " .. dll_path)
  return
end

vim.lsp.config("roslyn", {
  cmd = {
    "dotnet",
    dll_path,
    "--logLevel=Information",
    "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
    "--stdio"
  },
  root_dir = vim.fs.dirname(vim.fs.find({ ".sln" }, { upward = true })[1]) or vim.fn.getcwd(),
  filetypes = { "cs" },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
  end,
  settings = {
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = fullSolution,
      dotnet_compiler_diagnostics_scope = fullSolution
    },
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
    ["csharp|completion"] = {
      dotnet_provide_regex_completions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
    },
  },
})
