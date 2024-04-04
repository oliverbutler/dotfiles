return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      background = {     -- :h background
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false,     -- shows the '~' characters after the end of buffers
      term_colors = false,            -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
        enabled = false,              -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15,            -- percentage of the shade to apply to the inactive window
      },
      no_italic = false,              -- Force no italic
      no_bold = false,                -- Force no bold
      no_underline = false,           -- Force no underline
      styles = {                      -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" },      -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      color_overrides = {},
      custom_highlights = {
        -- Highlight for the selected item in the completion menu
        PmenuSel = { bg = "#4C566A", fg = "#ECEFF4" },
        -- Highlight for the scrollbar in the completion menu
        PmenuSbar = { bg = "#434C5E" },
        -- Optional: Adjust the background of the completion menu, if needed
        Pmenu = { bg = "#3B4252", fg = "#D8DEE9" },
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
      },
    },

    config = function()
      vim.cmd.colorscheme("catppuccin")

      -- Set highlight groups after colorscheme is applied
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#4C566A", fg = "#ECEFF4" })
      vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#434C5E" })
      vim.api.nvim_set_hl(0, "Pmenu", { bg = "#3B4252", fg = "#D8DEE9" })

      vim.g.airline_theme = "catppuccin"
    end,
  },
}
