-- File tagging and quick navigation

vim.pack.add({
	{ src = "https://github.com/cbochs/grapple.nvim" },
})

require("grapple").setup({
	scope = "git",
})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>m", "<cmd>Grapple toggle<cr>", { desc = "Grapple toggle tag" })
vim.keymap.set("n", "<leader>k", "<cmd>Grapple open_tags<cr>", { desc = "Grapple open tags" })
vim.keymap.set("n", "<leader>1", "<cmd>Grapple select index=1<cr>", { desc = "Grapple select 1" })
vim.keymap.set("n", "<leader>2", "<cmd>Grapple select index=2<cr>", { desc = "Grapple select 2" })
vim.keymap.set("n", "<leader>3", "<cmd>Grapple select index=3<cr>", { desc = "Grapple select 3" })
vim.keymap.set("n", "<leader>4", "<cmd>Grapple select index=4<cr>", { desc = "Grapple select 4" })
vim.keymap.set("n", "<leader>5", "<cmd>Grapple select index=5<cr>", { desc = "Grapple select 5" })
vim.keymap.set("n", "<leader>0", "<cmd>Grapple reset<cr>", { desc = "Grapple reset" })
