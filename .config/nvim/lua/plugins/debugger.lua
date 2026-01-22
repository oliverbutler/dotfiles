-- Debug Adapter Protocol (DAP) for debugging

vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  { src = "https://github.com/leoluz/nvim-dap-go" },
  { src = "https://github.com/nvim-neotest/nvim-nio" }, -- Required dependency for nvim-dap-ui
})

local dap = require("dap")
local dapui = require("dapui")

-----------------------------------------
-- DAP UI Setup
-----------------------------------------

dapui.setup()

-----------------------------------------
-- Virtual Text Setup
-----------------------------------------

require("nvim-dap-virtual-text").setup()

-----------------------------------------
-- Node/JavaScript/TypeScript Adapter
-----------------------------------------

-- Lazily configure the adapter when first needed
dap.adapters["pwa-node"] = function(callback, config)
  local mason_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"
  local js_debug_adapter_path = mason_path .. "/js-debug-adapter"

  callback({
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = js_debug_adapter_path,
      args = { "${port}" },
    },
  })
end

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

-----------------------------------------
-- Go Adapter Setup
-----------------------------------------

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

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Toggle DAP UI" })

vim.keymap.set("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Toggle breakpoint" })

vim.keymap.set("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Continue" })

vim.keymap.set("n", "<leader>ds", function()
  require("dap").step_over()
end, { desc = "Step over" })

vim.keymap.set("n", "<leader>di", function()
  require("dap").step_into()
end, { desc = "Step into" })

vim.keymap.set("n", "<leader>do", function()
  require("dap").step_out()
end, { desc = "Step out" })

vim.keymap.set("n", "<leader>dq", function()
  require("dap").disconnect()
end, { desc = "Disconnect" })
