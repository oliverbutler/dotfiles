return {
  "anuvyklack/windows.nvim",
  dependencies = {
    "anuvyklack/middleclass",
    "anuvyklack/animation.nvim",
  },
  keys = {
    {
      "<C-w>z",
      "<cmd>WindowsMaximize<cr>",
      desc = "Maximize window",
    },
    {
      "<C-w>_",
      "<cmd>WindowsMaximizeVertically<cr>",
      desc = "Maximize window vertically",
    },
    {
      "<C-w>|",
      "<cmd>WindowsMaximizeHorizontally<cr>",
      desc = "Maximize window horizontally",
    },
    {
      "<C-w>=",
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
