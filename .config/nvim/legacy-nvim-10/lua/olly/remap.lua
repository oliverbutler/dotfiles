vim.keymap.set("n", "<leader>ol", vim.cmd.Lazy)

-- Map leader [ and ] to navigate cursor positions
vim.keymap.set("n", "<leader>[", "<C-o>", { noremap = true })
vim.keymap.set("n", "<leader>]", "<C-i>", { noremap = true })

-- Go to the next quickfix item
vim.keymap.set("n", "]q", function()
  vim.cmd("cnext")
end, { desc = "Next Quickfix" })

vim.keymap.set("n", "[q", function()
  vim.cmd("cprev")
end, { desc = "Previous Quickfix" })

vim.keymap.set("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })

vim.keymap.set("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous Error" })

vim.keymap.set("n", "]d", function()
  vim.diagnostic.goto_next()
end, { desc = "Next Diagnostic" })

vim.keymap.set("n", "[d", function()
  vim.diagnostic.goto_prev()
end, { desc = "Previous Diagnostic" })

-- Map leader [ and ] to navigate files
vim.keymap.set("n", "<leader>{", ":bprevious<CR>", { noremap = true })
vim.keymap.set("n", "<leader>}", ":bnext<CR>", { noremap = true })

vim.keymap.set("n", "<leader>w", function()
  -- Check if buffer is modifiable and not readonly
  if vim.bo.modifiable and not vim.bo.readonly then
    vim.cmd("w")
  else
    -- This is rather than the existing annoying text that appears
    vim.notify("Buffer is not saveable", vim.log.levels.INFO, {
      title = "Save Buffer",
      icon = "ℹ️",
    })
  end
end)

-- Quit
vim.keymap.set("n", "<leader>q", function()
  vim.cmd("q")
end)

vim.keymap.set("n", "<leader>gl", function()
  local cmd
  local dir = vim.fn.getcwd()
  local config_flag = vim.o.background == "light" and "-ucf ~/.config/lazygit/config-light.yml" or ""

  if vim.env.GIT_DIR then
    cmd = string.format([[GIT_DIR=%s exec lazygit %s]], vim.env.GIT_DIR, config_flag)
    dir = vim.env.GIT_DIR
  else
    cmd = string.format([[cd %s && exec lazygit %s]], dir, config_flag)
  end

  vim.fn.system(string.format([[tmux display-popup -E -w 95%% -h 95%% -x C -y C -s bg=default -b none "%s"]], cmd))
end)

-- File helpers
vim.keymap.set("n", "<leader>fo", function()
  local file_path = vim.fn.expand("%:p")
  vim.fn.system({ "open", "-R", file_path })
end, { noremap = true, silent = true, desc = "Open current file in Finder" })

-- Define language-specific test patterns
local test_patterns = {
  -- JavaScript/TypeScript patterns
  js = { dot_suffix = { "spec", "test" } },
  jsx = { dot_suffix = { "spec", "test" } },
  ts = { dot_suffix = { "spec", "test" } },
  tsx = { dot_suffix = { "spec", "test" } },

  -- Go patterns
  go = { underscore_suffix = { "test" } },

  -- Default patterns for other languages
  default = { dot_suffix = { "spec", "test" } }
}

local function parseFilename(filename)
  local name, suffix, extension, suffix_type

  -- Find the last dot which should separate the file extension
  local lastDotIndex = filename:match("^.*()%.")
  if not lastDotIndex then
    return nil, nil, nil, nil -- No dot found
  end
  extension = filename:sub(lastDotIndex + 1)

  -- Remove the extension part from the filename
  local remaining = filename:sub(1, lastDotIndex - 1)

  -- Check for underscore suffix pattern (Go style: file_test.go)
  local underscore_idx = remaining:match("^(.-)_([^_]+)$")
  if underscore_idx then
    local potential_suffix = remaining:match("^.+_([^_]+)$")
    -- Check if the suffix matches known underscore suffixes for this extension
    local patterns = test_patterns[extension] or test_patterns.default
    if patterns.underscore_suffix then
      for _, valid_suffix in ipairs(patterns.underscore_suffix) do
        if potential_suffix == valid_suffix then
          name = remaining:sub(1, #remaining - #potential_suffix - 1) -- Remove _suffix
          suffix = potential_suffix
          suffix_type = "underscore"
          return name, suffix, extension, suffix_type
        end
      end
    end
  end

  -- Check for dot suffix pattern (JS/TS style: file.spec.js)
  local secondLastDotIndex = remaining:match("^.*()%.")
  if secondLastDotIndex then
    local potential_suffix = remaining:sub(secondLastDotIndex + 1)
    name = remaining:sub(1, secondLastDotIndex - 1)

    -- Check if the found suffix is a valid dot suffix for this extension
    local patterns = test_patterns[extension] or test_patterns.default
    if patterns.dot_suffix then
      for _, valid_suffix in ipairs(patterns.dot_suffix) do
        if potential_suffix == valid_suffix then
          suffix = potential_suffix
          suffix_type = "dot"
          return name, suffix, extension, suffix_type
        end
      end
    end

    -- If we get here, the suffix wasn't recognized as a test suffix
    name = remaining
    suffix = nil
  else
    name = remaining
  end

  return name, suffix, extension, suffix_type
end

vim.keymap.set("n", "<leader>gs", function()
  local current_file = vim.fn.expand("%:t")  -- Get the current file name
  local current_dir = vim.fn.expand("%:p:h") -- Get the current directory path

  local name, suffix, extension, suffix_type = parseFilename(current_file)

  -- Get language-specific patterns
  local patterns = test_patterns[extension] or test_patterns.default
  local alternate_files = {}

  if suffix then
    -- If we have a suffix, create the alternate path without the suffix
    table.insert(alternate_files, {
      suffix = nil,
      filename = string.format("%s.%s", name, extension)
    })
  else
    -- If we don't have a suffix, create alternate paths with all possible patterns for this extension

    -- Add dot suffix patterns (file.spec.js, file.test.js)
    if patterns.dot_suffix then
      for _, pattern in ipairs(patterns.dot_suffix) do
        table.insert(alternate_files, {
          suffix = pattern,
          suffix_type = "dot",
          filename = string.format("%s.%s.%s", name, pattern, extension)
        })
      end
    end

    -- Add underscore suffix patterns (file_test.go)
    if patterns.underscore_suffix then
      for _, pattern in ipairs(patterns.underscore_suffix) do
        table.insert(alternate_files, {
          suffix = pattern,
          suffix_type = "underscore",
          filename = string.format("%s_%s.%s", name, pattern, extension)
        })
      end
    end
  end

  for _, alt in ipairs(alternate_files) do
    if alt.suffix ~= suffix or alt.suffix_type ~= suffix_type then
      local path = current_dir .. "/" .. alt.filename
      print("Checking path: " .. path) -- Debugging output

      if vim.fn.filereadable(path) == 1 then
        vim.cmd("edit " .. path)
        return
      end
    end
  end

  vim.notify("No sibling file found", "warn", {
    title = "Toggle Sibling File",
    icon = "❌",
  })
end, { noremap = true, desc = "Toggle between sibling files" })

-- Close neovim safely
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
        true,    -- Vim leftovers
        false,   -- Also replace `<lt>`?
        true     -- Replace keycodes (like `<esc>`)?
      ),
      "x",       -- Mode flag
      false      -- Should be false, since we already `nvim_replace_termcodes()`
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
