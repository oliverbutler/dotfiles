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
      desc = "Search Help",
    },
    -- Keymaps
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Search Keymaps",
    },
    -- Files
    {
      "<leader>;",
      function()
        Snacks.picker.files()
      end,
      desc = "Search Files",
    },
    -- Buffers
    {
      "<leader>sb",
      function()
        Snacks.picker.buffers({})
      end,
      desc = "Search Buffers",
    },
    -- Word under cursor
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Search Word",
    },
    -- Document symbols
    {
      "<leader>sd",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "Search Document Symbols",
    },
    -- Git branches and commits
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
    -- Old files
    {
      "<leader>so",
      function()
        Snacks.picker.recent()
      end,
      desc = "Search Old Files",
    },
    -- Live grep
    {
      "<leader>'",
      function()
        Snacks.picker.grep({ live = true })
      end,
      desc = "Search Grep",
    },
    -- Resume last picker
    {
      "<leader><leader>",
      function()
        Snacks.picker.resume()
      end,
      desc = "Reopen Last Search",
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
        Snacks.picker.lines({
          layout = "default",
        })
      end,
      desc = "Search in Current Buffer",
    },
    -- Search in all buffers
    {
      "<leader>?",
      function()
        Snacks.picker.grep_buffers({
          layout = "default",
        })
      end,
      desc = "Search in Open Buffers",
    },
    -- Project-wide search
    {
      "<leader>.",
      function()
        Snacks.picker.grep({ live = true })
      end,
      desc = "Search in Project",
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
          })
        end, { desc = "Search " .. value })

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
            cmd = "chafa ~/.config/nvim/assets/maple-beach.jpg --format symbols --symbols vhalf --size 60x25; sleep .1",
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
