-- Codediff.nvim - VSCode-style side-by-side diff viewer

vim.pack.add({
  { src = "https://github.com/esmuellert/codediff.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
})

-----------------------------------------
-- Configuration
-----------------------------------------

require("codediff").setup({})

-- Set diagonal lines in place of deleted lines in diff-mode
vim.opt.fillchars:append({ diff = "╱" })

-----------------------------------------
-- Keymaps
-----------------------------------------

-- File history (commit log)
vim.keymap.set("n", "<leader>ha", "<cmd>CodeDiff history<CR>", { desc = "Diff History All" })
