return {
	{
		"nvim-tree/nvim-tree.lua",
		event = "VimEnter",
		version = "*",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				update_cwd = true,
				update_focused_file = {
					enable = true,
					update_cwd = true,
				},
				view = {
					width = 40,
				},
			})

			vim.keymap.set(
				"n",
				"<leader>e",
				vim.cmd.NvimTreeToggle,
				{ noremap = true }
			)
			vim.keymap.set(
				"n",
				"<leader>E",
				vim.cmd.NvimTreeFocus,
				{ noremap = true }
			)
		end,
	},
}
