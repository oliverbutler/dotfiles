local api_configs = {
  {
    env_var = "ANTHROPIC_API_KEY",
    onepass_name = "Anthropic API Key",
  },
  {
    env_var = "GROQ_API_KEY",
    onepass_name = "Groq API Key",
  },
  {
    env_var = "TAVILY_API_KEY",
    onepass_name = "Tavily API Key",
  },
}

local function load_api_keys()
  local home = os.getenv("HOME")
  local keys_file = home .. "/.config/nvim/.api_keys"
  local stored_keys = {}

  -- Try to load existing keys
  local f = io.open(keys_file, "r")
  if f then
    for line in f:lines() do
      local key, value = line:match("([^=]+)=(.*)")
      if key and value then
        stored_keys[key:gsub("^%s*(.-)%s*$", "%1")] = value:gsub("^%s*(.-)%s*$", "%1")
      end
    end
    f:close()
  end
  return stored_keys, keys_file
end

local function get_api_key(config, stored_keys, keys_file)
  -- Check if key exists in stored keys
  if stored_keys[config.env_var] then
    return stored_keys[config.env_var]
  end

  vim.notify("Retrieving " .. config.onepass_name)
  -- If not stored, retrieve it from 1Password
  local handle = io.popen(
    'op item get "' .. config.onepass_name .. '" --account "5S2IFKBEWJARZAMDT64SKMOSVA" --fields password --reveal'
  )

  if handle then
    local result = handle:read("*a")
    handle:close()
    result = result:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace

    -- Store the key for future use
    local f = io.open(keys_file, "a")
    if f then
      f:write(config.env_var .. "=" .. result .. "\n")
      f:close()
    end

    return result
  else
    print("Failed to get " .. config.onepass_name)
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
  keys = {
    {
      "<leader>ak",
      function()
        vim.cmd("AvanteClear")
        vim.cmd("AvanteToggle")
        vim.defer_fn(function()
          vim.cmd("AvanteToggle")
        end, 50)
      end,
      {
        noremap = true,
        silent = true,
        description = "Clear history and refresh Avante",
      },
    },
  },
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
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
    -- Load stored keys and get file path
    local stored_keys, keys_file = load_api_keys()

    -- Set up all API keys
    for _, config in ipairs(api_configs) do
      local api_key = get_api_key(config, stored_keys, keys_file)
      if api_key then
        vim.env[config.env_var] = api_key
      end
    end

    require("avante").setup({
      hints = {
        enabled = false,
      },
      file_selector = {
        provider = "fzf",
        provider_opts = {},
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
      },

      provider = "claude", -- In this example, use Claude for planning, but you can also use any provider you want.
      -- cursor_applying_provider = "groq", -- In this example, use Groq for applying, but you can also use any provider you want.
      -- behaviour = {
      --   enable_cursor_planning_mode = true, -- enable cursor planning mode!
      -- },

      web_search_engine = {
        provider = "tavily",
      },

      vendors = {
        groq = { -- define groq provider
          __inherited_from = "openai",
          api_key_name = "GROQ_API_KEY",
          endpoint = "https://api.groq.com/openai/v1/",
          model = "qwen-2.5-coder-32b",
          max_tokens = 20000,
        },
      },
    })
  end,
}
