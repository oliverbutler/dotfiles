return {
  "folke/which-key.nvim",
  event = "VimEnter",
  dependencies = {
    { "echasnovski/mini.icons", version = false },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register({
      { "<leader>c", group = "[C]ode" },
      { "<leader>c_", hidden = true },
      { "<leader>d", group = "[D]ocument" },
      { "<leader>d_", hidden = true },
      { "<leader>r", group = "[R]ename" },
      { "<leader>r_", hidden = true },
      { "<leader>s", group = "[S]earch" },
      { "<leader>s_", hidden = true },
    })
  end,
  opts = {
    -- Add any which-key configuration options here
  },
}
