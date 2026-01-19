-- Neotest - testing framework integration

vim.pack.add({
	{ src = "https://github.com/nvim-neotest/neotest" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/nvim-neotest/neotest-jest" },
	{ src = "https://github.com/nvim-neotest/neotest-go" },
	{ src = "https://github.com/marilari88/neotest-vitest" },
})

-----------------------------------------
-- Helper Functions
-----------------------------------------

local function get_log_file_path()
	local home = os.getenv("HOME")
	return home .. "/.config/nvim/logs/neotest-ai.log"
end

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

local function call_typescript_function(action, params)
	if type(action) ~= "string" or type(params) ~= "table" then
		error("Invalid arguments")
	end

	local params_string = vim.fn.json_encode(params)
	local home = os.getenv("HOME")
	local bunIndex = home .. "/.config/nvim/core/index.ts"

	local command = {
		"bun",
		"run",
		bunIndex,
		action,
		params_string,
	}

	local result = vim.fn.system(command)

	local last_line = nil
	for line in result:gmatch("[^\r\n]+") do
		if trim(line) ~= "" then
			local log_prefix = "NVIM_LOG::"
			if line:find(log_prefix, 1, true) == 1 then
				local level, log_message = line:match("NVIM_LOG::(%w+)::(.+)")
				if level and log_message then
					local log_level_map = {
						DEBUG = vim.log.levels.DEBUG,
						INFO = vim.log.levels.INFO,
						WARN = vim.log.levels.WARN,
						ERROR = vim.log.levels.ERROR,
					}
					vim.notify(log_message, log_level_map[level])
				end
			else
				last_line = line
			end
		end
	end

	if last_line then
		local success, decoded_result = pcall(vim.fn.json_decode, last_line)
		if success then
			return decoded_result
		end
	end

	return nil
end

-----------------------------------------
-- Setup
-----------------------------------------

require("neotest").setup({
	summary = {
		enabled = true,
		expand_errors = true,
		follow = true,
		mappings = {
			expand = { "<CR>", "<2-LeftMouse>" },
			expand_all = "e",
			output = "o",
			short = "O",
			attach = "a",
			jumpto = "i",
			stop = "u",
			run = "r",
		},
	},
	adapters = {
		require("neotest-go"),
		require("neotest-jest")({
			jestCommand = "pnpm jest --expand --runInBand",
			env = {},
			jestConfigFile = function(path)
				local file = vim.fn.expand("%:p")
				local new_config = vim.fn.getcwd() .. "/jest.config.ts"

				if string.find(file, "/libs/") then
					new_config = string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
				end

				return new_config
			end,
			cwd = function()
				local file = vim.fn.expand("%:p")
				local new_cwd = vim.fn.getcwd()
				if string.find(file, "/libs/") then
					new_cwd = string.match(file, "(.-/[^/]+/)src")
				end

				return new_cwd
			end,
		}),
	},
})

-----------------------------------------
-- AI Test Fixer
-----------------------------------------

local M = {}

-- Function to get the current test expectation block
M.get_current_test_block = function()
	local cur_line = vim.api.nvim_get_current_line()
	local cur_row = vim.api.nvim_win_get_cursor(0)[1]

	-- Check if the line contains toEqual or toStrictEqual
	local toEqual_pos = cur_line:find("toEqual%(") or cur_line:find("toStrictEqual%(")
	if not toEqual_pos then
		vim.notify("No toEqual or toStrictEqual found on the current line", vim.log.levels.WARN)
		return nil
	end

	-- Save current position
	local save_pos = vim.api.nvim_win_get_cursor(0)

	-- Move cursor to the opening parenthesis
	vim.api.nvim_win_set_cursor(0, { cur_row, toEqual_pos + (cur_line:find("toStrictEqual") and 12 or 7) })

	-- Use Vim's % motion to find the matching parenthesis
	vim.cmd("normal! %")
	local end_pos = vim.api.nvim_win_get_cursor(0)

	-- Go back to the opening parenthesis
	vim.api.nvim_win_set_cursor(0, { cur_row, toEqual_pos + (cur_line:find("toStrictEqual") and 12 or 7) })

	-- Get the text between the parentheses (including them)
	local start_line = cur_row
	local end_line = end_pos[1]

	-- Get all lines in the block
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Restore cursor position
	vim.api.nvim_win_set_cursor(0, save_pos)

	-- Join the lines and return the full block
	return table.concat(lines, "\n")
end

-- Function to fix test with Claude AI
M.fix_test_with_ai = function(replace_inline)
	-- Get the current test block with expectation
	local current_block = M.get_current_test_block()
	if not current_block then
		return
	end

	append_to_log("CURRENT BLOCK: " .. current_block)

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

		append_to_log("TEST ERROR OUTPUT: " .. error_output)

		-- Return to the original window
		vim.api.nvim_set_current_win(current_win)

		-- Close neotest output window
		vim.cmd("pclose")

		-- Check for API key
		local api_key = vim.fn.getenv("ANTHROPIC_API_KEY")
		if not api_key or api_key == vim.NIL or api_key == "" then
			vim.notify("ANTHROPIC_API_KEY environment variable not set", vim.log.levels.ERROR)
			append_to_log("ERROR: ANTHROPIC_API_KEY environment variable not set")
			return
		end

		vim.notify("Asking Claude to fix the test expectation... Please wait", vim.log.levels.INFO)
		append_to_log("INFO: Asking Claude to fix the test expectation...")

		-- Create prompt for Claude
		local prompt = [[
I have a failing Jest test. Help me fix the expectation to match the actual output.

Here's the test expectation:
```
]] .. current_block .. [[
```

And here's the test failure output:
```
]] .. error_output .. [[
```

Provide back only the FULL fixed expectation code, do not introduce comments/explanations, if you encounter variables used in the existing expectation, try to re-use them within the new output
]]

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
			api_key,
			payload_file,
			response_file
		)

		append_to_log("CURL COMMAND: " .. curl_cmd:gsub(api_key, "REDACTED"))

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

				append_to_log(
					"CLAUDE RAW RESPONSE: " ..
					response_json:sub(1, 500) .. (response_json:len() > 500 and "..." or "")
				)

				-- Parse the JSON response
				local parse_ok, response = pcall(vim.fn.json_decode, response_json)
				if not parse_ok or not response or not response.content or not response.content[1] then
					vim.notify(
						"Failed to parse API response: " ..
						vim.inspect(response_json:sub(1, 100)),
						vim.log.levels.ERROR
					)
					append_to_log("ERROR: Failed to parse API response: " ..
						vim.inspect(response_json:sub(1, 100)))
					return
				end

				local ai_response = response.content[1].text

				append_to_log("CLAUDE TEXT RESPONSE: " .. ai_response)

				-- Extract code block from the response (if present)
				local fixed_line = ai_response:match("```[%w%s]*\n(.-)```")
				if not fixed_line then
					fixed_line = ai_response:match("```(.-)```")
				end

				-- If no code block found, use the whole response
				fixed_line = fixed_line or ai_response

				-- Clean up the response
				fixed_line = trim(fixed_line)

				-- Remove trailing semicolon if present
				if fixed_line:sub(-1) == ";" then
					fixed_line = fixed_line:sub(1, -2)
				end

				append_to_log("EXTRACTED FIXED BLOCK: " .. fixed_line)

				-- Copy to clipboard
				vim.fn.setreg("+", fixed_line)
				vim.fn.setreg('"', fixed_line)

				if replace_inline then
					-- Return to the original buffer and position
					vim.api.nvim_set_current_buf(current_buf)
					vim.api.nvim_win_set_cursor(current_win, current_pos)

					-- Find the toEqual or toStrictEqual in the current line
					local cur_line = vim.api.nvim_get_current_line()
					local toEqual_pos = cur_line:find("toEqual%(") or
						cur_line:find("toStrictEqual%(")

					if toEqual_pos then
						-- Save current position
						local save_pos = vim.api.nvim_win_get_cursor(0)
						local cur_row = save_pos[1]

						-- Move cursor to the opening parenthesis
						vim.api.nvim_win_set_cursor(
							0,
							{ cur_row, toEqual_pos +
							(cur_line:find("toStrictEqual") and 12 or 7) }
						)

						-- Use Vim's % motion to find the matching parenthesis
						vim.cmd("normal! %")

						-- Go back to the opening parenthesis
						vim.api.nvim_win_set_cursor(
							0,
							{ cur_row, toEqual_pos +
							(cur_line:find("toStrictEqual") and 12 or 7) }
						)

						local original_line_number = vim.fn.line(".")

						-- Delete the content between parentheses (including parentheses)
						vim.cmd("normal! di(")

						-- Delete the whole line
						vim.cmd("normal! dd")

						-- move back up to the line above
						vim.cmd("normal! k")

						-- Split the fixed content by newlines and prepare for insertion
						local lines_to_insert = vim.fn.split(fixed_line, "\n")

						-- Insert the fixed content
						vim.api.nvim_put(lines_to_insert, "c", false, true)

						-- Save the file
						vim.cmd("write")

						vim.cmd(tostring(original_line_number) .. "G")

						vim.notify("Replaced test expectation with AI-fixed version",
							vim.log.levels.INFO)
					else
						vim.notify("Could not find toEqual or toStrictEqual in the current line",
							vim.log.levels.ERROR)
					end
				else
					vim.notify("Fixed test expectation copied to clipboard", vim.log.levels.INFO)
				end
			end,
		})
	end, 300)
