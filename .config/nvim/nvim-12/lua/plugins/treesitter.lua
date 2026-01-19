-- Treesitter - Syntax highlighting and parsing
-- New API for nvim-treesitter (Neovim 0.11+)

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

local ts = require("nvim-treesitter")

ts.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
	silent = true, -- Don't show installation messages
})

-- Install required parsers
-- local parsers = {
-- 	"json",
-- 	"javascript",
-- 	"typescript",
-- 	"tsx",
-- 	"yaml",
-- 	"html",
-- 	"css",
-- 	"markdown",
-- 	"markdown_inline",
-- 	"bash",
-- 	"lua",
-- 	"vim",
-- 	"vimdoc",
-- 	"go",
-- 	"rust",
-- }

-- -- Install parsers asynchronously (silently)
-- ts.install(parsers)
--
-- -- Register MDX as markdown
-- vim.treesitter.language.register("markdown", "mdx")
--
-- -- Enable treesitter highlighting for all filetypes
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "*",
-- 	callback = function()
-- 		pcall(vim.treesitter.start)
-- 	end,
-- })
