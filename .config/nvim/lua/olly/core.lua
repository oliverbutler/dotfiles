local function call_typescript_function(action, params)
  -- Ensure action and params are provided
  if type(action) ~= "string" or type(params) ~= "table" then
    error("Invalid arguments")
  end

  local params_string = vim.fn.json_encode(params)

  local home = os.getenv("HOME")
  local bunIndex = home .. "/.config/nvim/core/index.ts"

  -- Construct command with the correct path to the TypeScript entry point
  local command = ("bun run " .. bunIndex .. " %s '%s'"):format(action, params_string)

  local handle, err = io.popen(command)
  if not handle then
    error("Failed to execute command: " .. err)
  end

  local result = handle:read("*a")
  local success, close_err = handle:close()
  if not success then
    error("Failed to close handle: " .. close_err)
  end

  -- Process log messages and the final result
  for line in result:gmatch("[^\r\n]+") do
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
        vim.notify(log_message, log_level_map[level], { title = "TypeScript Logger" })
      end
    else
      -- Assuming the last non-log line is the JSON result
      local decoded_result
      success, decoded_result = pcall(vim.fn.json_decode, line)
      if success then
        return decoded_result
      else
        error("Failed to decode JSON result: " .. line)
      end
    end
  end

  -- If it reaches here, there's no valid result
  error("No valid result returned from TypeScript function")
end

return {
  call_typescript_function = call_typescript_function,
}
