return {
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
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
				view = {
					width = 60,
				},
			}

			vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { noremap = true })
		end
	}
}