end

M.get_test_output = function()
	require("neotest").output.open({
		enter = true,
		short = true,
	})

	vim.wait(100)

	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local test_output = table.concat(lines, "\n")

	local result = call_typescript_function("getTestExpectedObject", { testOutput = test_output })

	if result then
		vim.notify("Test output copied to clipboard", vim.log.levels.INFO)
		vim.fn.setreg("+", result)
	else
		vim.notify("Failed to parse test output", vim.log.levels.WARN)
	end

	vim.api.nvim_command("q")

	return result
end

M.paste_test_output = function()
	local output = M.get_test_output()
	if not output then
		return
	end

	local cur_line = vim.api.nvim_get_current_line()
	local toEqual_pos = cur_line:find("toEqual%(") or cur_line:find("toStrictEqual%(")

	if toEqual_pos then
		local after_toEqual = cur_line:sub(toEqual_pos)
		local paren_pos = after_toEqual:find("%(")

		if paren_pos then
			vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], toEqual_pos + paren_pos })
			vim.cmd("normal! di(")
			vim.cmd("normal! h")
			vim.api.nvim_put(vim.fn.split(output, "\n"), "", true, true)
			vim.notify("Replaced test expectation with actual output", vim.log.levels.INFO)
			vim.cmd("write")
		else
			vim.notify("Invalid format: couldn't find opening parenthesis", vim.log.levels.ERROR)
		end
	else
		vim.notify("No toEqual or toStrictEqual found on the current line", vim.log.levels.WARN)
	end
