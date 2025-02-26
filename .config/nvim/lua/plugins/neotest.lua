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
    "sidlatau/neotest-dart",
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
          jestCommand = "pnpm jest --expand --runInBand",
          env = {},
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
        require("neotest-dart")({
          command = "fvm flutter",
          use_lsp = true,
          custom_test_method_names = {},
        }),
      },
    })

    local M = {}

    -- Function to extract the test output and store it in a variable
    M.get_test_output = function()
      require("neotest").output.open({
        enter = true,
        short = true,
      })

      -- Wait 100ms
      vim.wait(100)

      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local test_output = table.concat(lines, "\n")

      local result =
        require("olly.core").call_typescript_function("getTestExpectedObject", { testOutput = test_output })

      vim.notify(result, "info", {
        title = "TypeScript Function Result",
        icon = "🚀",
      })

      vim.fn.setreg("+", result)

      -- Escape the output output_panel (:q)
      vim.api.nvim_command("q")

      return result
    end

    M.paste_test_output = function()
      local output = M.get_test_output()

      local bufnr = vim.api.nvim_get_current_buf()
      local cur_line = vim.api.nvim_get_current_line()

      local toEqual_pos = cur_line:find("toEqual%(") or cur_line:find("toStrictEqual%(")

      if toEqual_pos then
        -- Extract content before toEqual or toStrictEqual
        local before_toEqual = cur_line:sub(1, toEqual_pos - 1)

        -- The text after toEqual until end of line
        local after_toEqual = cur_line:sub(toEqual_pos)

        -- Find the opening parenthesis position after toEqual
        local paren_pos = after_toEqual:find("%(")

        if paren_pos then
          -- Move the cursor to the right position
          vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], toEqual_pos + paren_pos })

          -- Delete the text inside the parentheses
          vim.cmd("normal! di(")

          -- Move cursor one position to the left to be inside the parentheses
          vim.cmd("normal! h")

          -- Paste the new content
          vim.api.nvim_put(vim.fn.split(output, "\n"), "", true, true)

          vim.notify("Replaced test expectation with actual output")

          -- Save the file
          vim.cmd("write")
        else
          vim.notify("Invalid format: couldn't find opening parenthesis", vim.log.levels.ERROR)
        end
      else
        vim.notify("No toEqual or toStrictEqual found on the current line", vim.log.levels.WARN)
      end
    end

    vim.keymap.set("n", "<leader>tj", function()
      M.get_test_output()
    end, { noremap = true, silent = true, desc = "Get test output and copy to clipboard" })

    vim.keymap.set("n", "<leader>tJ", function()
      M.paste_test_output()
    end, { noremap = true, silent = true, desc = "Paste test output into toEqual/toStrictEqual" })

    vim.keymap.set("n", "<leader>ts", ":Neotest summary<CR>", { desc = "Show Neotest summary" })

    vim.keymap.set("n", "<leader>to", function()
      require("neotest").output.open({
        auto_close = true,
        short = true,
      })
    end, { desc = "[T]est [O]utput (short)" })

    vim.keymap.set("n", "<leader>tO", function()
      require("neotest").output.open({
        enter = true,
      })
    end, { desc = "[T]est [O]utput (full)" })

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
