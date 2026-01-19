-- Treesitter - Syntax highlighting and parsing
-- nvim-treesitter for Neovim 0.11+

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("nvim-treesitter").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Install parsers (no-op if already installed)
require("nvim-treesitter").install({
	"json",
	"javascript",
	"typescript",
	"tsx",
	"yaml",
	"html",
	"css",
	"markdown",
	"markdown_inline",
	"bash",
	"lua",
	"vim",
	"vimdoc",
	"go",
	"rust",
})

-- Register MDX as markdown
vim.treesitter.language.register("markdown", "mdx")
