return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      background = { -- :h background
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
      term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
      },
      no_italic = false, -- Force no italic
      no_bold = false, -- Force no bold
      no_underline = false, -- Force no underline
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
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
      custom_highlights = {},
      default_integrations = true,
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
        diffview = true,
        fzf = true,
        grug_far = true,
        leap = true,
        blink_cmp = true,
        mason = true,
        neotest = true,
      },
    },

    config = function()
      -- Apply the Catppuccin colorscheme
      vim.cmd.colorscheme("catppuccin")

      -- Load Catppuccin color palette
      local colors = require("catppuccin.palettes").get_palette()

      -- Define all custom highlight groups
      local CustomHighlights = {
        -- General highlight groups
        Normal = { bg = "none" },
        NormalFloat = { bg = "none" },
        PmenuSel = { bg = colors.surface2, fg = colors.text },
        PmenuSbar = { bg = colors.surface1 },
        Pmenu = { bg = colors.surface0, fg = colors.overlay2 },

        -- Telescope highlight groups
        TelescopeMatching = { fg = colors.flamingo },
        TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },
        TelescopePromptPrefix = { bg = colors.surface0 },
        TelescopePromptNormal = { bg = colors.surface0 },
        TelescopeResultsNormal = { bg = colors.mantle },
        TelescopePreviewNormal = { bg = colors.mantle },
        TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
        TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
        TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
        TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
        TelescopeResultsTitle = { fg = colors.mantle },
        TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
      }

      -- Apply all custom highlight groups
      for hl, col in pairs(CustomHighlights) do
        vim.api.nvim_set_hl(0, hl, col)
      end

      -- Apply Airline theme
      vim.g.airline_theme = "catppuccin"
    end,
  },
}
