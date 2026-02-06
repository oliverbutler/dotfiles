vim.cmd.filetype("plugin indent on") -- Enable filetype detection, plugins, and indentation

vim.cmd.colorscheme("catppuccin") -- Set colorscheme

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Search" })
  end,
})
