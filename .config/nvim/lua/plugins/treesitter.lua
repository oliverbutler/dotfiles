-- Treesitter - Syntax highlighting and parsing
-- nvim-treesitter for Neovim 0.12+

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

-- Set parser install directory before setup
local parser_install_dir = vim.fn.stdpath("data") .. "/site/parser"
vim.fn.mkdir(parser_install_dir, "p")
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

require("nvim-treesitter").setup({
	parser_install_dir = parser_install_dir,
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
