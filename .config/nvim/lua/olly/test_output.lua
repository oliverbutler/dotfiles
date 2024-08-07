local function split(str, sep)
  local fields = {}
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(str, pattern, function(c)
    fields[#fields + 1] = c
  end)
  return fields
end

local function process_test_output(output)
  local lines = split(output, "\n")
  local json_lines = {}

  for _, line in ipairs(lines) do
    -- Should return any lines before, AND including the line with pattern "+ Received"
    if line:match("+ Received") then
      -- Delete all lines before this line
      json_lines = {}
      goto continue
    end

    -- Remove lines starting with "-"
    if line:match("^-") then
      goto continue
    end

    -- Remove any lines that start with any number of blank spaces followed by "at"
    if line:match("^%s*at ") then
      goto continue
    end

    -- Replace any "Array [" with "[" if there is "Array [" in the line
    line = line:gsub("Array %[", "[")

    -- Replace any "Object {" with "{"
    line = line:gsub("Object {", "{")

    -- Remove any leading "+"
    line = line:gsub("^%+%s?", "")

    -- Remove all preceding spaces
    line = line:gsub("^%s+", "")

    table.insert(json_lines, line)

    ::continue::
  end

  -- Convert parsed lines into single JSON string
  local json_string = table.concat(json_lines, "\n")

  -- This step removes quotes from object keys
  json_string = json_string:gsub('"(%w+)":', "%1:")

  return json_string
end

return {
  process_test_output = process_test_output,
}
