-- Highlight and search TODO comments

vim.pack.add({
  { src = "https://github.com/folke/todo-comments.nvim" },
})

require("todo-comments").setup({})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next TODO comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous TODO comment" })

vim.keymap.set("n", "<leader>st", function()
  ---@diagnostic disable-next-line: undefined-field
  Snacks.picker.todo_comments()
end, { desc = "Search TODO comments" })
