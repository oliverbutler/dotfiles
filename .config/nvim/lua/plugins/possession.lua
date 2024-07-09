return {
  "jedrzejboczar/possession.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local Path = require("plenary.path")

    require("possession").setup({
      session_dir = (Path:new(vim.fn.stdpath("data")) / "possession"):absolute(),
    })
  end,
}
