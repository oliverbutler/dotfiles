vim.pack.add({
  { src = "https://github.com/zbirenbaum/copilot.lua" },
})

-----------------------------------------
-- copilot-lsp Configuration
-----------------------------------------

vim.g.copilot_nes_debounce = 500

-----------------------------------------
-- copilot.lua Configuration
-----------------------------------------

require("copilot").setup({
  copilot_node_command = "/users/olly/node-24",
  panel = {
    enabled = true,
    auto_refresh = true,
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    keymap = {
      accept = "<C-a>",
      accept_word = "<C-e>",
      accept_line = "<M-j>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  nes = {
    enabled = false, -- Disabled for now as it was proving more annoyance than help
    keymap = {
      accept_and_goto = "<C-p>",
      accept = false,
      dismiss = "<Esc>",
    },
  },
  filetypes = {
    yaml = true,
    markdown = true,
    gitcommit = true,
    ["."] = false,
  },
})

-----------------------------------------
-- Highlight Configuration
-----------------------------------------

-- Make Copilot suggestions more transparent using Catppuccin colors
-- This needs to be set after the colorscheme loads, so we use vim.schedule
vim.schedule(function()
  local colors = require("catppuccin.palettes").get_palette()

  -- Use overlay0 (visible but clearly not actual code) for suggestions
  vim.api.nvim_set_hl(0, "CopilotSuggestion", {
    fg = colors.overlay0,
    italic = true,
  })

  vim.api.nvim_set_hl(0, "CopilotAnnotation", {
    fg = colors.overlay0,
  })
end)

-----------------------------------------
-- Keymaps
-----------------------------------------

-- -- NES: Tab to accept in normal mode (jumps to edit, then applies)
-- vim.keymap.set("n", "<Tab>", function()
--   local bufnr = vim.api.nvim_get_current_buf()
--   local state = vim.b[bufnr].nes_state
--   if state then
--     local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
--       or (require("copilot-lsp.nes").apply_pending_nes() and require("copilot-lsp.nes").walk_cursor_end_edit())
--     return
--   end
--   -- Fallback to normal <C-i> (jump forward in jumplist)
--   vim.cmd("normal! \t")
-- end, { desc = "Accept Copilot NES or fallback" })
--
-- -- NES: Escape to clear suggestion
-- vim.keymap.set("n", "<Esc>", function()
--   if not require("copilot-lsp.nes").clear() then
--     -- Clear search highlight as fallback
--     vim.cmd("nohlsearch")
--   end
-- end, { desc = "Clear Copilot NES or nohlsearch" })

vim.keymap.set("n", "<leader>cp", function()
  require("copilot.panel").toggle()
end, { desc = "Toggle Copilot Panel" })

vim.keymap.set("n", "<leader>ct", function()
  require("copilot.suggestion").toggle_auto_trigger()
end, { desc = "Toggle Copilot Auto Trigger" })
