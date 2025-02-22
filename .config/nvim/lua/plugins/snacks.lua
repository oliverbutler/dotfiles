return {

  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<leader>go",
      function()
        Snacks.gitbrowse.open()
      end,
    },
    {
      "<leader>no",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
    -- Help
    {
      "<leader>sh",
      function()
        Snacks.picker.help()
      end,
      desc = "[S]earch [H]elp",
    },
    -- Keymaps
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "[S]earch [K]eymaps",
    },
    -- Files
    {
      "<leader>;",
      function()
        Snacks.picker.files()
      end,
      desc = "[S]earch Files",
    },
    -- Buffers
    {
      "<leader>sb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "[S]earch [B]uffers",
    },
    -- Word under cursor
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "[S]earch [W]ord",
    },
    -- Document symbols
    {
      "<leader>sd",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "[S]earch [D]ocument symbols",
    },
    -- Git branches and commits
    {
      "<leader>sgb",
      function()
        Snacks.picker.git_branches()
      end,
      desc = "[S]earch [G]it [B]ranches",
    },
    {
      "<leader>sgc",
      function()
        Snacks.picker.git_log()
      end,
      desc = "[S]earch [G]it [C]ommits",
    },
    -- Old files
    {
      "<leader>so",
      function()
        Snacks.picker.recent()
      end,
      desc = "[S]earch [O]ld files",
    },
    -- Live grep
    {
      "<leader>'",
      function()
        Snacks.picker.grep({ live = true })
      end,
      desc = "[S]earch [G]rep",
    },
    -- Resume last picker
    {
      "<leader><leader>",
      function()
        Snacks.picker.resume()
      end,
      desc = "[ ] reopen last",
    },
    -- Visual mode word search
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "[S]earch [W]ord",
      mode = "v",
    },
    -- Current buffer search
    {
      "<leader>/",
      function()
        Snacks.picker.lines()
      end,
      desc = "[/] Fuzzily search in current buffer",
    },
    -- Search in all buffers
    {
      "<leader>?",
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = "[/] Fuzzily search in open buffers",
    },
    -- Project-wide search
    {
      "<leader>.",
      function()
        Snacks.picker.grep({ live = true })
      end,
      desc = "[.] Fuzzy search in project",
    },
    -- Fast paste open
    {
      "<leader>P",
      function()
        local clipboard = vim.fn.getreg("+")
        Snacks.picker.files({ pattern = clipboard })
      end,
    },
    {
      "<leader>i",
      function()
        local params = vim.lsp.util.make_range_params()
        params.context = {
          diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
          only = { "quickfix", "refactor", "source" },
        }

        local results = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
        if not results or vim.tbl_isempty(results) then
          print("No code actions available")
          return
        end

        -- Collect all actions
        local actions = {}
        for _, result in pairs(results) do
          if result.result then
            for _, action in ipairs(result.result) do
              table.insert(actions, action)
            end
          end
        end

        Snacks.picker.pick({
          title = "Code Actions",
          preview = "preview",
          confirm = function(self, item)
            vim.notify("Selected: " .. item.text, vim.log.levels.INFO, {
              title = "Code Action",
              icon = "󰏫",
            })
            -- First close the picker
            vim.api.nvim_win_close(0, true)

            local action = item.action

            -- debug log the whole action
            vim.notify(vim.inspect(action), vim.log.levels.INFO, {
              title = "Code Action",
              icon = "󰏫",
            })

            vim.schedule(function()
              -- Handle edit actions
              if action.edit then
                vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
              end

              -- Handle command actions
              if action.command then
                vim.lsp.buf.execute_command(action.command)
              end
            end)
          end,
          finder = function()
            ---@type snacks.picker.finder.Item[]
            local items = {}

            for _, action in ipairs(actions) do
              local preview_text = ""
              if action.edit then
                local lines = {}
                for uri, edits in pairs(action.edit.changes or {}) do
                  for _, edit in ipairs(edits) do
                    table.insert(lines, "File: " .. vim.fn.fnamemodify(vim.uri_to_fname(uri), ":~:."))
                    table.insert(lines, "Change: " .. edit.newText)
                    table.insert(lines, "")
                  end
                end
                preview_text = table.concat(lines, "\n")
              else
                preview_text = "No preview available"
              end

              ---@type snacks.picker.finder.Item
              local item = {
                text = action.title,
                action = action,
                buf = vim.api.nvim_get_current_buf(),
                preview = {
                  text = preview_text,
                },
              }
              table.insert(items, item)
            end

            return items
          end,
          format = function(item)
            local ret = {}
            local icon = item.action.edit and "󰏬 " or "󰏫 "
            ret[#ret + 1] = { icon .. item.text, "@string" }
            return ret
          end,
        })
      end,
      desc = "[S]earch code actions",
    },
    {
      "gd",
      function()
        Snacks.picker.lsp_definitions()
      end,
    },
    {
      "gr",
      function()
        Snacks.picker.lsp_references()
      end,
    },
  },
  config = function()
    -- Enable mini.files to do a LSP rename
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesActionRename",
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })

    -- Custom search symbols function implementation
    local function setup_custom_symbol_search()
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
          local search_result = ollySearchSymbols.get_symbol_results({
            type = value,
            also_search_file_name = false,
          })

          Snacks.picker.pick({
            title = search_result.title,
            finder = function()
              ---@type snacks.picker.finder.Item[]
              local items = {}

              for _, result in ipairs(search_result.results) do
                ---@type snacks.picker.finder.Item
                local item = {
                  text = result.symbol, -- the searchable text in the picker
                  line = result.symbol, -- this tells snacks to use the symbol as the line shown in the preview (lhs)
                  file = result.file,
                  pos = { result.lnum, result.col },
                }

                table.insert(items, item)
              end

              return items
            end,
            -- format = function(item)
            --   local ret = {}
            --   -- ret[#ret + 1] = { item.text or "", "@string" }
            --   return ret
            -- end,
          })
        end, { desc = "[S]earch [" .. upper_key .. "]" })

        -- vim.keymap.set("n", "<leader>s" .. upper_key, function()
        --   ollySearchSymbols.custom_symbol_search({
        --     type = value,
        --     also_search_file_name = true,
        --   })
        -- end, { desc = "[S]earch [" .. upper_key .. "] (include file name)" })
      end
    end

    require("snacks").setup({
      animation = {
        enabled = true,
      },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          {
            section = "terminal",
            cmd = "chafa ~/.config/nvim/assets/maple-beach.jpg --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
            height = 25,
            padding = 1,
          },
          {
            pane = 2,
            { icon = " ", section = "recent_files", padding = 1 },
            { section = "keys", gap = 1, padding = 1 },
            { section = "startup" },
          },
        },
      },
      gitbrowse = {
        enabled = true,
      },
      notifier = {
        enabled = true,
      },
      image = {
        enabled = true,
      },
      picker = {},
    })

    -- Setup custom symbol search keymaps
    setup_custom_symbol_search()
  end,
}
