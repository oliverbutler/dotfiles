return {
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,
        },
        copilot_node_command = vim.fn.expand("$HOME") .. "/.local/share/fnm/node-versions/v20.16.0/installation/bin/node",
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
          javascript = true,
          typescript = true,
          json = true,
          markdown = true,
          yaml = true,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        server_opts_overrides = {},
      })

      vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#6c7086", blend = 50 })
    end,
  },
}
