-- AI coding assistant with chat, inline editing, and agentic workflows

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/olimorris/codecompanion.nvim", version = vim.version.range("^18.0.0") },
})

-----------------------------------------
-- Configuration
-----------------------------------------

local providers = require("codecompanion.providers")

require("codecompanion").setup({
  interactions = {
    chat = {
      adapter = {
        name = "copilot",
        model = "gpt-4.1",
      },
      opts = {
        completion_provider = "blink",
      },
    },
    inline = {
      adapter = {
        name = "anthropic",
        model = "claude-4.5-sonnet",
      },
      keymaps = {
        accept_change = {
          modes = { n = "<leader>aa" },
          description = "Accept inline suggestion",
        },
        reject_change = {
          modes = { n = "<leader>ar" },
          description = "Reject inline suggestion",
        },
      },
    },
    cmd = {
      adapter = "opencode",
    },
    background = {
      adapter = "opencode",
    },
  },
  display = {
    diff = {
      enabled = true,
      provider = providers.mini_diff,
    },
  },
  opts = {
    log_level = "ERROR",
  },
})

-----------------------------------------

-----------------------------------------
-- Keymaps
-----------------------------------------

-- Action palette
vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })

-- Toggle chat buffer
vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle Chat" })

-- Add visual selection to chat
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add to Chat" })

-- Inline assistant
vim.keymap.set({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "Inline Assistant" })

-- Command abbreviation for convenience
vim.cmd([[cab cc CodeCompanion]])
