-- Git integration with mini.diff

vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.diff" },
})

require("mini.diff").setup({
  view = {
    style = "sign",
  },
})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>gh", function()
  require("mini.diff").toggle_overlay(vim.api.nvim_get_current_buf())
end, { desc = "Toggle Diff Overlay" })

vim.keymap.set("n", "<leader>gj", function()
  require("mini.diff").goto_hunk("next", {})()
end, { desc = "Go to Next Hunk" })

vim.keymap.set("n", "<leader>gk", function()
  require("mini.diff").goto_hunk("prev", {})()
end, { desc = "Go to Previous Hunk" })

vim.keymap.set("n", "<leader>gy", function()
  -- Execute the yank operator with the hunk text object
  local yank_op = require("mini.diff").operator("yank")
  vim.api.nvim_feedkeys(yank_op .. "gh", "mx", false)
end, { desc = "Yank Hunk" })
