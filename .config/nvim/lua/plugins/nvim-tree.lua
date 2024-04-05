return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = { "<leader>e", "<leader>E" }, -- Example key bindings to trigger loading
    cmd = { "NvimTreeToggle", "NvimTreeFocus" }, -- These commands will trigger the lazy loading
    config = function()
      local function natural_cmp(left, right)
        left = left.name:lower()
        right = right.name:lower()

        if left == right then
          return false
        end

        for i = 1, math.max(string.len(left), string.len(right)), 1 do
          local l = string.sub(left, i, -1)
          local r = string.sub(right, i, -1)

          if type(tonumber(string.sub(l, 1, 1))) == "number" and type(tonumber(string.sub(r, 1, 1))) == "number" then
            local l_number = tonumber(string.match(l, "^[0-9]+"))
            local r_number = tonumber(string.match(r, "^[0-9]+"))

            if l_number ~= r_number then
              return l_number < r_number
            end
          elseif string.sub(l, 1, 1) ~= string.sub(r, 1, 1) then
            return l < r
          end
        end
      end

      require("nvim-tree").setup({
        update_cwd = true,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        view = {
          width = 40,
        },
        sort_by = function(nodes)
          table.sort(nodes, natural_cmp)
        end,
      })

      vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { noremap = true })
      vim.keymap.set("n", "<leader>E", vim.cmd.NvimTreeFocus, { noremap = true })
    end,
  },
}
