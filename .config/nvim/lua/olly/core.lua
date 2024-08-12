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

  vim.notify(result)

  local decoded_result
  success, decoded_result = pcall(vim.fn.json_decode, result)
  if not success then
    error("Failed to decode JSON result: " .. decoded_result)
  end

  return decoded_result
end

return {
  call_typescript_function = call_typescript_function,
}
