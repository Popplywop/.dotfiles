-- Plugin: folke/noice.nvim
-- Installed via store.nvim

return {
    "folke/noice.nvim",
    event = "VeryLazy",
    -- run our setup after the plugin (and its dependencies) load
    config = function()
        -- this file will configure nvim-notify and noice together
        pcall(require, 'noice_notify')
    end,
    opts = {},
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        "rcarriga/nvim-notify"
    }
}
