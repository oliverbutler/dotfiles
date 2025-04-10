return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      local latte = require("catppuccin.palettes").get_palette("latte")

      -- Function to darken hex colors
      local function darken_hex(hex, percent)
        -- Remove '#' if present
        hex = hex:gsub("#", "")
        -- Convert hex to RGB
        local r = tonumber(hex:sub(1, 2), 16)
        local g = tonumber(hex:sub(3, 4), 16)
        local b = tonumber(hex:sub(5, 6), 16)
        -- Darken by percentage (multiply by (1 - percent/100))
        local factor = (1 - percent / 100)
        r = math.floor(r * factor)
        g = math.floor(g * factor)
        b = math.floor(b * factor)

        -- Ensure values stay in valid range
        r = math.min(math.max(r, 0), 255)
        g = math.min(math.max(g, 0), 255)
        b = math.min(math.max(b, 0), 255)

        -- Convert back to hex
        return string.format("#%02x%02x%02x", r, g, b)
      end


      -- Get NVIM_THEME directly from tmux environment
      local handle = io.popen("tmux show-environment -g NVIM_THEME 2>/dev/null")
      local result = handle and handle:read("*a") or ""
      if handle then handle:close() end

      -- Parse the value
      local nvimTheme = result:match("NVIM_THEME=(%w+)")

      -- Set the background if a valid theme is found
      if nvimTheme == "dark" or nvimTheme == "light" then
        vim.notify("NVIM_THEME is set to " .. nvimTheme)
        vim.o.background = nvimTheme
      end

      require("catppuccin").setup({
        flavour = "auto",
        background = { -- :h background
          light = "latte",
          dark = "mocha",
        },
        transparent_background = true, -- disables setting the background color.
        show_end_of_buffer = false,    -- shows the '~' characters after the end of buffers
        term_colors = true,            -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = false,             -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15,           -- percentage of the shade to apply to the inactive window
        },
        no_italic = false,             -- Force no italic
        no_bold = false,               -- Force no bold
        no_underline = false,          -- Force no underline
        styles = {                     -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = {},               -- Change the style of comments
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
        color_overrides = {
          all = {},
          latte = {
            -- base = darken_hex(latte.base, 10),
            -- crust = darken_hex(latte.crust, 10),
            -- mantle = darken_hex(latte.mantle, 10),
            -- overlay0 = darken_hex(latte.overlay0, 10),
            -- overlay1 = darken_hex(latte.overlay1, 10),
            -- overlay2 = darken_hex(latte.overlay2, 10),
            -- surface0 = darken_hex(latte.surface0, 10),
            -- surface1 = darken_hex(latte.surface1, 10),
            -- surface2 = darken_hex(latte.surface2, 10),
            blue = darken_hex(latte.blue, 10),
            flamingo = darken_hex(latte.flamingo, 10),
            green = darken_hex(latte.green, 10),
            lavender = darken_hex(latte.lavender, 10),
            maroon = darken_hex(latte.maroon, 10),
            mauve = darken_hex(latte.mauve, 10),
            peach = darken_hex(latte.peach, 10),
            pink = darken_hex(latte.pink, 10),
            red = darken_hex(latte.red, 10),
            rosewater = darken_hex(latte.rosewater, 10),
            sapphire = darken_hex(latte.sapphire, 10),
            sky = darken_hex(latte.sky, 10),
            subtext0 = darken_hex(latte.subtext0, 10),
            subtext1 = darken_hex(latte.subtext1, 10),
            teal = darken_hex(latte.teal, 10),
            text = darken_hex(latte.text, 10),
            yellow = darken_hex(latte.yellow, 10),
          },
          frappe = {},
          macchiato = {},
          mocha = {},
        },
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
          snacks = true,
          grug_far = true,
          leap = true,
          blink_cmp = true,
          mason = true,
          neotest = true,
        },
      })

      -- Apply the Catppuccin colorscheme
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
