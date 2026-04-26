return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    -- Show code context (fixing scope lines to the top)
    "nvim-treesitter/nvim-treesitter-context",
  },
}
