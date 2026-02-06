-- Seamless navigation between tmux panes and vim splits

vim.pack.add({
  { src = "https://github.com/christoomey/vim-tmux-navigator" },
})

-- Disable default mappings (we'll replace the existing keymaps.lua mappings)
vim.g.tmux_navigator_no_mappings = 1

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Move to left pane/window", silent = true })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Move to below pane/window", silent = true })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Move to above pane/window", silent = true })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Move to right pane/window", silent = true })