end

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
	-- Wait a bit for the window to open, then configure it
	vim.defer_fn(function()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local bufname = vim.api.nvim_buf_get_name(buf)
			if bufname:match("Neotest Summary") then
				vim.api.nvim_set_option_value("wrap", false, { win = win })
				vim.api.nvim_set_option_value("linebreak", false, { win = win })
			end
		end
	end, 50)
end, { desc = "Test summary" })

vim.keymap.set("n", "<leader>to", function()
	require("neotest").output.open({
		auto_close = true,
		short = true,
	})
end, { desc = "Test output (short)" })

vim.keymap.set("n", "<leader>tp", function()
	require("neotest").output.open({
		enter = true,
	})
end, { desc = "Test output (full)" })

vim.keymap.set("n", "<leader>tc", function()
	require("neotest").output_panel.clear()
end, { desc = "Test clear" })

vim.keymap.set("n", "<leader>tr", function()
	require("neotest").run.run()
end, { desc = "Test run" })

vim.keymap.set("n", "<leader>tl", function()
	require("neotest").run.run_last()
end, { desc = "Test last" })

vim.keymap.set("n", "<leader>tf", function()
	require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Test file" })

vim.keymap.set("n", "<leader>twf", function()
	require("neotest").watch.toggle(vim.fn.expand("%"))
end, { desc = "Test watch file" })

vim.keymap.set("n", "<leader>tws", function()
	require("neotest").watch.stop()
end, { desc = "Test watch stop" })

vim.keymap.set("n", "<leader>tww", function()
	require("neotest").watch.watch()
end, { desc = "Test watch" })

vim.keymap.set("n", "<leader>td", function()
	require("neotest").run.run({ strategy = "dap" })
end, { desc = "Test debug" })

vim.keymap.set("n", "<leader>ti", function()
	M.fix_test_with_ai(false)
end, { desc = "Fix test with AI (clipboard)" })

vim.keymap.set("n", "<leader>tI", function()
	M.fix_test_with_ai(true)
end, { desc = "Fix test with AI (replace)" })

vim.keymap.set("n", "<leader>tj", function()
	M.get_test_output()
end, { desc = "Get test output to clipboard" })

vim.keymap.set("n", "<leader>tJ", function()
	M.paste_test_output()
end, { desc = "Paste test output into expectation" })
