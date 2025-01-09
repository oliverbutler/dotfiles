return {
  "stevearc/oil.nvim",
  cmd = "Oil",
  lazy = false,
  keys = {
    {
      "<leader>e",
      "<cmd>Oil<cr>",
      desc = "Open parent directory",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")

    oil.setup({
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, bufnr)
          local m = name:match("^%.")
          return m ~= nil
        end,
      },
      natural_order = "fast",
      watch_for_changes = true,
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime",
      },
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-l>"] = "actions.refresh",
        -- ["-"] = { "actions.parent", mode = "n" }, -- we use this keybind to exit nvim
        -- ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
      use_default_keymaps = false,
    })

    -- -- Open oil at startup
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --   callback = function()
    --     if vim.fn.argc() == 0 then
    --       vim.cmd("Oil")
    --     end
    --   end,
    -- })
  end,
}
