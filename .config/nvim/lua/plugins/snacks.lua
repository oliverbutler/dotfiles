return {

  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
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
      "<leader>no",
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
          preset = {
            keys = {
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              { icon = " ", key = "s", desc = "Restore Session", section = "session" },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
          },
          sections = {
            {
              section = "terminal",
              cmd = "chafa ~/.config/nvim/assets/maple-beach.jpg --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
              height = 25,
              padding = 1,
            },
            {
              pane = 2,
              { icon = " ", section = "recent_files", padding = 1 },
              { section = "keys", gap = 1, padding = 1 },
              { section = "startup" },
            },
          },
        },
        gitbrowse = {
          enabled = true,
        },
        notifier = {
          enabled = true,
        },
        image = {
          enabled = true,
        },
      }
    )
  end,
}
