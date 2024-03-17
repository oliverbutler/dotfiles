return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"marilari88/neotest-vitest",
		"nvim-treesitter/nvim-treesitter"
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-vitest"),
			}
		})

		vim.keymap.set("n", "<leader>ts", ":Neotest summary<CR>")

		vim.keymap.set("n", "<leader>tr", function()
			require('neotest').run.run()
		end)

		vim.keymap.set("n", "<leader>tl", function()
			require('neotest').run.run_last()
		end)

	end
}
