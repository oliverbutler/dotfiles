return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<leader>gl",
      function()
        Snacks.lazygit.open()
      end,
      desc = "Open LazyGit",
    },
    {
      "<leader>gf",
      function()
        Snacks.lazygit.log_file()
      end,
      desc = "Open file in LazyGit",
    },
    {
      "<leader>go",
      function()
        Snacks.gitbrowse.open()
      end,
    },
    {
      "<leader>n",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
  },
  config = function()
    require("snacks").setup(

      ---@type snacks.Config
      {
        dashboard = {
          enabled = true,
          sections = {
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
            { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
            { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
            {
              title = "Notifications",
              action = function()
                vim.ui.open("https://github.com/notifications")
              end,
              key = "n",
              icon = " ",
              height = 5,
              enabled = true,
            },
            { section = "startup" },
          },
        },
        lazygit = {
          enabled = true,
        },
        gitbrowse = {
          enabled = true,
        },
        notifier = {
          enabled = true,
        },
      }
    )
  end,
}
