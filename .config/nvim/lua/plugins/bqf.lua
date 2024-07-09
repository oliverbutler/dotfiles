return {
  "kevinhwang91/nvim-bqf",
  keys = {
    {
      "<leader>Q",
      ":copen<CR>",
      desc = "Open quickfix window",
    },
  },
  config = function()
    require("bqf").setup({})
  end,
}
