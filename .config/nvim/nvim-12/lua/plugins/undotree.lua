-- Undotree - Visualize undo history

vim.pack.add({
	{ src = "https://github.com/mbbill/undotree" },
})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Toggle Undo Tree" })
