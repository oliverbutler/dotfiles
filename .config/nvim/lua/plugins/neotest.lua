return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"marilari88/neotest-vitest",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-jest",
		"nvim-neotest/nvim-nio",
	},
	-- Specifies when to load neotest
	keys = { "<leader>tr", "<leader>ts", "<leader>tl" }, -- Example key bindings to trigger loading
	module = "neotest", -- Load when the neotest module is required
	cmd = { "TestFile", "TestNearest", "TestSuite", "TestLast", "TestVisit" }, -- Load for neotest commands
	config = function()
		require("neotest").setup({
			adapters = {
				--			require("neotest-vitest"),
				require("neotest-jest")({
					jestCommand = "pnpm jest --ci --runInBand",
					env = { CI = true },
					jestConfigFile = function(path)
						local file = vim.fn.expand("%:p")
						local new_config = vim.fn.getcwd() .. "/jest.config.ts"

						if string.find(file, "/libs/") then
							new_config = string.match(file, "(.-/[^/]+/)src")
								.. "jest.config.ts"
						end

						-- vim.notify("Jest Config: " .. new_config)
						return new_config
					end,
					cwd = function()
						local file = vim.fn.expand("%:p")
						local new_cwd = vim.fn.getcwd()
						if string.find(file, "/libs/") then
							new_cwd = string.match(file, "(.-/[^/]+/)src")
						end

						-- vim.notify("CWD: " .. new_cwd)
						return new_cwd
					end,
				}),
			},
		})

		vim.keymap.set(
			"n",
			"<leader>ts",
			":Neotest summary<CR>",
			{ desc = "Show Neotest summary" }
		)
		vim.keymap.set(
			"n",
			"<leader>to",
			":Neotest output<CR>",
			{ desc = "Show Neotest output" }
		)
		vim.keymap.set(
			"n",
			"<leader>tp",
			":Neotest output_panel<CR>",
			{ desc = "Show Neotest output panel" }
		)

		vim.keymap.set("n", "<leader>tr", function()
			require("neotest").run.run()
		end, { desc = "Run Neotest" })
		vim.keymap.set("n", "<leader>tl", function()
			require("neotest").run.run_last()
		end, { desc = "Run last Neotest" })
	end,
}
