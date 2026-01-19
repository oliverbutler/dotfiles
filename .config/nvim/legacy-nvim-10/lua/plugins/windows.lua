return {
  "anuvyklack/windows.nvim",
  dependencies = {
    "anuvyklack/middleclass",
    "anuvyklack/animation.nvim",
  },
  keys = {
    {
      "<C-w>m",
      "<cmd>WindowsMaximize<cr>",
      desc = "Maximize window",
    },
    {
      "<C-w>e",
      "<cmd>WindowsEqualize<cr>",
      desc = "Equalize window",
    },
  },
  config = function()
    vim.o.winwidth = 10
    vim.o.winminwidth = 10
    vim.o.equalalways = false
    require("windows").setup()
  end,
}
