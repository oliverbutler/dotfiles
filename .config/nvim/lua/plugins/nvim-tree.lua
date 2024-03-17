return {
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {
				update_cwd = true,
				update_focused_file = {
					enable = true,
					update_cwd = true,
				},
			}

			vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeFocus)
			vim.keymap.set("n", "<leader>E", vim.cmd.NvimTreeToggle)
		end
	}
}
