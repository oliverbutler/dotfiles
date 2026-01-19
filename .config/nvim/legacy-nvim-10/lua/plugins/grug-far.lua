return {
  "MagicDuck/grug-far.nvim",
  keys = {
    {
      "<leader>fr",
      ":GrugFar<CR>",
      desc = "Open GrugFar",
    },
  },
  config = function()
    require("grug-far").setup({})
  end,
}
