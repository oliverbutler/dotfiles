return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>du",
        "<cmd>lua require('dapui').toggle()<CR>",
        noremap = true,
        silent = true,
        desc = "Toggle DAP UI",
      },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }

      for _, language in ipairs({ "typescript", "javascript" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            -- trace = true, -- include debugger info
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
          },
        }
      end

      require("dap-go").setup({

        -- Additional dap configurations can be added.
        -- dap_configurations accepts a list of tables where each entry
        -- represents a dap configuration. For more details do:
        -- :help dap-configuration
        dap_configurations = {
          {
            -- Must be "go" or it will be ignored by the plugin
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        -- delve configurations
        delve = {
          -- the path to the executable dlv which will be used for debugging.
          -- by default, this is the "dlv" executable on your PATH.
          path = "dlv",
          -- time to wait for delve to initialize the debug session.
          -- default to 20 seconds
          initialize_timeout_sec = 20,
          -- a string that defines the port to start delve debugger.
          -- default to string "${port}" which instructs nvim-dap
          -- to start the process in a random available port
          port = "${port}",
          -- additional args to pass to dlv
          args = {},
          -- the build flags that are passed to delve.
          -- defaults to empty string, but can be used to provide flags
          -- such as "-tags=unit" to make sure the test suite is
          -- compiled during debugging, for example.
          -- passing build flags using args is ineffective, as those are
          -- ignored by delve in dap mode.
          build_flags = "",
        },
      })

      vim.keymap.set(
        "n",
        "<leader>db",
        "<cmd>lua require('dap').toggle_breakpoint()<CR>",
        { noremap = true, silent = true, desc = "Toggle breakpoint" }
      )
      vim.keymap.set(
        "n",
        "<leader>dc",
        "<cmd>lua require('dap').continue()<CR>",
        { noremap = true, silent = true, desc = "Continue" }
      )
      vim.keymap.set(
        "n",
        "<leader>ds",
        "<cmd>lua require('dap').step_over()<CR>",
        { noremap = true, silent = true, desc = "Step over" }
      )
      vim.keymap.set(
        "n",
        "<leader>di",
        "<cmd>lua require('dap').step_into()<CR>",
        { noremap = true, silent = true, desc = "Step into" }
      )
      vim.keymap.set(
        "n",
        "<leader>do",
        "<cmd>lua require('dap').step_out()<CR>",
        { noremap = true, silent = true, desc = "Step out" }
      )
      vim.keymap.set(
        "n",
        "<leader>dq",
        "<cmd>lua require('dap').disconnect()<CR>",
        { noremap = true, silent = true, desc = "Disconnect" }
      )
    end,
  },
}
