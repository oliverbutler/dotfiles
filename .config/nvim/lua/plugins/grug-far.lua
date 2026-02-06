-- Grug-far - Search and replace across multiple files

vim.pack.add({
  { src = "https://github.com/MagicDuck/grug-far.nvim" },
})

-----------------------------------------
-- Configuration
-----------------------------------------

require("grug-far").setup({
  -- options, see Configuration section below
  -- leave empty to use default values
})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>gr", function()
  require("grug-far").open()
end, { desc = "Search and Replace" })

vim.keymap.set("n", "<leader>gw", function()
  require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search and Replace Word" })

vim.keymap.set("v", "<leader>gr", function()
  require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search and Replace Selection" })
