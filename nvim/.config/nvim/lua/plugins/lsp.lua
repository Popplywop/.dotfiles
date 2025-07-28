return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = false,
      ensure_installed = {
        "lua_ls",
        "fsautocomplete",
        "sqls",
      },
      inlay_hints = { enabled = true },
    },
    dependencies = {
      {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = {
          PATH = "prepend",
          registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry", -- Add custom registry for Roslyn
          },
        },
      },
    },
  },
  {
    "folke/lazydev.nvim",
    opts = {},
  },
  {
    "ionide/Ionide-vim",
  },
  {
    "nanotee/sqls.nvim",
    lazy = false,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require("lspconfig")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local keymap = function(mode, key, action, bufnr, desc)
        vim.keymap.set(mode, key, action, { buffer = bufnr, remap = false, desc = desc })
      end

      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Existing Lua LSP configuration
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "require", "nnoremap", "love" },
            },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
      })

      -- Existing SQLs LSP configuration
      lspconfig.sqls.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          require("sqls").on_attach(client, bufnr)
          keymap({ "n", "v" }, "<leader>rq", "<cmd>SqlsExecuteQuery<CR>", bufnr, "[R]un Query")
          keymap("n", "<leader>sd", "<cmd>SqlsSwitchDatabase<CR>", bufnr, "[S]witch Database")
        end,
      })

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
  },
}
