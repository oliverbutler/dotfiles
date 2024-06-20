vim.keymap.set("n", "<leader>l", vim.cmd.Lazy)

-- Map leader [ and ] to navigate cursor positions
vim.keymap.set("n", "<leader>[", "<C-o>", { noremap = true })
vim.keymap.set("n", "<leader>]", "<C-i>", { noremap = true })

-- Map leader [ and ] to navigate files
vim.keymap.set("n", "<leader>{", ":bprevious<CR>", { noremap = true })
vim.keymap.set("n", "<leader>}", ":bnext<CR>", { noremap = true })

-- undo tree
vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>", { noremap = true })

vim.keymap.set("n", "<leader>w", function()
  vim.cmd("w")
end)

-- ChatGPT
vim.keymap.set("n", "<leader>co", ":ChatGPT<CR>")
vim.keymap.set("v", "<leader>ce", ":ChatGPTEditWithInstructions<CR>")

-- Helpers
vim.keymap.set("n", "<leader>ra", ":LspRestart *<CR>", { noremap = true, desc = "Restart LSP" })

-- Add this to your init.lua file
vim.keymap.set("n", "<leader>-", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
  if modified then
    vim.ui.input({
      prompt = "You have unsaved changes. Save before quitting? (y/n) ",
    }, function(input)
      if input == "y" then
        vim.cmd("wa")
        vim.cmd("qa!")
      elseif input == "n" or input == "N" then
        vim.cmd("qa!")
      end
    end)
  else
    vim.cmd("qa!")
  end
end, { desc = "Quit Neovim with prompt to save changes" })

vim.keymap.set("n", "<leader>+", function()
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
    notification_id = vim.notify("Searching... 🔍🚀", "info", {
      title = "Navigation Progress",
      icon = "🌠",
      replace = notification_id,
      hide_from_history = true,
    })

    for i, path in ipairs(valid_paths) do
      vim.defer_fn(function()
        vim.cmd("edit " .. path)

        -- Update the notification with progress
        notification_id = vim.notify(string.format("%d/%d 🔍 %s", i, #valid_paths, path), "info", {
          title = "Navigation Progress",
          icon = "🌠",
          replace = notification_id,
          hide_from_history = true,
        })
      end, (i - 1) * 50)
    end

    vim.defer_fn(function()
      vim.api.nvim_set_current_buf(original_buffer)

      -- Final notification
      vim.notify(string.format("for '%s'! 🎉", current_word), "info", {
        title = "Index Complete",
        icon = "✅",
        replace = notification_id,
      })
    end, #valid_paths * 200)
  else
    vim.notify("No references found for '" .. current_word .. "' 😔", "warn", {
      title = "Search Results",
      icon = "❌",
    })
  end
end)

------------------------------------------------
--
-- Quickfix
--
------------------------------------------------

-- Remove items from quickfix list.
-- `dd` to delete in Normal
-- `d` to delete Visual selection
local function delete_qf_items()
  local mode = vim.api.nvim_get_mode()["mode"]

  local start_idx
  local count

  if mode == "n" then
    -- Normal mode
    start_idx = vim.fn.line(".")
    count = vim.v.count > 0 and vim.v.count or 1
  else
    -- Visual mode
    local v_start_idx = vim.fn.line("v")
    local v_end_idx = vim.fn.line(".")

    start_idx = math.min(v_start_idx, v_end_idx)
    count = math.abs(v_end_idx - v_start_idx) + 1

    -- Go back to normal
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(
        "<esc>", -- what to escape
        true, -- Vim leftovers
        false, -- Also replace `<lt>`?
        true -- Replace keycodes (like `<esc>`)?
      ),
      "x", -- Mode flag
      false -- Should be false, since we already `nvim_replace_termcodes()`
    )
  end

  local qflist = vim.fn.getqflist()

  for _ = 1, count, 1 do
    table.remove(qflist, start_idx)
  end

  vim.fn.setqflist(qflist, "r")
  vim.fn.cursor(start_idx, 1)
end

vim.api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "qf",
  callback = function()
    -- Do not show quickfix in buffer lists.
    vim.api.nvim_buf_set_option(0, "buflisted", false)

    -- Escape closes quickfix window.
    vim.keymap.set("n", "<ESC>", "<CMD>cclose<CR>", { buffer = true, remap = false, silent = true })

    -- `dd` deletes an item from the list.
    vim.keymap.set("n", "dd", delete_qf_items, { buffer = true })
    vim.keymap.set("x", "d", delete_qf_items, { buffer = true })
  end,
  desc = "Quickfix tweaks",
})
