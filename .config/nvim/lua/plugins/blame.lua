-- Blame.nvim - Git blame annotations

vim.pack.add({
	{ src = "https://github.com/FabijanZulj/blame.nvim" },
})

-----------------------------------------
-- Configuration
-----------------------------------------

require("blame").setup({})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>gb", "<cmd>BlameToggle<CR>", { desc = "Toggle Git Blame" })
