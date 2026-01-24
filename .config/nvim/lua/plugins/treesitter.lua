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

-- Set parser install directory before setup
local parser_install_dir = vim.fn.stdpath("data") .. "/site/parser"
vim.fn.mkdir(parser_install_dir, "p")
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

require("nvim-treesitter").setup({
  parser_install_dir = parser_install_dir,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = "<TAB>",
      node_decremental = "<S-TAB>",
    },
  },
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

-- Fix: Force highlight on FileType event (fixes race condition)
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    -- Small delay to ensure parser is loaded
    vim.defer_fn(function()
      if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
        return -- Already attached
      end
      -- Try to attach highlighter
      pcall(vim.treesitter.start)
    end, 50)
  end,
})
