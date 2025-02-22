return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      --- stylua: ignore
      {
        "<leader>gp",
        function()
          require("gitsigns").preview_hunk()
        end,
        desc = "Preview hunk",
      },
      {
        "<leader>gi",
        function()
          require("gitsigns").preview_hunk_inline()
        end,
        desc = "Preview hunk inline",
      },
    },
  },
  {
    "FabijanZulj/blame.nvim",
    opts = {},
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<CR>", desc = "Toggle Git Blame" },
    },
  },
  {
    "sindrets/diffview.nvim",
    opts = {},
    init = function()
      -- Set diagonal lines in place of deleted lines in diff-mode
      vim.opt.fillchars:append({ diff = "╱" })
    end,
    keys = {
      { "<leader>hf", ":DiffviewFileHistory %<CR>", desc = "File History" },
      { "<leader>ha", ":DiffviewFileHistory<CR>", desc = "History All" },
      { "<leader>hc", ":DiffviewClose<CR>", desc = "History Close" },
      { "<leader>ho", ":DiffviewOpen<CR>", desc = "History Open" },
      { "<leader>hs", ":DiffviewFileHistory<CR>", mode = "v", desc = "History Selection" },
      {
        "<leader>hm",
        function()
          local mainOrMaster = "master"
          if vim.fn.executable("git") == 1 then
            local result = vim.fn.system("git rev-parse --verify origin/main 2>/dev/null")
            if vim.v.shell_error == 0 then
              mainOrMaster = "main"
            end
          end
          vim.cmd("DiffviewOpen origin/" .. mainOrMaster .. "...HEAD")
        end,
        desc = "History Master",
      },
      {
        "<leader>gp",
        function()
          local word = vim.fn.expand("<cword>")
          if not word:match("^%x+$") or word:len() < 7 or word:len() > 40 then
            vim.notify("Invalid or no Git SHA selected", vim.log.levels.ERROR)
            return
          end
          local sha_only = word .. "^!"
          local status_ok, err = pcall(vim.cmd, "DiffviewOpen " .. sha_only)
          if not status_ok then
            vim.notify("Failed to open diff for SHA: " .. word .. "\nError: " .. err, vim.log.levels.ERROR)
          end
        end,
        desc = "Git Preview under cursor",
      },
    },
  },
}
