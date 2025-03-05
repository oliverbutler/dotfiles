local function get_log_file_path()
  local home = os.getenv("HOME")
  return home .. "/.config/nvim/logs/neotest-ai.log"
end

-- Add string trim function
local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

local function append_to_log(message)
  local log_file = get_log_file_path()
  local file = io.open(log_file, "a")
  if file then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    file:write(string.format("[%s] %s\n", timestamp, message))
    file:close()
  end
end

return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "marilari88/neotest-vitest",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-go",
    "sidlatau/neotest-dart",
  },
  -- Specifies when to load neotest
  keys = { "<leader>t" }, -- Example key bindings to trigger loading
  module = "neotest", -- Load when the neotest module is required
  cmd = { "TestFile", "TestNearest", "TestSuite", "TestLast", "TestVisit" }, -- Load for neotest commands
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-go"),
        --			require("neotest-vitest"),
        require("neotest-jest")({
          jestCommand = "pnpm jest --expand --runInBand",
          env = {},
          jestConfigFile = function(path)
            local file = vim.fn.expand("%:p")
            local new_config = vim.fn.getcwd() .. "/jest.config.ts"

            if string.find(file, "/libs/") then
              new_config = string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
            end

            -- vim.notify("Jest Config: " .. new_config)
            return new_config
          end,
          cwd = function()
            local file = vim.fn.expand("%:p")
            local new_cwd = vim.fn.getcwd()
            if string.find(file, "/libs/") then
              new_cwd = string.match(file, "(.-/[^/]+/)src")
            end

            -- vim.notify("CWD: " .. new_cwd)
            return new_cwd
          end,
        }),
        require("neotest-dart")({
          command = "fvm flutter",
          use_lsp = true,
          custom_test_method_names = {},
        }),
      },
    })

    local M = {}

    -- Function to extract the test output and store it in a variable

    -- Function to get the current line's test context
    M.get_current_test_line = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local cur_line = vim.api.nvim_get_current_line()

      -- Check if the line contains toEqual or toStrictEqual
      local toEqual_pos = cur_line:find("toEqual%(") or cur_line:find("toStrictEqual%(")
      if not toEqual_pos then
        vim.notify("No toEqual or toStrictEqual found on the current line", vim.log.levels.WARN)
        return nil
      end

      return cur_line
    end

    -- Function to fix test with Claude AI
    M.fix_test_with_ai = function(replace_inline)
      -- Get the current line with expectation
      local current_line = M.get_current_test_line()
      if not current_line then
        return
      end

      -- Log the current line
      append_to_log("CURRENT LINE: " .. current_line)

      -- Check if neotest is available
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        vim.notify("Neotest plugin not found", vim.log.levels.ERROR)
        append_to_log("ERROR: Neotest plugin not found")
        return
      end

      -- Save current window/buffer
      local current_win = vim.api.nvim_get_current_win()
      local current_buf = vim.api.nvim_get_current_buf()
      local current_pos = vim.api.nvim_win_get_cursor(current_win)

      -- Open neotest output
      neotest.output.open({ enter = true, short = true })

      -- Get neotest output after a short delay
      vim.defer_fn(function()
        -- Get the error output
        local error_bufnr = vim.api.nvim_get_current_buf()
        local error_lines = vim.api.nvim_buf_get_lines(error_bufnr, 0, -1, false)
        local error_output = table.concat(error_lines, "\n")

        -- Log the test error output
        append_to_log("TEST ERROR OUTPUT: " .. error_output)

        -- Return to the original window
        vim.api.nvim_set_current_win(current_win)

        -- Close neotest output window
        vim.cmd("pclose")

        -- Check for API key
        if not vim.env.ANTHROPIC_API_KEY then
          vim.notify("ANTHROPIC_API_KEY environment variable not set", vim.log.levels.ERROR)
          append_to_log("ERROR: ANTHROPIC_API_KEY environment variable not set")
          return
        end

        -- Show notification that we're processing
        vim.notify("Asking Claude to fix the test expectation... Please wait", vim.log.levels.INFO)
        append_to_log("INFO: Asking Claude to fix the test expectation...")

        -- Create prompt for Claude
        local prompt = [[
I have a failing Jest test. Help me fix the expectation to match the actual output.

Here's the test expectation line:
```
]] .. current_line .. [[
```

And here's the test failure output:
```
]] .. error_output .. [[
```

Only provide the fixed expectation line. Keep the same variable names and structure. 
Don't change the test logic itself. Provide ONLY the fixed line with no additional explanation.
]]

        -- Log the prompt sent to Claude
        append_to_log("CLAUDE PROMPT: " .. prompt)

        -- Create temporary files
        local prompt_file = vim.fn.tempname()
        local response_file = vim.fn.tempname()

        -- Write prompt to temporary file
        local f = io.open(prompt_file, "w")
        if not f then
          vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
          append_to_log("ERROR: Failed to create temporary file")
          return
        end
        f:write(prompt)
        f:close()

        -- Create the JSON payload file
        local payload_file = vim.fn.tempname()
        local payload = string.format(
          [[
{
  "model": "claude-3-5-haiku-20241022",
  "max_tokens": 8000,
  "messages": [
    {
      "role": "user",
      "content": %s
    }
  ]
}]],
          vim.fn.json_encode(prompt)
        )

        -- Log the payload (truncated for readability)
        append_to_log("CLAUDE API PAYLOAD: " .. payload:sub(1, 500) .. (payload:len() > 500 and "..." or ""))

        -- Write payload to file
        f = io.open(payload_file, "w")
        if not f then
          vim.notify("Failed to create payload file", vim.log.levels.ERROR)
          append_to_log("ERROR: Failed to create payload file")
          os.remove(prompt_file)
          return
        end
        f:write(payload)
        f:close()

        -- Prepare the API call
        local curl_cmd = string.format(
          [[
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: %s" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  --data @%s \
  -o %s
]],
          vim.env.ANTHROPIC_API_KEY,
          payload_file,
          response_file
        )

        -- Log the curl command (with API key redacted)
        append_to_log("CURL COMMAND: " .. curl_cmd:gsub(vim.env.ANTHROPIC_API_KEY, "REDACTED"))

        -- Execute the API call
        vim.fn.jobstart(curl_cmd, {
          on_exit = function(_, code)
            -- Clean up temporary prompt file
            os.remove(prompt_file)
            os.remove(payload_file)

            if code ~= 0 then
              vim.notify("API call failed with code: " .. code, vim.log.levels.ERROR)
              append_to_log("ERROR: API call failed with code: " .. code)
              os.remove(response_file)
              return
            end

            -- Read the response from file
            local resp_file = io.open(response_file, "r")
            if not resp_file then
              vim.notify("Failed to read API response", vim.log.levels.ERROR)
              append_to_log("ERROR: Failed to read API response")
              return
            end

            local response_json = resp_file:read("*all")
            resp_file:close()
            os.remove(response_file)

            -- Log the raw JSON response (truncated for readability)
            append_to_log(
              "CLAUDE RAW RESPONSE: " .. response_json:sub(1, 500) .. (response_json:len() > 500 and "..." or "")
            )

            -- Parse the JSON response
            local ok, response = pcall(vim.fn.json_decode, response_json)
            if not ok or not response or not response.content or not response.content[1] then
              vim.notify(
                "Failed to parse API response: " .. vim.inspect(response_json:sub(1, 100)),
                vim.log.levels.ERROR
              )
              append_to_log("ERROR: Failed to parse API response: " .. vim.inspect(response_json:sub(1, 100)))
              return
            end

            local ai_response = response.content[1].text

            -- Log the text response from Claude
            append_to_log("CLAUDE TEXT RESPONSE: " .. ai_response)

            -- Extract code block from the response (if present)
            local fixed_line = ai_response:match("```[%w%s]*\n(.-)
```")
            if not fixed_line then
              -- Try alternative pattern without language specification
              fixed_line = ai_response:match("```(.-)```")
            end

            -- If no code block found, use the whole response
            fixed_line = fixed_line or ai_response

            -- Clean up the response
            fixed_line = trim(fixed_line)

            -- Log the extracted fixed line
            append_to_log("EXTRACTED FIXED LINE: " .. fixed_line)

            -- Copy to clipboard
            vim.fn.setreg("+", fixed_line)
            vim.fn.setreg('"', fixed_line)

            if replace_inline then
              -- Return to the original buffer and position
              vim.api.nvim_set_current_buf(current_buf)
              vim.api.nvim_win_set_cursor(current_win, current_pos)

              -- Replace the current line with the fixed line
              vim.api.nvim_buf_set_lines(current_buf, current_pos[1] - 1, current_pos[1], false, { fixed_line })

              -- Save the file
              vim.cmd("write")

              vim.notify("Replaced test expectation with AI-fixed version", vim.log.levels.INFO)
            else
              vim.notify("Fixed test expectation copied to clipboard", vim.log.levels.INFO)
            end
          end,
        })
      end, 300) -- 300ms delay to ensure neotest output is loaded
    end
    M.get_test_output = function()
      require("neotest").output.open({
        enter = true,
        short = true,
      })

      -- Wait 100ms
      vim.wait(100)

      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local test_output = table.concat(lines, "\n")

      local result =
        require("olly.core").call_typescript_function("getTestExpectedObject", { testOutput = test_output })

      vim.notify(result, "info", {
        title = "TypeScript Function Result",
        icon = "🚀",
      })

      vim.fn.setreg("+", result)

      -- Escape the output output_panel (:q)
      vim.api.nvim_command("q")

      return result
    end

    M.paste_test_output = function()
      local output = M.get_test_output()

      local bufnr = vim.api.nvim_get_current_buf()
      local cur_line = vim.api.nvim_get_current_line()

      local toEqual_pos = cur_line:find("toEqual%(") or cur_line:find("toStrictEqual%(")

      if toEqual_pos then
        -- Extract content before toEqual or toStrictEqual
        local before_toEqual = cur_line:sub(1, toEqual_pos - 1)

        -- The text after toEqual until end of line
        local after_toEqual = cur_line:sub(toEqual_pos)

        -- Find the opening parenthesis position after toEqual
        local paren_pos = after_toEqual:find("%(")

        if paren_pos then
          -- Move the cursor to the right position
          vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], toEqual_pos + paren_pos })

          -- Delete the text inside the parentheses
          vim.cmd("normal! di(")

          -- Move cursor one position to the left to be inside the parentheses
          vim.cmd("normal! h")

          -- Paste the new content
          vim.api.nvim_put(vim.fn.split(output, "\n"), "", true, true)

          vim.notify("Replaced test expectation with actual output")

          -- Save the file
          vim.cmd("write")
        else
          vim.notify("Invalid format: couldn't find opening parenthesis", vim.log.levels.ERROR)
        end
      else
        vim.notify("No toEqual or toStrictEqual found on the current line", vim.log.levels.WARN)
      end
    end

    vim.keymap.set("n", "<leader>tj", function()
      M.get_test_output()
    end, { noremap = true, silent = true, desc = "Get test output and copy to clipboard" })

    -- Command to fix Jest test expectation based on yanked test and neotest output
    vim.api.nvim_create_user_command("FixTest", function()
      -- Get the yanked text
      local yanked_test = vim.fn.getreg('"')

      if yanked_test == "" then
        vim.notify("No text yanked. Select and yank a test first (use 'y')", vim.log.levels.ERROR)
        return
      end

      -- Check if neotest is available
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        vim.notify("Neotest plugin not found", vim.log.levels.ERROR)
        append_to_log("ERROR: Neotest plugin not found")
        return
      end

      -- Save current window/buffer
      local current_win = vim.api.nvim_get_current_win()

      -- Log the yanked test
      append_to_log("YANKED TEST: " .. yanked_test)

      -- Open neotest output
      neotest.output.open({ enter = true, short = true })

      -- Get neotest output after a short delay
      vim.defer_fn(function()
        -- Get the error output
        local error_bufnr = vim.api.nvim_get_current_buf()
        local error_lines = vim.api.nvim_buf_get_lines(error_bufnr, 0, -1, false)
        local error_output = table.concat(error_lines, "\n")

        -- Log the test error output
        append_to_log("TEST ERROR OUTPUT: " .. error_output)

        -- Return to the original window
        vim.api.nvim_set_current_win(current_win)

        -- Close neotest output window
        vim.cmd("pclose")

        -- Check for API key
        if not vim.env.ANTHROPIC_API_KEY then
          vim.notify("ANTHROPIC_API_KEY environment variable not set", vim.log.levels.ERROR)
          append_to_log("ERROR: ANTHROPIC_API_KEY environment variable not set")
          return
        end

        -- Show notification that we're processing
        vim.notify("Asking Claude to fix the test... Please wait", vim.log.levels.INFO)
        append_to_log("INFO: Asking Claude to fix the test...")

        -- Create prompt for Claude
        local prompt = [[
I have a failing Jest test. Help me fix the expectation to match the actual output.

Here's the test:
```
]] .. yanked_test .. [[
```

And here's the test failure output:
```
]] .. error_output .. [[
```

Only update the expectation to match the actual values. Don't change the test logic itself. Provide ONLY the complete fixed code with no additional explanation.
]]

        -- Log the prompt sent to Claude
        append_to_log("CLAUDE PROMPT: " .. prompt)

        -- Create temporary files
        local prompt_file = vim.fn.tempname()
        local response_file = vim.fn.tempname()

        -- Write prompt to temporary file
        local f = io.open(prompt_file, "w")
        if not f then
          vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
          append_to_log("ERROR: Failed to create temporary file")
          return
        end
        f:write(prompt)
        f:close()

        -- Create the JSON payload file
        local payload_file = vim.fn.tempname()
        local payload = string.format(
          [[
{
  "model": "claude-3-5-haiku-20241022",
  "max_tokens": 8000,
  "messages": [
    {
      "role": "user",
      "content": %s
    }
  ]
}]],
          vim.fn.json_encode(prompt)
        )

        -- Log the payload (truncated for readability)
        append_to_log("CLAUDE API PAYLOAD: " .. payload:sub(1, 500) .. (payload:len() > 500 and "..." or ""))

        -- Write payload to file
        f = io.open(payload_file, "w")
        if not f then
          vim.notify("Failed to create payload file", vim.log.levels.ERROR)
          append_to_log("ERROR: Failed to create payload file")
          os.remove(prompt_file)
          return
        end
        f:write(payload)
        f:close()

        -- Prepare the API call
        local curl_cmd = string.format(
          [[
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: %s" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  --data @%s \
  -o %s
]],
          vim.env.ANTHROPIC_API_KEY,
          payload_file,
          response_file
        )

        -- Log the curl command (with API key redacted)
        append_to_log("CURL COMMAND: " .. curl_cmd:gsub(vim.env.ANTHROPIC_API_KEY, "REDACTED"))

        -- Execute the API call
        vim.fn.jobstart(curl_cmd, {
          on_exit = function(_, code)
            -- Clean up temporary prompt file
            os.remove(prompt_file)
            os.remove(payload_file)

            if code ~= 0 then
              vim.notify("API call failed with code: " .. code, vim.log.levels.ERROR)
              append_to_log("ERROR: API call failed with code: " .. code)
              os.remove(response_file)
              return
            end

            -- Read the response from file
            local resp_file = io.open(response_file, "r")
            if not resp_file then
              vim.notify("Failed to read API response", vim.log.levels.ERROR)
              append_to_log("ERROR: Failed to read API response")
              return
            end

            local response_json = resp_file:read("*all")
            resp_file:close()
            os.remove(response_file)

            -- Log the raw JSON response (truncated for readability)
            append_to_log(
              "CLAUDE RAW RESPONSE: " .. response_json:sub(1, 500) .. (response_json:len() > 500 and "..." or "")
            )

            -- Parse the JSON response
            local ok, response = pcall(vim.fn.json_decode, response_json)
            if not ok or not response or not response.content or not response.content[1] then
              vim.notify(
                "Failed to parse API response: " .. vim.inspect(response_json:sub(1, 100)),
                vim.log.levels.ERROR
              )
              append_to_log("ERROR: Failed to parse API response: " .. vim.inspect(response_json:sub(1, 100)))
              return
            end

            local ai_response = response.content[1].text

            -- Log the text response from Claude
            append_to_log("CLAUDE TEXT RESPONSE: " .. ai_response)

            -- Extract code block from the response (if present)
            local code_block = ai_response:match("```[%w%s]*\n(.-)\n```")
            if not code_block then
              -- Try alternative pattern without language specification
              code_block = ai_response:match("```(.-)\n```")
            end

            -- If no code block found, use the whole response
            local fixed_test = code_block or ai_response

            -- Log the extracted code/fixed test
            append_to_log("EXTRACTED FIXED TEST: " .. fixed_test)

            -- Log the new assertion for debugging
            vim.notify("New Assertion:", fixed_test)

            -- Explicitly set the default and plus registers
            vim.fn.setreg('"', fixed_test) -- default register
            vim.fn.setreg("+", fixed_test) -- system clipboard register

            -- Notify user that fixed test is ready to paste
            vim.notify("Fixed test copied to register. Paste with 'p'", vim.log.levels.INFO)
            append_to_log("INFO: Fixed test copied to register")
          end,
        })
      end, 300) -- 300ms delay to ensure neotest output is loaded
    end, {})

    -- Optional: Create a shorter command alias
    vim.api.nvim_create_user_command("FT", function()
      vim.cmd("FixTest")
    end, {})

    vim.keymap.set("n", "<leader>tJ", function()
      M.paste_test_output()
    end, { noremap = true, silent = true, desc = "Paste test output into toEqual/toStrictEqual" })

    vim.keymap.set("n", "<leader>ti", function()
      M.fix_test_with_ai(false)
    end, { noremap = true, silent = true, desc = "Fix test with AI (copy to clipboard)" })

    vim.keymap.set("n", "<leader>tI", function()
      M.fix_test_with_ai(true)
    end, { noremap = true, silent = true, desc = "Fix test with AI (replace inline)" })

    vim.keymap.set("n", "<leader>ts", ":Neotest summary<CR>", { desc = "Show Neotest summary" })

    vim.keymap.set("n", "<leader>to", function()
      require("neotest").output.open({
        auto_close = true,
        short = true,
      })
    end, { desc = "[T]est [O]utput (short)" })

    vim.keymap.set("n", "<leader>tO", function()
      require("neotest").output.open({
        enter = true,
      })
    end, { desc = "[T]est [O]utput (full)" })

    vim.keymap.set("n", "<leader>tp", function()
      require("neotest").output_panel.toggle()
    end, { desc = "[T]est Output [P]anel" })

    vim.keymap.set("n", "<leader>tc", function()
      require("neotest").output_panel.clear()
    end, { desc = "[T]est [C]lear" })

    vim.keymap.set("n", "<leader>tr", function()
      require("neotest").run.run()
    end, { desc = "[T]est [R]un" })

    vim.keymap.set("n", "<leader>tl", function()
      require("neotest").run.run_last()
    end, { desc = "[T]est [L]ast" })

    vim.keymap.set("n", "<leader>tf", function()
      require("neotest").run.run(vim.fn.expand("%"))
    end, { desc = "[T]est [F]ile" })

    -- Setup test watching, running the last ran test when related files change using the neotest.watch api

    vim.keymap.set("n", "<leader>twf", function()
      require("neotest").watch.toggle(vim.fn.expand("%"))
    end, { desc = "[T]est [W]atch [File]" })

    vim.keymap.set("n", "<leader>tws", function()
      require("neotest").watch.stop()
    end, { desc = "[T]est [W]atch [S]top" })

    vim.keymap.set("n", "<leader>tww", function()
      require("neotest").watch.watch()
    end, { desc = "[T]est [W]atch" })

    -- debugging

    vim.keymap.set("n", "<leader>td", function()
      require("dapui").open()

      require("neotest").run.run({ strategy = "dap" })
    end, { desc = "[T]est [D]ebug" })
  end,
}
