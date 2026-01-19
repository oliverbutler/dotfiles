-- Flash.nvim - Navigate your code with search labels

vim.pack.add({
	{ src = "https://github.com/folke/flash.nvim" }
})

-----------------------------------------
-- Configuration
-----------------------------------------

---@type Flash.Config
require("flash").setup({})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set({ "n", "x", "o" }, "<leader>l", function()
	require("flash").jump()
end, { desc = "Flash Jump" })

vim.keymap.set({ "n", "x", "o" }, "<leader>L", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })
