-- Mini.files plugin configuration

vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.files" }
})

-----------------------------------------
-- Configuration
-----------------------------------------

require("mini.files").setup({
	content = {
		---Custom sort function for file system entries.
		---
		---Deals with V{number}__ migration files and orders them by version number.
		---
		---Defaults to normal mini-files behavior.
		---
		---@param fs_entries table Array of file system entry data.
		---   Each one is a table with the following fields:
		--- __minifiles_fs_entry_data_fields
		---
		---@return table Sorted array of file system entries.
		sort = function(fs_entries)
			-- First convert entries to include additional sort metadata
			local res = vim.tbl_map(function(x)
				-- Extract version number for migration files, letting them be ordered by V<number>__
				local version_num = 0
				if x.name:match("^V%d+__") then
					version_num = tonumber(x.name:match("^V(%d+)__")) or 0
				end

				return {
					fs_type = x.fs_type,
					name = x.name,
					path = x.path,
					is_dir = x.fs_type == "directory",
					version_num = version_num,
				}
			end, fs_entries)

			-- Custom sort function
			table.sort(res, function(a, b)
				-- Directories always come first
				if a.is_dir ~= b.is_dir then
					return a.is_dir
				end

				-- If both are migration files, sort by version number
				if a.version_num > 0 and b.version_num > 0 then
					return a.version_num < b.version_num
				end

				-- Otherwise sort alphabetically (case-insensitive)
				return a.name:lower() < b.name:lower()
			end)

			-- Convert back to original format
			return vim.tbl_map(function(x)
				return {
					name = x.name,
					fs_type = x.fs_type,
					path = x.path,
				}
			end, res)
		end,
	},
	mappings = {
		close = "q",
		go_in = "<Enter>",
		go_in_plus = "<Enter>",
		go_out = "<leader>e",
		go_out_plus = "H",
		mark_goto = "'",
		mark_set = "m",
		reset = "<BS>",
		reveal_cwd = "@",
		show_help = "g?",
		synchronize = "<leader>w",
		trim_left = "<",
		trim_right = ">",
	},
})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>e", function()
	local mini_files = require("mini.files")
	mini_files.open(vim.api.nvim_buf_get_name(0))
end, { desc = "Open File Explorer" })
