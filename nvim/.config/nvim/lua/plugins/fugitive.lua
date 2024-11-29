return {
  {
    "tpope/vim-fugitive", -- Git integration
    cmd = "Git",
    keys = {
      { "<leader>G", vim.cmd.Git, desc = "[G]it interface" },
    },
  },
}
