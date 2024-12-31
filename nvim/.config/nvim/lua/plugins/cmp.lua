local function cmp_setup()
  local cmp     = require("cmp")
  -- lspkind.lua
  local lspkind = require("lspkind")

  require("luasnip.loaders.from_vscode").lazy_load()

  -- initialize global var to false -> nvim-cmp turned off per default
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

  cmp.setup({
    enabled = function()
      return vim.g.cmptoggle
    end,
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    view = {
      entries = "custom", -- custom, native, wildmenu
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    preselect = cmp.PreselectMode.None,
    completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = {
      { name = "nvim_lua" }, -- plugin excludes itself from non-lua buffers
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "luasnip" },
      { name = "buffer",  keyword_length = 3 },
      { name = "copilot" },
    },
    ---@diagnostic disable-next-line: missing-fields
    formatting = {
      format = lspkind.cmp_format({
        mode = "symbol_text", -- show symbol + text annotations
        maxwidth = 70, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        ellipsis_char = "⋯", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
        menu = {
          buffer    = "<buf",
          nvim_lsp  = "<lsp",
          nvim_lua  = "<api",
          path      = "<path",
          lua_snip  = "<snip",
          gh_issues = "<git",
          ctags     = "<tag",
          copilot   = "<ia",
        },
        symbol_map = {
          Copilot = "",
        }
      }),
    },
  })
  -- Set configuration for specific filetype.
  cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
      { name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
      { name = "buffer" },
    }),
  })
  cmp.setup.filetype("sql", {
    sources = cmp.config.sources({
      { name = "vim-dadbod-completion" },
      { name = "buffer" },
      { name = "copilot" },
    })
  })
end

return {
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end
  },
  -- Autocompletion
  { "hrsh7th/nvim-cmp",            config = cmp_setup },
  { "hrsh7th/cmp-buffer" },   -- completions from buffer
  { "hrsh7th/cmp-path" },     -- completions from paths
  { "hrsh7th/cmp-cmdline" },  -- completions from cmd line
  { "hrsh7th/cmp-nvim-lsp" }, -- completions from LSP
  { "hrsh7th/cmp-nvim-lua" }, -- neovim lua API

  -- Snippets
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },     -- LuaSnip completions
  { "rafamadriz/friendly-snippets" }, -- vscode-like snippes

  -- UI
  { "onsails/lspkind.nvim" }, -- add nerd icons to completion menu sources

}
