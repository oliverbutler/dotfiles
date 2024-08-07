return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local function get_git_branch()
      local git_path = vim.fn.finddir(".git", ".;")
      if git_path == "" then
        return nil
      end
      local head_file = git_path .. "/HEAD"
      local file = io.open(head_file)
      if not file then
        return nil
      end
      local head = file:read("*l")
      file:close()
      return head:match("ref: refs/heads/(.+)")
    end

    local function shortened_branch()
      local branch = get_git_branch()
      if not branch or branch == "" then
        return ""
      end
      local max_length = 25
      if #branch > max_length then
        return string.sub(branch, 1, max_length) .. "..."
      else
        return branch
      end
    end

    require("lualine").setup({
      options = { theme = "catppuccin" },
      sections = {
        lualine_a = { "mode", "grapple" },
        lualine_b = {
          shortened_branch,
          "diff",
          "diagnostics",
          {
            require("noice").api.statusline.mode.get,
            cond = require("noice").api.statusline.mode.has,
            color = { fg = "#ff9e64" },
          },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "fugitive", "trouble" },
    })
  end,
}
