-- LazyDev.nvim - Better Lua LSP support for Neovim config development

vim.pack.add({
	{ src = "https://github.com/folke/lazydev.nvim" }
})

-----------------------------------------
-- Configuration
-----------------------------------------

require("lazydev").setup({
	library = {
		"lazy.nvim",
	},
})
