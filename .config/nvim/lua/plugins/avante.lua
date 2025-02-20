local api_configs = {
  {
    env_var = "ANTHROPIC_API_KEY",
    onepass_name = "Anthropic API Key",
    file_name = ".anthropic_api_key",
  },
  {
    env_var = "GROQ_API_KEY",
    onepass_name = "Groq API Key",
    file_name = ".groq_api_key",
  },
  {
    env_var = "TAVILY_API_KEY",
    onepass_name = "Tavily API Key",
    file_name = ".tavily_api_key",
  },
}

local function get_api_key(config)
  local home = os.getenv("HOME")
  local key_file = home .. "/.config/nvim/" .. config.file_name

  -- Check if the key file exists
  local f = io.open(key_file, "r")
  if f then
    local api_key = f:read("*all")
    f:close()
    return api_key:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
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
    f = io.open(key_file, "w")
    if f then
      f:write(result)
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
      ":AvanteClear<CR>",
      {
        noremap = true,
        silent = true,
        description = "Clear history",
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
    -- Set up all API keys
    for _, config in ipairs(api_configs) do
      local api_key = get_api_key(config)
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
      cursor_applying_provider = "groq", -- In this example, use Groq for applying, but you can also use any provider you want.
      behaviour = {
        --- ... existing behaviours
        enable_cursor_planning_mode = true, -- enable cursor planning mode!
      },

      web_search_engine = {
        provider = "tavily",
      },

      vendors = {
        groq = { -- define groq provider
          __inherited_from = "openai",
          api_key_name = "GROQ_API_KEY",
          endpoint = "https://api.groq.com/openai/v1/",
          model = "qwen-2.5-coder-32b",
          max_tokens = 8192, -- remember to increase this value, otherwise it will stop generating halfway
        },
      },
    })
  end,
}
