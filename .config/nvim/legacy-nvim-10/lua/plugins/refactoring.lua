return {
  "ThePrimeagen/refactoring.nvim",
  cmd = "Refactor",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    {
      "<leader>rp",
      function()
        require("refactoring").debug.printf({})
      end,
      mode = "n",
      desc = "Printf",
    },
    {
      "<leader>rv",
      function()
        require("refactoring").debug.print_var({})
      end,
      mode = { "n", "x" },
      desc = "Print the variable under the cursor",
    },
    {
      "<leader>rk",
      function()
        require("refactoring").debug.cleanup({})
      end,
      "Cleanup all debugs",
    },
    {
      "<leader>re",
      function()
        require("refactoring").refactor("Extract Function")
      end,
      desc = "Extract Function",
      mode = "x",
    },
  },
  config = function()
    require("refactoring").setup({})
  end,
}
