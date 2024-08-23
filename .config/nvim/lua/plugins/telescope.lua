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
    local lga_actions = require("telescope-live-grep-args.actions")
    local actions = require("telescope.actions")

    require("telescope").setup({
      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
        },
        ["ui-select"] = {
          require("telescope.themes").get_cursor(),
        },
        "project",
        live_grep_args = {
          auto_quoting = true, -- enable/disable auto-quoting
          -- define mappings, e.g.
          mappings = { -- extend mappings
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " -i " }),
            },
          },
        },
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
            prompt_position = "top",
            width = 0.90,
            mirror = false,
          },
          vertical = {
            prompt_position = "top",
            width = 0.90,
            mirror = false,
          },
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
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

    -- Fast paste open
    vim.keymap.set("n", "<leader>P", function()
      builtin.find_files()

      local clipboard = vim.fn.getreg("+")

      if clipboard and #clipboard > 0 then
        vim.cmd("normal! i" .. clipboard)
      end
    end)

    vim.keymap.set("n", "<leader>'", function()
      require("telescope").extensions.live_grep_args.live_grep_args()
    end, { desc = "[S]search [G]rep" })

    --#region
    -- Custom search functions
    local search_key_map = {
      a = "all",
      z = "zod",
      t = "types",
      c = "classes",
      r = "react",
      f = "functions",
    }

    for key, value in pairs(search_key_map) do
      local upper_key = key:upper()

      vim.keymap.set("n", "<leader>s" .. key, function()
        require("olly.search-symbols").custom_symbol_search({
          type = value,
          also_search_file_name = false,
        })
      end, { desc = "[S]earch [" .. upper_key .. "]" })

      vim.keymap.set("n", "<leader>s" .. upper_key, function()
        require("olly.search-symbols").custom_symbol_search({
          type = value,
          also_search_file_name = true,
        })
      end, { desc = "[S]earch [" .. upper_key .. "] (include file name)" })
    end

    --#endregion

    vim.keymap.set("n", "<leader><leader>", builtin.resume, { desc = "[ ] reopen last" })

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
          width = 0.85,
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

    -- Custom Lua function for spell suggestions
    local function spell_suggestions()
      -- Get the current word under the cursor
      local word = vim.fn.expand("<cword>")

      -- Get spell suggestions for the word
      local suggestions = vim.fn.spellsuggest(word)

      -- If there are no suggestions, add a default message
      if vim.tbl_isempty(suggestions) then
        suggestions = { "No suggestions found" }
      end

      -- Telescope configuration
      require("telescope.pickers")
        .new({}, {
          prompt_title = "Spell Suggestions",
          finder = require("telescope.finders").new_table({
            results = suggestions,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry,
                ordinal = entry,
              }
            end,
          }),
          sorter = require("telescope.config").values.generic_sorter({}),
          attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
              local selection = require("telescope.actions.state").get_selected_entry()
              require("telescope.actions").close(prompt_bufnr)
              -- Replace the current word with the selected suggestion
              vim.cmd("normal! ciw" .. selection.value)
            end)
            return true
          end,
        })
        :find()
    end

    -- Map the custom command to <leader>ss
    vim.keymap.set("n", "<leader>ss", spell_suggestions, { desc = "[S]search [S]pell" })
  end,
}
