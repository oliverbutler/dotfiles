return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre", -- Loads on buffer read, but you can adjust based on your use-case
    config = function()
      require("gitsigns").setup()
      vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>")
      vim.keymap.set("n", "<leader>gb", ":Git blame<CR>")
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git" },
  },
  {
    "sindrets/diffview.nvim",
    event = "BufReadPre",
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

      vim.keymap.set("n", "<leader>hs", function()
        -- should make a visual selection and then call the command '<,'>DiffviewFileHistory to get line history
        vim.cmd("normal! gv")
        vim.cmd("'<,'>DiffviewFileHistory<CR>")
      end, { noremap = true, silent = true, desc = "[H]istory [S]election" })

      vim.keymap.set("v", "<leader>hs", function()
        -- Save the current position of the cursor
        local cursor_pos = vim.api.nvim_win_get_cursor(0)

        -- Get the position of the start and end of the visual selection
        local start_pos = vim.api.nvim_buf_get_mark(0, "<")
        local end_pos = vim.api.nvim_buf_get_mark(0, ">")

        -- Construct the command with the proper range
        local command = start_pos[1] .. "," .. end_pos[1] .. "DiffviewFileHistory"

        -- Execute the command
        vim.cmd(command)

        -- Get the number of lines in the current buffer
        local line_count = vim.api.nvim_buf_line_count(0)

        -- Check if the cursor's original position is within the current buffer's bounds
        if cursor_pos[1] > line_count then
          cursor_pos[1] = line_count
        end

        -- Optionally, you can also ensure the column is within bounds, but typically,
        -- setting the line is sufficient for this use case.

        -- Restore the cursor position within bounds
        vim.api.nvim_win_set_cursor(0, cursor_pos)
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
      end, { noremap = true, silent = false })
    end,
  },
}
