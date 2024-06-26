return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "marilari88/neotest-vitest",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-go",
  },
  -- Specifies when to load neotest
  keys = { "<leader>t" }, -- Example key bindings to trigger loading
  module = "neotest", -- Load when the neotest module is required
  cmd = { "TestFile", "TestNearest", "TestSuite", "TestLast", "TestVisit" }, -- Load for neotest commands
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-go"),
        --			require("neotest-vitest"),
        require("neotest-jest")({
          jestCommand = "pnpm jest --ci --runInBand",
          env = { CI = true },
          jestConfigFile = function(path)
            local file = vim.fn.expand("%:p")
            local new_config = vim.fn.getcwd() .. "/jest.config.ts"

            if string.find(file, "/libs/") then
              new_config = string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
            end

            -- vim.notify("Jest Config: " .. new_config)
            return new_config
          end,
          cwd = function()
            local file = vim.fn.expand("%:p")
            local new_cwd = vim.fn.getcwd()
            if string.find(file, "/libs/") then
              new_cwd = string.match(file, "(.-/[^/]+/)src")
            end

            -- vim.notify("CWD: " .. new_cwd)
            return new_cwd
          end,
        }),
      },
    })

    vim.keymap.set("n", "<leader>ts", ":Neotest summary<CR>", { desc = "Show Neotest summary" })
    vim.keymap.set("n", "<leader>to", ":Neotest output<CR>", { desc = "Show Neotest output" })

    vim.keymap.set("n", "<leader>to", function()
      require("neotest").output.open({
        auto_close = true,
      })
    end, { desc = "[T]est [O]utput" })

    vim.keymap.set("n", "<leader>tp", function()
      require("neotest").output_panel.toggle()
    end, { desc = "[T]est Output [P]anel" })

    vim.keymap.set("n", "<leader>tc", function()
      require("neotest").output_panel.clear()
    end, { desc = "[T]est [C]lear" })

    vim.keymap.set("n", "<leader>tr", function()
      require("neotest").run.run()
    end, { desc = "[T]est [R]un" })

    vim.keymap.set("n", "<leader>tl", function()
      require("neotest").run.run_last()
    end, { desc = "[T]est [L]ast" })

    vim.keymap.set("n", "<leader>tf", function()
      require("neotest").run.run(vim.fn.expand("%"))
    end, { desc = "[T]est [F]ile" })

    -- Setup test watching, running the last ran test when related files change using the neotest.watch api

    vim.keymap.set("n", "<leader>twf", function()
      require("neotest").watch.toggle(vim.fn.expand("%"))
    end, { desc = "[T]est [W]atch [File]" })

    vim.keymap.set("n", "<leader>tws", function()
      require("neotest").watch.stop()
    end, { desc = "[T]est [W]atch [S]top" })

    vim.keymap.set("n", "<leader>tww", function()
      require("neotest").watch.watch()
    end, { desc = "[T]est [W]atch" })

    -- debugging

    vim.keymap.set("n", "<leader>td", function()
      require("dapui").open()

      require("neotest").run.run({ strategy = "dap" })
    end, { desc = "[T]est [D]ebug" })
  end,
}
