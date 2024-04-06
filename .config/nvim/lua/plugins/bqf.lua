return {
  "kevinhwang91/nvim-bqf",
  config = function()
    require("bqf").setup({})

    vim.keymap.set("n", "<leader>q", ":copen<CR>", { noremap = true, silent = true, desc = "Open quickfix window" })
    vim.keymap.set("n", "<leader>Q", ":cclose<CR>", { noremap = true, silent = true, desc = "Close quickfix window" })
  end,
}
