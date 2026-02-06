-- Treesitter Context - Shows sticky context at the top of the buffer

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
})

require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "[c", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { desc = "Go to context" })
