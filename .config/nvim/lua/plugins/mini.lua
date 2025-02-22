return {
  {
    "echasnovski/mini.pairs",
    version = false,
    config = function()
      require("mini.pairs").setup()
    end,
  },
  {
    "echasnovski/mini.move",
    event = "VeryLazy",
    config = function()
      require("mini.move").setup()
    end,
  },
  {
    "echasnovski/mini.sessions",
    version = false,
    event = "VeryLazy",
    config = function()
      local sessions = require("mini.sessions")

      sessions.setup()

      -- If no session, start one with mksession
      if not sessions.get_latest() then
        vim.notify("No session found, creating one", "info", { title = "Mini Sessions" })
        vim.cmd("mksession!")
      end
    end,
  },
  {
    "echasnovski/mini.files",
    event = "VeryLazy",
    keys = {
      {
        "<leader>e",
        function()
          local mini_files = require("mini.files")
          mini_files.open(vim.api.nvim_buf_get_name(0))
        end,
      },
    },
    config = function()
      require("mini.files").setup({
        content = {
          ---Custom sort function for file system entries.
          ---
          ---Deals with V{number}__ migration files and orders them by version number.
          ---
          ---Defaults to normal mini-files behavior.
          ---
          ---@param fs_entries table Array of file system entry data.
          ---   Each one is a table with the following fields:
          --- __minifiles_fs_entry_data_fields
          ---
          ---@return table Sorted array of file system entries.
          sort = function(fs_entries)
            -- First convert entries to include additional sort metadata
            local res = vim.tbl_map(function(x)
              -- Extract version number for migration files, letting them be ordered by V<number>__
              local version_num = 0
              if x.name:match("^V%d+__") then
                version_num = tonumber(x.name:match("^V(%d+)__")) or 0
              end

              return {
                fs_type = x.fs_type,
                name = x.name,
                path = x.path,
                is_dir = x.fs_type == "directory",
                version_num = version_num,
              }
            end, fs_entries)

            -- Custom sort function
            table.sort(res, function(a, b)
              -- Directories always come first
              if a.is_dir ~= b.is_dir then
                return a.is_dir
              end

              -- If both are migration files, sort by version number
              if a.version_num > 0 and b.version_num > 0 then
                return a.version_num < b.version_num
              end

              -- Otherwise sort alphabetically (case-insensitive)
              return a.name:lower() < b.name:lower()
            end)

            -- Convert back to original format
            return vim.tbl_map(function(x)
              return {
                name = x.name,
                fs_type = x.fs_type,
                path = x.path,
              }
            end, res)
          end,
        },
        mappings = {
          close = "q",
          go_in = "<Enter>",
          go_in_plus = "<Enter>",
          go_out = "<leader>e",
          go_out_plus = "H",
          mark_goto = "'",
          mark_set = "m",
          reset = "<BS>",
          reveal_cwd = "@",
          show_help = "g?",
          synchronize = "<leader>w",
          trim_left = "<",
          trim_right = ">",
        },
      })
    end,
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
  },
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",
        update_n_lines = "sn",
        suffix_last = "l",
        suffix_next = "n",
      },
    },
  },
}
