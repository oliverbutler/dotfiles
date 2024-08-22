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

    vim.keymap.set("n", '<leader>"', function()
      local keyword_pattern = [[\b(const|let|async|function)\s+(\w+)]]

      vim.notify("Starting symbol search...", vim.log.levels.INFO)

      local Job = require("plenary.job")
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local previewers = require("telescope.previewers")

      local fzf_lua = require("telescope").extensions.fzf

      local function grep_symbols()
        local results = {}
        Job:new({
          command = "rg",
          args = {
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            keyword_pattern,
            ".",
          },
          on_exit = function(j, return_val)
            for _, line in ipairs(j:result()) do
              table.insert(results, line)
            end
          end,
        }):sync()
        vim.notify("Found " .. #results .. " symbols", vim.log.levels.INFO)
        return results
      end

      local symbol_results = grep_symbols()

      if #symbol_results == 0 then
        vim.notify("No symbols found", vim.log.levels.WARN)
        return
      end

      pickers
        .new(require("telescope.themes").get_dropdown(), {
          prompt_title = "Search Symbol",
          finder = finders.new_table({
            results = symbol_results,
            entry_maker = function(entry)
              local file, lnum, col, text = string.match(entry, "([^:]+):([^:]+):([^:]+):(.+)")
              local keyword, symbol = string.match(text, "(%w+)%s+(%w+)")

              if not symbol then
                symbol = text
              end

              return {
                value = entry,
                display = symbol .. " - " .. file .. ":" .. lnum,
                ordinal = symbol,
                filename = file,
                lnum = tonumber(lnum),
                col = tonumber(col),
              }
            end,
          }),
          sorter = fzf_lua.native_fzf_sorter(),
          previewer = previewers.vim_buffer_vimgrep.new({}),
          layout_config = {
            horizontal = {
              prompt_position = "top",
              width = 0.60,
              mirror = false,
            },
          },
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              vim.notify("Opening " .. selection.filename .. " at line " .. selection.lnum, vim.log.levels.INFO)
              vim.cmd("edit " .. selection.filename)
              vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
            end)
            return true
          end,
        })
        :find()

      vim.notify("Symbol search completed", vim.log.levels.INFO)
    end, { desc = "[S]earch [S]ymbol" })

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
