-- Git integration with mini.diff

vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.diff" },
})

require("mini.diff").setup({
  -- Configuration options
})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>gh", function()
  require("mini.diff").toggle_overlay()
end, { desc = "Toggle Diff Overlay" })

vim.keymap.set("n", "<leader>gj", function()
  require("mini.diff").goto_hunk()
end, { desc = "Go to Next Hunk" })

vim.keymap.set("n", "<leader>gk", function()
  require("mini.diff").goto_hunk({ count = -1 })
end, { desc = "Go to Previous Hunk" })

