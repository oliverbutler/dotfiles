-- Which-key.nvim - Displays available keybindings in popup

vim.pack.add({
	{ src = "https://github.com/folke/which-key.nvim" }
})

-----------------------------------------
-- Configuration
-----------------------------------------

require("which-key").setup({
	triggers = {
		{ "<leader>" },
		{ "s", mode = { "n", "v" } },
		{ "v", mode = { "n", "v" } },
	},
})
