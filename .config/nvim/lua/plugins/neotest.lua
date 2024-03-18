return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"marilari88/neotest-vitest",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-jest"
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-vitest"),
				require('neotest-jest')({
					jestCommand = "npm test --",
					jestConfigFile = "jest.config.ts",
					env = { CI = true },
					cwd = function(path)
						return vim.fn.getcwd()
					end,
				})
			}
		})

		vim.keymap.set("n", "<leader>ts", ":Neotest summary<CR>")
		vim.keymap.set("n", "<leader>to", ":Neotest output<CR>")
		vim.keymap.set("n", "<leader>tp", ":Neotest output_panel<CR>")

		vim.keymap.set("n", "<leader>tr", function()
			require('neotest').run.run()
		end)
		vim.keymap.set("n", "<leader>tl", function()
			require('neotest').run.run_last()
		end)

	end
}
