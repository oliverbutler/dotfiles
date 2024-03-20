return {
	"kyazdani42/nvim-web-devicons",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				-- When i stole this from kickstar this was a thing it had
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{
				"nvim-telescope/telescope-ui-select.nvim",
			},
			{
				"nvim-tree/nvim-web-devicons",
				enabled = vim.g.have_nerd_font,
			},
		},
		config = function()
			local builtin = require("telescope.builtin")

			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
					prompt_prefix = "  ",
					selection_caret = "  ",
					entry_prefix = "  ",
					initial_mode = "insert",
					selection_strategy = "reset",
					sorting_strategy = "ascending",
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							mirror = false,
						},
						vertical = {
							mirror = false,
						},
					},
					file_sorter = require("telescope.sorters").get_fuzzy_file,
					file_ignore_patterns = {},
					generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
					winblend = 0,
					border = {},
					borderchars = {
						"─",
						"│",
						"─",
						"│",
						"╭",
						"╮",
						"╯",
						"╰",
					},
					color_devicons = true, -- Enable color devicons
					use_less = true,
					path_display = {},
					set_env = { ["COLORTERM"] = "truecolor" },
					file_previewer = require("telescope.previewers").vim_buffer_cat.new,
					grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
					qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			vim.keymap.set(
				"n",
				"<leader>sh",
				builtin.help_tags,
				{ desc = "[S]search [H]elp" }
			)
			vim.keymap.set(
				"n",
				"<leader>sk",
				builtin.keymaps,
				{ desc = "[S]search [K]eymaps" }
			)
			-- vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = "[S]search [F]iles" })
			vim.keymap.set(
				"n",
				"<leader>ss",
				builtin.find_files,
				{ desc = "[S]search Files" }
			)
			vim.keymap.set(
				"n",
				"<leader>sb",
				builtin.buffers,
				{ desc = "[S]search [B]uffers" }
			)
			vim.keymap.set(
				"n",
				"<leader>sw",
				builtin.grep_string,
				{ desc = "[S]search [W]ord" }
			)
			vim.keymap.set(
				"n",
				"<leader>sg",
				builtin.live_grep,
				{ desc = "[S]search [G]rep" }
			)
			vim.keymap.set(
				"n",
				"<leader>sr",
				builtin.resume,
				{ desc = "[S]search [R]esume" }
			)
			vim.keymap.set(
				"n",
				"<leader>s.",
				builtin.oldfiles,
				{ desc = '[S]earch Recent Files ("." for repeat)' }
			)
			vim.keymap.set(
				"n",
				"<leader><leader>",
				builtin.buffers,
				{ desc = "[ ] Find existing buffers" }
			)

			-- Visual mode when <leader>sw search for selected text
			vim.keymap.set("v", "<leader>sw", function()
				local selected_text = vim.fn.getreg('"')
				if selected_text and #selected_text > 0 then
					builtin.grep_string({ search = selected_text })
				else
					builtin.grep_string()
				end
			end, { desc = "[S]search [W]ord" })

			-- Slightly advanced e.ample of overriding default behavior and theme
			vim.keymap.set("n", "<leader>/", function()
				-- You can pass additional configuration to Telescope to change the theme, layout, etc.
				builtin.current_buffer_fuzzy_find(
					require("telescope.themes").get_dropdown({
						winblend = 10,
						previewer = false,
					})
				)
			end, { desc = "[/] Fuzzily search in current buffer" })
		end,
	},
}
