return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      PATH = "prepend"
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "cssls",
          "html",
          "omnisharp",
          "jsonls",
          "ts_ls"
        },
        opts = { inlay_hints = { enabled = true } }
      })
    end,
  },
  {
    "folke/neodev.nvim",
    config = function()
      require("neodev").setup({})
    end,
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufnewFile" },
    config = function()
      require("neodev").setup({})

      local lspconfig = require("lspconfig")

      local omnisharp_path = vim.fn.expand("$HOME/.config/Omnisharp/OmniSharp.dll")
      local ps_path = vim.fn.expand("$HOME/.config/PowerShellEditorServices/")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local keymap = function(mode, key, action, bufnr, desc)
        vim.keymap.set(mode, key, action, { buffer = bufnr, remap = false, desc = desc })
      end

      capabilities = vim.tbl_deep_extend('force', capabilities, require("cmp_nvim_lsp").default_capabilities())

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "require", "nnoremap", "love" },
            },
            telemetry = { enable = false, },
            hint = { enable = true }
          }
        }
      })
      lspconfig.cssls.setup({
        capabilities = capabilities,
      })
      lspconfig.html.setup({
        capabilities = capabilities,
      })
      lspconfig.eslint.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })
      lspconfig.jsonls.setup({
        capabilities = capabilities,
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.omnisharp.setup({
        cmd = { "dotnet", omnisharp_path },
        on_attach = function(client, bufnr)
          local omnisharp_extended = require("omnisharp_extended")
          keymap("n", "<leader>ogd", function() omnisharp_extended.lsp_definition() end, bufnr,
            "[O]mnisharp Go To Definition")
          keymap("n", "<leader>ogD", function() omnisharp_extended.lsp_type_definition() end, bufnr,
            "[O]mnisharp Go To Type Definition")
          keymap("n", "<leader>ogr", function() omnisharp_extended.lsp_references() end, bufnr,
            "[O]mnisharp Go To References")
          keymap("n", "<leader>ogi", function() omnisharp_extended.lsp_implementation() end, bufnr,
            "[O]mnisharp Go To Implementations")

          vim.api.nvim_create_autocmd("InsertLeave", {
            buffer = bufnr,
            command = "w"
          })

          vim.opt.tabstop = 4
          vim.opt.shiftwidth = 4
          vim.opt.shiftround = true
          vim.opt.expandtab = true
        end,
        capabilities = capabilities,
        root_dir = function(fname)
          local primary = require("lspconfig.util").root_pattern("*.sln")(fname)
          local fallback = require("lspconfig.util").root_pattern("*.csproj")(fname)
          return primary or fallback
        end,
      })

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

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          local keymap = function(mode, key, action, desc)
            vim.keymap.set(mode, key, action, { buffer = ev.buf, remap = false, desc = desc })
          end

          keymap("n", "gd", vim.lsp.buf.definition, "go to definition (LSP)")
          keymap("n", "gD", vim.lsp.buf.declaration, "go to declaration (LSP)")
          keymap("n", "gr", vim.lsp.buf.references, "go to [r]eferences (LSP)")
          keymap("n", "gi", vim.lsp.buf.implementation, "goto implementation (LSP)")
          keymap("n", "gK", vim.lsp.buf.hover, "show info (LSP)")     -- K is now default for show_info
          keymap("n", "R", vim.lsp.buf.rename, "rename symbol (LSP)") -- default is <F2>
          keymap("n", "g=", vim.lsp.buf.format, "reformat (LSP)")
          keymap("v", "g=", RangeFormat, "reformat (LSP)")
          keymap("n", "gl", vim.lsp.diagnostic.get_line_diagnostics, "line diagnostic (LSP)")
          keymap("n", "<C-k>", vim.lsp.buf.signature_help, "signature help (LSP)")
          keymap("n", "<space>wa", vim.lsp.buf.add_workspace_folder, "add workspace folder (LSP)")
          keymap("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, "remove workspace folder (LSP)")
          keymap("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "(LSP) list workspace folders")
          keymap("n", "<space>D", vim.lsp.buf.type_definition, "type definition (LSP)")
          keymap({ "n", "v" }, "<space>ca", function()
            vim.lsp.buf.code_action({ apply = true })
          end, "code action (LSP)")
        end,
      })
    end,
  }
}
