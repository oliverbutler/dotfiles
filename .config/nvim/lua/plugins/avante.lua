local function get_anthropic_api_key()
  local home = os.getenv("HOME")
  local key_file = home .. "/.config/nvim/.anthropic_api_key"

  -- Check if the key file exists
  local f = io.open(key_file, "r")
  if f then
    local api_key = f:read("*all")
    f:close()
    return api_key:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
  end

  vim.notify("Retrieving Anthropic API Key")
  -- If not stored, retrieve it from 1Password
  local handle =
    io.popen('op item get "Anthropic API Key" --account "5S2IFKBEWJARZAMDT64SKMOSVA" --fields password --reveal')

  if handle then
    local result = handle:read("*a")
    handle:close()
    result = result:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace

    -- Store the key for future use
    f = io.open(key_file, "w")
    if f then
      f:write(result)
      f:close()
    end

    return result
  else
    print("Failed to get Anthropic API Key")
    return nil
  end
end

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false,
  opts = {},
  build = "make",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "zbirenbaum/copilot.lua",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  config = function()
    vim.notify("Configuring Avante", "info", { title = "Avante" })
    local api_key = get_anthropic_api_key()
    vim.notify("API Key: " .. api_key)
    if api_key then
      vim.env.ANTHROPIC_API_KEY = api_key
    end

    require("avante").setup()
  end,
}
