-- Lualine.nvim - Statusline

vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim" }
})

-----------------------------------------
-- Configuration
-----------------------------------------

local function get_git_branch()
	local git_path = vim.fn.finddir(".git", ".;")
	if git_path == "" then
		return nil
	end
	local head_file = git_path .. "/HEAD"
	local file = io.open(head_file)
	if not file then
		return nil
	end
	local head = file:read("*l")
	file:close()
	return head:match("ref: refs/heads/(.+)")
end

local function shortened_branch()
	local branch = get_git_branch()
	if not branch or branch == "" then
		return ""
	end
	local max_length = 25
	if #branch > max_length then
		return string.sub(branch, 1, max_length) .. "..."
	else
		return branch
	end
end

require("lualine").setup({
	options = { 
		theme = "catppuccin",
		section_separators = "",
		component_separators = "",
	},
	sections = {
		lualine_a = { "mode", "grapple" },
		lualine_b = { shortened_branch, "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = {},
		lualine_y = {},
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	extensions = { "trouble" },
})
