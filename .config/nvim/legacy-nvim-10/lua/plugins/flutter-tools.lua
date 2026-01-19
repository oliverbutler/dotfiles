return {
  "akinsho/flutter-tools.nvim",
  ft = "dart",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for vim.ui.select
    "saghen/blink.cmp", -- add dependency for capabilities
  },
  config = function()
    -- Function to get the active FVM Flutter path
    local function get_fvm_flutter_path()
      -- Try to get the project-specific FVM config first
      local handle = io.popen("[ -f .fvm/fvm_config.json ] && cat .fvm/fvm_config.json 2>/dev/null")
      if handle then
        local result = handle:read("*a")
        handle:close()

        -- Parse the JSON if it exists
        if result and result ~= "" then
          local ok, parsed = pcall(vim.json.decode, result)
          if ok and parsed and parsed.flutterSdkVersion then
            local version = parsed.flutterSdkVersion
            local path = vim.fn.expand("$HOME/fvm/versions/" .. version .. "/bin/flutter")
            if vim.fn.filereadable(path) == 1 then
              return path
            end
          end
        end
      end

      -- If no project config or couldn't read it, try the global/default FVM version
      local handle2 = io.popen("fvm list 2>/dev/null | grep '\\*' | awk '{print $2}'")
      if handle2 then
        local version = handle2:read("*l")
        handle2:close()

        if version and version ~= "" then
          local path = vim.fn.expand("$HOME/fvm/versions/" .. version .. "/bin/flutter")
          if vim.fn.filereadable(path) == 1 then
            return path
          end
        end
      end

      -- Fallback to the system Flutter if available
      local handle3 = io.popen("which flutter 2>/dev/null")
      if handle3 then
        local path = handle3:read("*l")
        handle3:close()
        if path and path ~= "" then
          return path
        end
      end

      -- Last resort: try the default FVM path
      return vim.fn.expand("$HOME/fvm/default/bin/flutter")
    end

    -- Get the Flutter path
    local flutter_path = get_fvm_flutter_path()

    -- Derive the Dart SDK path from the Flutter path
    local dart_sdk_path = flutter_path:gsub("/bin/flutter$", "/bin/cache/dart-sdk")

    -- Log the paths in a single notification for less noise
    vim.notify("Flutter: " .. flutter_path .. "\nDart SDK: " .. dart_sdk_path, vim.log.levels.INFO, {
      title = "Flutter Tools",
      icon = "🐦",
    })

    require("flutter-tools").setup({
      lsp = {
        on_attach = function(client, bufnr)
          -- You can add your LSP keybindings here
        end,
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        -- Use dynamically determined Flutter path
        flutter_path = flutter_path,
        -- Use the Dart SDK bundled with Flutter
        dart_sdk_path = dart_sdk_path,
      },
      -- Enable debug logs for the plugin
      dev_log = {
        enabled = true,
        open_cmd = "tabedit",
      },
      -- Use FVM for Flutter commands
      fvm = true,
    })
  end,
}
