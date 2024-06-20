return {
  "kevinhwang91/nvim-bqf",
  keys = {
    {
      "<leader>q",
      ":copen<CR>",
      desc = "Open quickfix window",
    },
    {
      "<leader>Q",
      ":cclose<CR>",
      desc = "Close quickfix window",
    },
  },
  config = function()
    require("bqf").setup({})
  end,
}
