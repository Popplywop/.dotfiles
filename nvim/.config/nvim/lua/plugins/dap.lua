return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio"
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()

      dap.adapters.coreclr = {
        type = 'executable',
        command = 'netcoredbg',
        args = {'--interpreter=vscode'}
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch - NetCoreDbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
          end
        },
        {
          type = "coreclr",
          name = "Attach - NetCoreDbg",
          request = "attach",
          processId = function()
            return vim.fn.input('Process ID: ')
          end
        }
      }
    end
  }
}
