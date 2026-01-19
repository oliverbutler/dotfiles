-- Snacks.nvim

vim.pack.add({
	{ src = "https://github.com/folke/snacks.nvim" }
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesActionRename",
	callback = function(event)
		Snacks.rename.on_rename_file(event.data.from, event.data.to)
	end,
})

require("snacks").setup({
	animation = {
		enabled = true,
	},
	dashboard = {
		enabled = true,
		preset = {
			keys = {
				{ icon = " ", key = "n", desc = "New File",        action = ":ene | startinsert" },
				{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
				{ icon = " ", key = "q", desc = "Quit",            action = ":qa" },
			},
		},
		sections = {
			{
				section = "terminal",
				cmd =
				"chafa ~/.config/nvim/assets/maple-beach.jpg --format symbols --symbols vhalf --size 60x17; sleep .1",
				height = 17,
				padding = 1,
			},
			{
				pane = 2,
				{ icon = " ",         section = "recent_files", padding = 1 },
				{ section = "keys",   gap = 1,                  padding = 1 },
				{ section = "startup" },
			},
		},
	},
	lazygit = {
		enabled = true,
	},
	gitbrowse = {
		enabled = true,
	},
	notifier = {
		enabled = true,
	},
	image = {
		enabled = true,
	},
	---@type snacks.picker.Config
	picker = {
		enabled = true,
		formatters = {
			file = {
				truncate = 50,
			},
		},
		sources = {
			grep_word = {
				hidden = true,
				ignored = true,
				exclude = {
					"**/node_modules/**",
					"**/.git/**",
					"**/.cache/**",
					"**/tmp/**",
					"**/.nx/**",
					"**/dist/**",
					"**/coverage/**",
				},
			},
			grep = {
				hidden = true,
				ignored = true,
				exclude = {
					"**/node_modules/**",
					"**/.git/**",
					"**/.cache/**",
					"**/tmp/**",
					"**/.nx/**",
					"**/dist/**",
					"**/coverage/**",
				},
			},
			files = {
				hidden = true,
				ignored = true,
				exclude = {
					"**/node_modules/**",
					"**/.git/**",
					"**/.cache/**",
					"**/tmp/**",
					"**/.nx/**",
					"**/dist/**",
					"**/coverage/**",
				},
			},
		},
	},
	bigfile = {
		enabled = true,
	},
	quickfile = {
		enabled = true,
	},
	explorer = {
		enabled = true,
	},
})

-----------------------------------------
-- Keymaps
-----------------------------------------

-- Git Browse
vim.keymap.set("n", "<leader>go", function()
	Snacks.gitbrowse.open()
end, { desc = "Git Browse Open" })

-- Notifier
vim.keymap.set("n", "<leader>no", function()
	Snacks.notifier.show_history()
end, { desc = "Notification History" })

-- Picker: Help
vim.keymap.set("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "Search Help" })

-- Picker: Keymaps
vim.keymap.set("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "Search Keymaps" })

-- Picker: Smart file search (multi-source)
vim.keymap.set("n", "<leader>;", function()
	Snacks.picker.smart({
		multi = { "buffers", "recent", "files" },
		format = "file",
		matcher = {
			cwd_bonus = true,
			frecency = true,
			sort_empty = true,
		},
		transform = "unique_file",
	})
end, { desc = "Search Files" })

-- Picker: Buffers
vim.keymap.set("n", "<leader>sb", function()
	Snacks.picker.buffers({
		layout = "dropdown",
	})
end, { desc = "Search Buffers" })

-- Picker: Grep word (normal mode)
vim.keymap.set("n", "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "Search Word" })

-- Picker: Grep word (visual mode)
vim.keymap.set("v", "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "Search Word" })

-- Picker: LSP Document symbols
vim.keymap.set("n", "<leader>sd", function()
	Snacks.picker.lsp_symbols()
end, { desc = "Search Document Symbols" })

-- Picker: Git branches
vim.keymap.set("n", "<leader>sgb", function()
	Snacks.picker.git_branches()
end, { desc = "Search Git Branches" })

-- Picker: Git commits
vim.keymap.set("n", "<leader>sgc", function()
	Snacks.picker.git_log()
end, { desc = "Search Git Commits" })

-- Picker: Recent files
vim.keymap.set("n", "<leader>so", function()
	Snacks.picker.recent()
end, { desc = "Search Old Files" })

-- Picker: Live grep
vim.keymap.set("n", "<leader>'", function()
	Snacks.picker.grep({ live = true })
end, { desc = "Search Grep" })

-- Picker: Resume last search
vim.keymap.set("n", "<leader><leader>", function()
	Snacks.picker.resume()
end, { desc = "Reopen Last Search" })

-- Picker: Search in current buffer
vim.keymap.set("n", "<leader>/", function()
	Snacks.picker.lines({
		layout = "ivy_split",
	})
end, { desc = "Search in Current Buffer" })

-- Picker: Search in open buffers
vim.keymap.set("n", "<leader>?", function()
	Snacks.picker.grep_buffers({
		layout = "ivy_split",
	})
end, { desc = "Search in Open Buffers" })

-- Picker: Fast search paste
vim.keymap.set("n", "<leader>P", function()
	local clipboard = vim.fn.getreg("+")
	Snacks.picker.files({ pattern = clipboard })
end, { desc = "Fast Search Paste" })

-- Explorer
vim.keymap.set("n", "<leader>E", function()
	Snacks.explorer.open()
end, { desc = "Explorer" })

-- LazyGit
vim.keymap.set("n", "<leader>gl", function()
	Snacks.lazygit.open({
		win = {
			width = 0.95,
			height = 0.95,
		},
	})
end, { desc = "LazyGit" })

-- LazyGit: Log file
vim.keymap.set("n", "<leader>gf", function()
	Snacks.lazygit.log_file()
end, { desc = "LazyGit File History" })

-----------------------------------------
-- Custom Symbol Search
-----------------------------------------

local function setup_custom_symbol_search()
	local search_key_map = {
		a = "all",
		z = "zod",
		t = "types",
		c = "classes",
		r = "react",
		m = "methods",
	}

	local ollySearchSymbols = require("olly.search-symbols")

	for key, value in pairs(search_key_map) do
		vim.keymap.set("n", "<leader>s" .. key, function()
			local search_result = ollySearchSymbols.get_symbol_results({
				type = value,
				also_search_file_name = false,
			})

			Snacks.picker.pick({
				title = search_result.title,
				finder = function()
					---@type snacks.picker.finder.Item[]
					local items = {}

					for _, result in ipairs(search_result.results) do
						---@type snacks.picker.finder.Item
						local item = {
							text = result.symbol,
							line = result.symbol,
							file = result.file,
							pos = { result.lnum, result.col },
						}

						table.insert(items, item)
					end

					return items
				end,
			})
		end, { desc = "Search " .. value })
	end
end

setup_custom_symbol_search()
