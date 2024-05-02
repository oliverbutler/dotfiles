return {
  "nvim-pack/nvim-spectre",
  keys = {
    {
      "<leader>R",
      "<cmd>lua require('spectre').toggle()<CR>",
      desc = "Toggle Spectre",
    },
    {
      "<leader>rw",
      "<cmd>lua require('spectre').open_visual({select_word=true})<CR>",
      desc = "Search current word",
    },
    {
      "<leader>rp",
      "<cmd>lua require('spectre').open_file_search({select_word=true})<CR>",
      desc = "Search on current file",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("spectre").setup()
  end,
}
