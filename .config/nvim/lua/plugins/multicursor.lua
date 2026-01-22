-- Multiple cursors in Neovim

vim.pack.add({
	{ src = "https://github.com/jake-stewart/multicursor.nvim", ref = "1.0" },
})

local mc = require("multicursor-nvim")
mc.setup()

-- Customize how cursors look
local hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor", { reverse = true })
hl(0, "MultiCursorVisual", { link = "Visual" })
hl(0, "MultiCursorSign", { link = "SignColumn" })
hl(0, "MultiCursorMatchPreview", { link = "Search" })
hl(0, "MultiCursorDisabledCursor", { reverse = true })
hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

-- Keymap layer - only active when there are multiple cursors
mc.addKeymapLayer(function(layerSet)
	-- Select a different cursor as the main one
	layerSet({ "n", "x" }, "<left>", mc.prevCursor)
	layerSet({ "n", "x" }, "<right>", mc.nextCursor)

	-- Delete the main cursor
	layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

	-- Enable and clear cursors using escape
	layerSet("n", "<esc>", function()
		if not mc.cursorsEnabled() then
			mc.enableCursors()
		else
			mc.clearCursors()
		end
	end)
end)

-----------------------------------------
-- Keymaps
-----------------------------------------

-- Add or skip adding a new cursor by matching word/selection
vim.keymap.set({ "n", "x" }, "<leader>n", function()
	mc.matchAddCursor(1)
end, { desc = "Add cursor at next match" })

-- Ctrl+s as an alternative for adding cursor at next match
vim.keymap.set({ "n", "x" }, "<C-s>", function()
	mc.matchAddCursor(1)
end, { desc = "Add cursor at next match" })

vim.keymap.set({ "n", "x" }, "<leader>s", function()
	mc.matchSkipCursor(1)
end, { desc = "Skip next match" })

vim.keymap.set({ "n", "x" }, "<leader>N", function()
	mc.matchAddCursor(-1)
end, { desc = "Add cursor at previous match" })

vim.keymap.set({ "n", "x" }, "<leader>S", function()
	mc.matchSkipCursor(-1)
end, { desc = "Skip previous match" })

-- Add or skip cursor above/below the main cursor
vim.keymap.set({ "n", "x" }, "<up>", function()
	mc.lineAddCursor(-1)
end, { desc = "Add cursor above" })

vim.keymap.set({ "n", "x" }, "<down>", function()
	mc.lineAddCursor(1)
end, { desc = "Add cursor below" })

vim.keymap.set({ "n", "x" }, "<leader><up>", function()
	mc.lineSkipCursor(-1)
end, { desc = "Skip line above" })

vim.keymap.set({ "n", "x" }, "<leader><down>", function()
	mc.lineSkipCursor(1)
end, { desc = "Skip line below" })

-- Add and remove cursors with control + left click
vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse, { desc = "Add/remove cursor with mouse" })
vim.keymap.set("n", "<c-leftdrag>", mc.handleMouseDrag, { desc = "Drag cursor with mouse" })
vim.keymap.set("n", "<c-leftrelease>", mc.handleMouseRelease, { desc = "Release cursor mouse" })

-- Disable and enable cursors
vim.keymap.set({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "Toggle cursor on/off" })

-- Add a cursor for all matches in the document
vim.keymap.set({ "n", "x" }, "<leader>A", mc.matchAllAddCursors, { desc = "Add cursor at all matches" })

-- Align cursor columns
vim.keymap.set("n", "<leader>a", mc.alignCursors, { desc = "Align cursor columns" })

-- Split visual selections by regex
vim.keymap.set("x", "S", mc.splitCursors, { desc = "Split cursors by regex" })

-- Append/insert for each line of visual selections
vim.keymap.set("x", "I", mc.insertVisual, { desc = "Insert at start of visual lines" })
vim.keymap.set("x", "A", mc.appendVisual, { desc = "Append at end of visual lines" })

-- Bring back cursors if you accidentally clear them
vim.keymap.set("n", "<leader>gv", mc.restoreCursors, { desc = "Restore cursors" })
