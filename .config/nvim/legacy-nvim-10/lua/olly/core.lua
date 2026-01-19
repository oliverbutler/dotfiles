local function get_log_file_path()
  local home = os.getenv("HOME")
  return home .. "/.config/nvim/logs/typescript.log"
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

local function call_typescript_function(action, params)
  -- Ensure action and params are provided
  if type(action) ~= "string" or type(params) ~= "table" then
    error("Invalid arguments")
  end

  local params_string = vim.fn.json_encode(params)

  local home = os.getenv("HOME")
  local bunIndex = home .. "/.config/nvim/core/index.ts"

  -- Construct command as an array of arguments
  local command = {
    "bun",
    "run",
    bunIndex,
    action,
    params_string, -- Remove shellescape since we're using array form
  }

  -- Log the command for debugging (with proper escaping for shell reproduction)
  local debug_command = string.format(
    "bun run %s %s %s",
    vim.fn.shellescape(bunIndex),
    vim.fn.shellescape(action),
    vim.fn.shellescape(params_string)
  )
  append_to_log("Shell equivalent: " .. debug_command)

  -- Execute command using vim.fn.system with raw arguments
  local result = vim.fn.system(command)
  local exit_code = vim.v.shell_error

  -- Log the exit code and result details
  append_to_log("Command exit code: " .. exit_code)
  append_to_log("Raw command output follows:")
  append_to_log("----------------------------------------")
  append_to_log("Result length: " .. #result)
  append_to_log("First 1000 characters of raw result:")
  append_to_log(result:sub(1, 1000))
  append_to_log("----------------------------------------")

  -- Store all non-log lines for debugging
  local non_log_lines = {}
  local last_line = nil
  local has_logs = false

  -- Process log messages and the final result
  for line in result:gmatch("[^\r\n]+") do
    if trim(line) ~= "" then -- Skip empty lines
      -- Log every line we receive
      append_to_log("RAW OUTPUT: " .. line)

      local log_prefix = "NVIM_LOG::"
      if line:find(log_prefix, 1, true) == 1 then
        has_logs = true
        local level, log_message = line:match("NVIM_LOG::(%w+)::(.+)")
        if level and log_message then
          local log_level_map = {
            DEBUG = vim.log.levels.DEBUG,
            INFO = vim.log.levels.INFO,
            WARN = vim.log.levels.WARN,
            ERROR = vim.log.levels.ERROR,
          }
          vim.notify(log_message, log_level_map[level], { title = "TypeScript Logger" })
        end
      else
        table.insert(non_log_lines, line)
        last_line = line
      end
    end
  end

  append_to_log("----------------------------------------")

  -- Try to decode the last non-log line as JSON
  if last_line then
    local decoded_result
    success, decoded_result = pcall(vim.fn.json_decode, last_line)
    if success then
      return decoded_result
    else
      -- Provide detailed error information
      local error_msg = string.format(
        "Failed to decode JSON result.\nCommand: %s\nRaw output:\n%s\nJSON decode error: %s",
        command,
        table.concat(non_log_lines, "\n"),
        decoded_result -- This will contain the error message from json_decode
      )
      error(error_msg)
    end
  end

  -- If it reaches here, there's no valid result
  local debug_info = string.format(
    "No valid result returned from TypeScript function\nCommand: %s\nRaw output:\n%s\nHad logs: %s",
    command,
    table.concat(non_log_lines, "\n"),
    has_logs and "yes" or "no"
  )
  append_to_log("ERROR: " .. debug_info)
  vim.notify(debug_info, vim.log.levels.ERROR, { title = "TypeScript Logger" })
  vim.notify("Logs available in " .. get_log_file_path(), vim.log.levels.INFO, { title = "TypeScript Logger" })
  error(debug_info)
end

-- Command to view logs
vim.api.nvim_create_user_command("TypeScriptLogs", function()
  vim.cmd("edit " .. get_log_file_path())
end, {})

return {
  call_typescript_function = call_typescript_function,
}
