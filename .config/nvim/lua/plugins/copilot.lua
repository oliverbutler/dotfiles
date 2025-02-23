return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<C-a>",
            accept_word = "<C-s>",
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          ["*"] = true,
          bun,
        },
        copilot_node_command = "node",
        server_opts_overrides = {},
      })

      vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#6c7086", blend = 50 })
    end,
  },
}
