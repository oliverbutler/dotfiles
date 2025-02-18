return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "echasnovski/mini.icons",
  },
  config = function()
    local fzf = require("fzf-lua")

    -- Setup configuration
    fzf.setup({
      global_resume = true,
      global_resume_query = true,
      file_icons = true,
      winopts = {
        height = 0.85,
        width = 0.90,
        preview = {
          default = "builtin",
        },
      },
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>sh", fzf.help_tags, { desc = "[S]search [H]elp" })
    vim.keymap.set("n", "<leader>sk", fzf.keymaps, { desc = "[S]search [K]eymaps" })
    vim.keymap.set("n", "<leader>;", fzf.files, { desc = "[S]search Files" })
    vim.keymap.set("n", "<leader>sb", fzf.buffers, { desc = "[S]search [B]uffers" })
    vim.keymap.set("n", "<leader>sw", function()
      fzf.grep_cword()
    end, { desc = "[S]search [W]ord" })

    vim.keymap.set("n", "<leader>'", fzf.live_grep, { desc = "[S]search [G]rep" })

    local search_key_map = {
      a = "all",
      z = "zod",
      t = "types",
      c = "classes",
      r = "react",
    }

    local ollySearchSymbols = require("olly.search-symbols")

    for key, value in pairs(search_key_map) do
      local upper_key = key:upper()

      vim.keymap.set("n", "<leader>s" .. key, function()
        ollySearchSymbols.custom_symbol_search({
          type = value,
          also_search_file_name = false,
        })
      end, { desc = "[S]earch [" .. upper_key .. "]" })

      vim.keymap.set("n", "<leader>s" .. upper_key, function()
        ollySearchSymbols.custom_symbol_search({
          type = value,
          also_search_file_name = true,
        })
      end, { desc = "[S]earch [" .. upper_key .. "] (include file name)" })
    end

    vim.keymap.set("n", "<leader><leader>", fzf.resume, { desc = "[ ] reopen last" })

    -- Visual mode search
    vim.keymap.set("v", "<leader>sw", function()
      fzf.grep_visual()
    end, { desc = "[S]search [W]ord" })

    -- Current buffer search
    vim.keymap.set("n", "<leader>/", function()
      fzf.blines()
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- Project-wide search
    vim.keymap.set("n", "<leader>.", function()
      fzf.live_grep()
    end, { desc = "[.] Fuzzy search in project" })

    -- Fast paste open
    vim.keymap.set("n", "<leader>P", function()
      local clipboard = vim.fn.getreg("+")
      fzf.files({ default_text = clipboard })
    end)
  end,
}
