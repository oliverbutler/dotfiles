return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    keys = {
      { "n", "<leader>g" },
    },
    config = function()
      require("gitsigns").setup()

      vim.keymap.set(
        "n",
        "<leader>gp",
        "<cmd>lua require('gitsigns').preview_hunk()<CR>",
        { noremap = true, silent = true, desc = "Preview hunk" }
      )

      vim.keymap.set(
        "n",
        "<leader>gi",
        "<cmd>lua require('gitsigns').preview_hunk_inline()<CR>",
        { noremap = true, silent = true, desc = "Preview hunk inline" }
      )
    end,
  },
  {
    "FabijanZulj/blame.nvim",
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<CR>" },
    },
    config = function()
      require("blame").setup()
    end,
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({})

      vim.keymap.set(
        "n",
        "<leader>hf",
        ":DiffviewFileHistory %<CR>",
        { noremap = true, silent = true, desc = "[F]ile [H]istory" }
      )
      vim.keymap.set(
        "n",
        "<leader>ha",
        ":DiffviewFileHistory<CR>",
        { noremap = true, silent = true, desc = "[H]istory [A]ll" }
      )
      vim.keymap.set(
        "n",
        "<leader>hc",
        ":DiffviewClose<CR>",
        { noremap = true, silent = true, desc = "[H]istory [C]lose" }
      )
      vim.keymap.set(
        "n",
        "<leader>ho",
        ":DiffviewOpen<CR>",
        { noremap = true, silent = true, desc = "[H]istory [O]pen" }
      )

      -- History for a PR/branch against origin/master
      vim.keymap.set("n", "<leader>hm", function()
        local mainOrMaster = "master"

        if vim.fn.executable("git") == 1 then
          local branch = vim.fn.systemlist("git branch --show-current")[1]
          if branch == nil then
            vim.notify("No branch found", vim.log.levels.ERROR)
            return
          end

          if branch == "main" then
            mainOrMaster = "main"
          end
        end

        vim.cmd("DiffviewOpen origin/" .. mainOrMaster .. "...HEAD")
      end, { noremap = true, silent = true, desc = "[H]istory [M]aster" })

      vim.keymap.set("n", "<leader>hs", function()
        -- should make a visual selection and then call the command '<,'>DiffviewFileHistory to get line history
        vim.cmd("normal! gv")
        vim.cmd("'<,'>DiffviewFileHistory<CR>")
      end, { noremap = true, silent = true, desc = "[H]istory [S]election" })

      vim.keymap.set("v", "<leader>hs", function()
        -- Get the position of the start and end of the visual selection
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")

        -- Construct the command with the proper range and options
        local command = string.format("%d,%dDiffviewFileHistory --follow %%", start_pos[2], end_pos[2])

        -- Execute the command
        vim.cmd(command)
      end, { noremap = true, silent = true, desc = "[H]istory [S]election" })

      vim.keymap.set("n", "<leader>gp", function()
        -- Get the word under the cursor, which is presumed to be a SHA
        local word = vim.fn.expand("<cword>")

        -- Basic validation of the SHA: length and character check (simplistic)
        if not word:match("^%x+$") or word:len() < 7 or word:len() > 40 then
          vim.notify("Invalid or no Git SHA selected", vim.log.levels.ERROR)
          return
        end

        local sha_only = word .. "^!"

        -- Attempt to open the diff view for the SHA
        local status_ok, err = pcall(vim.cmd, "DiffviewOpen " .. sha_only)
        if not status_ok then
          vim.notify("Failed to open diff for SHA: " .. word .. "\nError: " .. err, vim.log.levels.ERROR)
        end
      end, { noremap = true, silent = false, desc = "[G]it [P]review under cursor" })
    end,
  },
}
