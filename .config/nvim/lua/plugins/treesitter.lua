-- Treesitter - Syntax highlighting and parsing
-- nvim-treesitter for Neovim 0.12+

-- Check for tree-sitter CLI (required for nvim-treesitter main branch)
if vim.fn.executable("tree-sitter") ~= 1 then
  vim.notify(
    "tree-sitter CLI not found! Parsers won't compile.\nInstall with: brew install tree-sitter-cli",
    vim.log.levels.WARN
  )
end

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

-- Setup (only install_dir is needed now)
require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Install parsers asynchronously (no-op if already installed)
vim.defer_fn(function()
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
end, 0)

-- Register MDX as markdown
vim.treesitter.language.register("markdown", "mdx")

-- Enable treesitter highlighting for all filetypes with a parser
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
