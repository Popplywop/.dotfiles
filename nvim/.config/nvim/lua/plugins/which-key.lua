return {
  {                     -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Sets the loading event to 'VeryLazy'
    config = function() -- This is the function that runs, AFTER loading
      local wk = require('which-key')
      wk.setup()

      -- Document existing key chains
      wk.add {
        { "<leader>c",  group = "[C]olor" },
        { "<leader>c_", hidden = true },
        { "<leader>s",  group = "[S]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>t",  group = "[T]est" },
        { "<leader>t_", hidden = true },
        { "<leader>w",  group = "[W]orkspace" },
        { "<leader>w_", hidden = true },
        { "<leader>o", group = "[O]mnisharp" },
        { "<leader>o_", hidden = true }
      }
    end,
  },
}

