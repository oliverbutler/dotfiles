return {
  "folke/which-key.nvim",
  event = "VimEnter",
  dependencies = {
    { "echasnovski/mini.icons", version = false },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
  end,
  opts = {
    triggers = {
      { "<leader>" },
      { "s", mode = { "n", "v" } },
      { "v", mode = { "n", "v" } },
    },
  },
}
