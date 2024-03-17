vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>l", vim.cmd.Lazy)
vim.keymap.set("n", "<Enter>", "o")
vim.keymap.set("n", "<S-Enter>", "O")
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>p', '"+p')

-- Map leader [ and ] to navigate cursor positions
vim.keymap.set('n', '<leader>[', '<C-o>', { noremap = true })
vim.keymap.set('n', '<leader>]', '<C-i>', { noremap = true })

-- Map leader [ and ] to navigate files
vim.keymap.set('n', '<leader>{', ':bprevious<CR>', { noremap = true })
vim.keymap.set('n', '<leader>}', ':bnext<CR>', { noremap = true })

-- undo tree
vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { noremap = true })


-- Add this to your init.lua file
vim.keymap.set("n", "<leader>q", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
	if modified then
		vim.ui.input({
			prompt = "You have unsaved changes. Save before quitting? (y/n) ",
		}, function(input)
			if input == "y" then
				vim.cmd("write")
				vim.cmd("quit")
			elseif input == "n" or input == "N" then
				vim.cmd("quit!")
			end
		end)
	else
		vim.cmd("quit")
	end
end, { desc = "Quit Neovim with prompt to save changes" })


local notify = require("notify")

vim.keymap.set("n", "<leader>§", function()
    local current_word = vim.fn.expand("<cword>")
    local monorepo_root = vim.fn.getcwd()

    -- Use ripgrep with `--vimgrep` for better integration with Vim
    -- and `--type` to specify file types instead of `--include`
    local rg_cmd = string.format("rg --vimgrep '%s' %s", current_word, monorepo_root)
    local raw_rg_output = vim.fn.systemlist(rg_cmd)
    local valid_paths = {}
    local unique_paths = {}

    for _, line in ipairs(raw_rg_output) do
        local path = line:match("^(.-):")
        if path and not unique_paths[path] then
            table.insert(valid_paths, path)
            unique_paths[path] = true
        end
    end

    if #valid_paths > 0 then
        local original_buffer = vim.api.nvim_get_current_buf()
        local notification_id

        -- Initial notification with loading symbols
        notification_id = notify("Searching... 🔍🚀", "info", {
            title = "Navigation Progress",
            icon = "🌠",
            replace = notification_id,
            hide_from_history = true,
        })

        for i, path in ipairs(valid_paths) do
            vim.defer_fn(function()
                vim.cmd("edit " .. path)

                -- Update the notification with progress
                notification_id = notify(string.format("%d/%d 🔍 %s", i, #valid_paths, path), "info", {
                    title = "Navigation Progress",
                    icon = "🌠",
                    replace = notification_id,
                    hide_from_history = true,
                })
            end, (i - 1) * 200)
        end

        vim.defer_fn(function()
            vim.api.nvim_set_current_buf(original_buffer)

            -- Final notification
            notify(string.format("for '%s'! 🎉", current_word), "info", {
                title = "Index Complete",
                icon = "✅",
                replace = notification_id,
            })
        end, #valid_paths * 200)
    else
        notify("No references found for '" .. current_word .. "' 😔", "warn", {
            title = "Search Results",
            icon = "❌",
        })
    end
end)
