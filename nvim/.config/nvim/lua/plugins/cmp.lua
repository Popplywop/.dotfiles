return {
  {
    "hrsh7th/nvim-cmp",
    init = function()
      vim.g.cmptoggle = true
      vim.keymap.set(
        "n",
        "<leader><tab>",
        function()
          vim.g.cmptoggle = not vim.g.cmptoggle
          print("Completion set to:", vim.g.cmptoggle)
        end,
        { desc = "toggle nvim-cmp" }
      )
    end,
    ---@params opts cmp.ConfigSchema
    opts = function(_, opts)
      opts.enabled = function()
        return vim.g.cmptoggle
      end

      local cmp = require("cmp")

      opts.snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      }

      opts.view = {
        entries = "custom", -- custom, native, wildmenu
      }

      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }

      opts.preselect = cmp.PreselectMode.None

      opts.mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
      })

      opts.sources = {
        { name = "nvim_lua" }, -- plugin excludes itself from non-lua buffers
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "luasnip" },
        { name = "buffer",  keyword_length = 3 },
      }

      ---@diagnostic disable-next-line: missing-fields
      opts.formatting = {
        format = require("lspkind").cmp_format({
          mode = "symbol_text", -- show symbol + text annotations
          maxwidth = 70, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
          ellipsis_char = "⋯", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          menu = {
            buffer   = "<buf",
            nvim_lsp = "<lsp",
            nvim_lua = "<api",
            path     = "<path",
            lua_snip = "<snip",
            cmdline  = "<cmd",
          },
        }),
      }

      cmp.setup.cmdline(":", {
        mappings = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" }
        }),
      })

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
    end,
    dependencies = {
      { "hrsh7th/cmp-buffer" },   -- completions from buffer
      { "hrsh7th/cmp-path" },     -- completions from paths
      { "hrsh7th/cmp-cmdline" },  -- completions from cmd line
      { "hrsh7th/cmp-nvim-lsp" }, -- completions from LSP
      { "hrsh7th/cmp-nvim-lua" }, -- neovim lua API
      { "onsails/lspkind.nvim" }, -- add nerd icons to completion menu sources
      {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp"
      }
    }
  },
}
