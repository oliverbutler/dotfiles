return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = { "<leader>e", "<leader>E" }, -- Example key bindings to trigger loading
    cmd = { "NvimTreeToggle", "NvimTreeFocus" }, -- These commands will trigger the lazy loading
    config = function()
      require("nvim-tree").setup({
        update_cwd = true,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        view = {
          width = 40,
        },
      })

      vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { noremap = true })
      vim.keymap.set("n", "<leader>E", vim.cmd.NvimTreeFocus, { noremap = true })
    end,
  },
}
