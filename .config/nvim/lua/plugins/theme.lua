return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        borderless_telescope = false,
        extensions = {
          telescope = true,
          notify = true,
          mini = true,
        },
        theme = {
          variant = "auto",
          overrides = function(t)
            return { SmartOpenDirectory = { fg = t.grey } }
          end,
        },
      })

      vim.cmd("colorscheme cyberdream")

      -- Add a custom keybinding to toggle the colour scheme
      vim.api.nvim_set_keymap("n", "<leader>tt", ":CyberdreamToggleMode<CR>", { noremap = true, silent = true })

      -- The event data property will contain a string with either "default" or "light" respectively
      vim.api.nvim_create_autocmd("User", {
        pattern = "CyberdreamToggleMode",
        callback = function(event)
          print("Switched to " .. event.data .. " mode!")
        end,
      })
    end,
  },
}
