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
    {
      "<leader>sh",
      function()
        Snacks.picker.help()
      end,
      desc = "Search Help",
    },
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Search Keymaps",
    },
    {
      "<leader>;",
      function()
        Snacks.picker.smart({
          multi = { "buffers", "recent", "files" },
          format = "file", -- use `file` format for all sources
          matcher = {
            cwd_bonus = true, -- boost cwd matches
            frecency = true, -- use frecency boosting
            sort_empty = true, -- sort even when the filter is empty
          },
          transform = "unique_file",
        })
      end,
      desc = "Search Files",
    },
    {
      "<leader>sb",
      function()
        Snacks.picker.buffers({
          layout = "dropdown",
        })
      end,
      desc = "Search Buffers",
    },
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Search Word",
    },
    {
      "<leader>sd",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "Search Document Symbols",
    },
    {
      "<leader>sgb",
      function()
        Snacks.picker.git_branches()
      end,
      desc = "Search Git Branches",
    },
    {
      "<leader>sgc",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Search Git Commits",
    },
    {
      "<leader>so",
      function()
        Snacks.picker.recent()
      end,
      desc = "Search Old Files",
    },
    {
      "<leader>'",
      function()
        Snacks.picker.grep({ live = true })
      end,
      desc = "Search Grep",
    },
    {
      "<leader><leader>",
      function()
        Snacks.picker.resume()
      end,
      desc = "Reopen Last Search",
    },
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Search Word",
      mode = "v",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.lines({
          layout = "ivy_split",
        })
      end,
      desc = "Search in Current Buffer",
    },
    {
      "<leader>?",
      function()
        Snacks.picker.grep_buffers({
          layout = "ivy_split",
        })
      end,
      desc = "Search in Open Buffers",
    },
    {
      "<leader>P",
      function()
        local clipboard = vim.fn.getreg("+")
        Snacks.picker.files({ pattern = clipboard })
      end,
      desc = "Fast Search Paste",
    },
    {
      "gd",
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = "LSP Definitions",
    },
    {
      "gr",
      function()
        Snacks.picker.lsp_references()
      end,
      desc = "LSP References",
    },
    {
      "<leader>E",
      function()
        Snacks.explorer.open()
      end,
      desc = "Explorer",
    },
    {
      "<leader>gl",
      function()
        Snacks.lazygit.open({
          win = {
            width = 0.95,
            height = 0.95,
          },
        })
      end,
    },
    {
      "<leader>gf",
      function()
        Snacks.lazygit.log_file()
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
        m = "methods",
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
          })
        end, { desc = "Search " .. value })
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
            cmd = "chafa ~/.config/nvim/assets/maple-beach.jpg --format symbols --symbols vhalf --size 60x17; sleep .1",
            height = 17,
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
      lazygit = {
        enabled = true,
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
      ---@type snacks.picker.Config
      picker = {
        enabled = true,
        formatters = {
          file = {
            truncate = 50, -- truncate the file path to (roughly) this length
          },
        },
        sources = {
          grep_word = {
            hidden = true,
            ignored = true,
            exclude = {
              "**/node_modules/**",
              "**/.git/**",
              "**/.cache/**",
              "**/tmp/**",
              "**/.nx/**",
              "**/dist/**",
            },
          },
          grep = {
            hidden = true,
            ignored = true,
            exclude = {
              "**/node_modules/**",
              "**/.git/**",
              "**/.cache/**",
              "**/tmp/**",
              "**/.nx/**",
              "**/dist/**",
            },
          },
          files = {
            hidden = true,
            ignored = true,
            exclude = {
              "**/node_modules/**",
              "**/.git/**",
              "**/.cache/**",
              "**/tmp/**",
              "**/.nx/**",
              "**/dist/**",
            },
          },
        },
      },
      bigfile = {
        enabled = true,
      },
      quickfile = {
        enabled = true,
      },
      explorer = {
        enabled = true,
      },
    })

    -- Setup custom symbol search keymaps
    setup_custom_symbol_search()
  end,
}
