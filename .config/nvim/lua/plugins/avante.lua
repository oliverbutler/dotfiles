local function encrypt_key(key)
  local handle = io.popen("echo '" .. key .. "' | openssl enc -aes-256-cbc -a -salt -pass pass:your_secret_passphrase")
  local result = handle:read("*a")
  handle:close()
  return result
end

local function decrypt_key(encrypted_key)
  local handle =
    io.popen("echo '" .. encrypted_key .. "' | openssl enc -aes-256-cbc -d -a -salt -pass pass:your_secret_passphrase")
  local result = handle:read("*a")
  handle:close()
  return result:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
end

local function get_anthropic_api_key()
  local home = os.getenv("HOME")
  local key_file = home .. "/.config/nvim/.anthropic_api_key"

  -- Check if the encrypted key file exists
  local f = io.open(key_file, "r")
  if f then
    local encrypted_key = f:read("*all")
    f:close()
    -- Decrypt the key (you'll need to implement this function)
    return decrypt_key(encrypted_key)
  end

  -- If not stored, retrieve it from 1Password
  local handle = io.popen('op item get "Anthropic API Key" --fields password')
  if handle then
    local result = handle:read("*a")
    handle:close()
    result = result:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace

    -- Encrypt and store the key for future use
    local encrypted_key = encrypt_key(result)
    f = io.open(key_file, "w")
    if f then
      f:write(encrypted_key)
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
  version = false, -- set this if you want to always pull the latest change
  opts = {
    -- add any opts here
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  config = function()
    local api_key = get_anthropic_api_key()
    if api_key then
      vim.env.ANTHROPIC_API_KEY = api_key
    end
    require("avante").setup()
  end,
}
