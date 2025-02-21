return {
  "mistweaverco/kulala.nvim",
  keys = {
    {
      "<leader>rs",
      function()
        require("kulala").run()
      end,
      desc = "Send Request",
    },
    {
      "<leader>ra",
      function()
        require("kulala").run_all()
      end,
      desc = "Send All Requests",
    },
    {
      "<leader>rr",
      function()
        require("kulala").replay()
      end,
      desc = "Replay Last Request",
    },
  },
  ft = { "http", "rest" },
  opts = {
    global_keymaps = false,
  },
}
