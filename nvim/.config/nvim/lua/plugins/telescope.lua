-- Plugin: nvim-telescope/telescope.nvim
-- Installed via store.nvim

return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- optional but recommended
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make"
        }
    }
}