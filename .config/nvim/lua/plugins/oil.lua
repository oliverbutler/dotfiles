return {
  "stevearc/oil.nvim",
  cmd = "Oil",
  keys = {
    {
      "-",
      "<cmd>Oil<cr>",
      desc = "Open parent directory",
    },
    {
      "<leader>e",
      "<cmd>Oil<cr>",
      desc = "Open parent directory",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
    })
  end,
}
