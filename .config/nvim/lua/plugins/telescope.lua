return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- When i stole this from kickstar this was a thing it had
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    {
      "nvim-telescope/telescope-ui-select.nvim",
    },
    {
      "nvim-telescope/telescope-project.nvim",
    },
    {
      "nvim-tree/nvim-web-devicons",
      enabled = vim.g.have_nerd_font,
    },
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      version = "^1.0.0",
    },
  },
  config = function()
    local builtin = require("telescope.builtin")

    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
        "project",
        "live_grep_args",
      },
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--hidden",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",

          -- Exclude some patterns from search
          "--glob=!**/.git/*",
          "--glob=!**/.idea/*",
          "--glob=!**/.vscode/*",
          "--glob=!**/build/*",
          "--glob=!**/dist/*",
          "--glob=!**/yarn.lock",
          "--glob=!**/package-lock.json",
        },
        prompt_prefix = "  ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            mirror = false,
          },
          vertical = {
            mirror = false,
          },
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        winblend = 0,
        border = {},
        borderchars = {
          "─",
          "│",
          "─",
          "│",
          "╭",
          "╮",
          "╯",
          "╰",
        },
        color_devicons = true, -- Enable color devicons
        use_less = true,
        path_display = {},
        set_env = { ["COLORTERM"] = "truecolor" },
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      },
      pickers = {
        find_files = {
          hidden = true,
          -- needed to exclude some files & dirs from general search
          -- when not included or specified in .gitignore
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob=!**/.git/*",
            "--glob=!**/.idea/*",
            "--glob=!**/.vscode/*",
            "--glob=!**/build/*",
            "--glob=!**/dist/*",
            "--glob=!**/yarn.lock",
            "--glob=!**/package-lock.json",
          },
        },
      },
    })

    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")
    require("telescope").load_extension("project")
    require("telescope").load_extension("live_grep_args")

    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]search [H]elp" })
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]search [K]eymaps" })
    -- vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = "[S]search [F]iles" })
    vim.keymap.set("n", "<leader>;", builtin.find_files, { desc = "[S]search Files" })
    vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]search [B]uffers" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]search [W]ord" })
    vim.keymap.set("n", "<leader>'", builtin.live_grep, { desc = "[S]search [G]rep" })
    vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]search [R]esume" })
    vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

    -- Visual mode when <leader>sw search for selected text
    vim.keymap.set("v", "<leader>sw", function()
      local selected_text = vim.fn.getreg('"')
      if selected_text and #selected_text > 0 then
        builtin.grep_string({ search = selected_text })
      else
        builtin.grep_string()
      end
    end, { desc = "[S]search [W]ord" })

    vim.keymap.set("n", "<leader>/", function()
      local telescope_dropdown = require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = true, -- Enable previewer
        layout_config = {
          width = 0.8, -- Set width to 80% of the editor's width
        },
      })
      require("telescope.builtin").current_buffer_fuzzy_find(telescope_dropdown)
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- Fuzzy searches across all files in the project
    vim.keymap.set("n", "<leader>.", function()
      builtin.grep_string({
        shorten_path = true,
        word_match = "-w",
        search = "",
      })
    end, { desc = "[.] Fuzzy search in project" })
  end,
}
