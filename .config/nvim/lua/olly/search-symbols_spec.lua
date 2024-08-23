local function mock_web_devicons()
  -- Create a table to represent the module and its functions
  local web_devicons_mock = {}

  -- Add any functions or properties that your code might be calling
  -- For example, if your code calls `require('nvim-web-devicons').get_icon()`,
  -- you should mock this function.
  function web_devicons_mock.get_icon(name, ext)
    -- You can return a mock value or set up logic to return different values
    return "mock_icon", "mock_highlight_group"
  end

  -- Return the mock table when required
  return web_devicons_mock
end

package.loaded["nvim-web-devicons"] = mock_web_devicons()

local getFirstSymbol = require("lua.olly.search-symbols").get_first_symbol
local ripgrep_line_patterns = require("lua.olly.search-symbols").ripgrep_line_patterns

-- Helper function to run ripgrep on a string
local function run_ripgrep_on_string(pattern, content)
  -- Create a temporary file
  local temp_file = os.tmpname()

  -- Write content to the temp file
  local file = io.open(temp_file, "w")
  file:write(content)
  file:close()

  -- Run ripgrep
  local handle = io.popen(string.format("rg -e '%s' %s", pattern, temp_file))
  local result = handle:read("*a")
  handle:close()

  -- Remove the temporary file
  os.remove(temp_file)

  return result ~= ""
end

describe("ripgrep_line_patterns", function()
  describe("all", function()
    it("should match variable declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.all, "const foo = 'bar';"))
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.all, "async myFunc = () => {};"))
    end)

    it("should match function declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.all, "function myFunction() {"))
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.all, "async function asyncFunc() {"))
    end)

    it("should match class declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.all, "class MyClass {"))
    end)

    it("should match type and interface declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.all, "type MyType = {"))
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.all, "interface MyInterface {"))
    end)

    it("should not match regular assignments or function calls", function()
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.all, "x = 5;"))
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.all, "myFunction();"))
    end)
  end)

  describe("types", function()
    it("should match interface declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.types, "interface MyInterface {"))
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.types, "interface AnotherInterface{"))
    end)

    it("should match type declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.types, "type MyType = {"))
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.types, "type AnotherType="))
    end)

    it("should not match class or function declarations", function()
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.types, "class MyClass {"))
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.types, "function myFunc() {"))
    end)
  end)

  describe("classes", function()
    it("should match simple class declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.classes, "class MyClass {"))
    end)

    it("should match class declarations with extends", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.classes, "class ChildClass extends ParentClass {"))
    end)

    it("should match class declarations with implements", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.classes, "class MyClass implements MyInterface {"))
    end)

    it("should not match function or interface declarations", function()
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.classes, "function myFunction() {"))
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.classes, "interface MyInterface {"))
    end)
  end)

  describe("zod", function()
    it("should match zod schema declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.zod, "const mySchema = z.object({"))
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.zod, "const anotherSchema = z.string()"))
    end)

    it("should not match non-zod constant declarations", function()
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.zod, "const myVar = 5;"))
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.zod, "const obj = {z: 5};"))
    end)
  end)

  describe("react", function()
    it("should match functional component declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.react, "const MyComponent = () => {"))
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.react, "function MyComponent() {"))
    end)

    it("should match class component declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.react, "class MyComponent extends React.Component {"))
    end)

    it("should match memoized component declarations", function()
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.react, "const MyComponent = React.memo(() => {"))
      assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.react, "const AppRouter = memo((props) => {"))
    end)

    it("should match forwardRef component declarations", function()
      assert.is_true(
        run_ripgrep_on_string(ripgrep_line_patterns.react, "const MyComponent = React.forwardRef((props, ref) => {")
      )
      assert.is_true(
        run_ripgrep_on_string(ripgrep_line_patterns.react, "const MyComponent = forwardRef((props, ref) => {")
      )
      assert.is_true(
        run_ripgrep_on_string(
          ripgrep_line_patterns.react,
          "export const TextInput = forwardRef<HTMLInputElement, TextInputProps>("
        )
      )
    end)

    it("should not match non-component declarations", function()
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.react, "const myVar = 5;"))
      assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.react, "function helperFunction() {"))
    end)
  end)
end)

describe("getFirstSymbol", function()
  it("should return the first symbol in a simple assignment", function()
    assert.are.equal("foo", getFirstSymbol("const foo = 42"))
  end)

  it("should ignore keywords", function()
    assert.are.equal("bar", getFirstSymbol("function bar() {}"))
  end)

  it("should handle type definitions", function()
    assert.are.equal("Person", getFirstSymbol("interface Person {}"))
  end)

  it("should handle class definitions", function()
    assert.are.equal("MyClass", getFirstSymbol("class MyClass extends BaseClass {}"))
  end)

  it("should handle assignments with spaces", function()
    assert.are.equal("baz", getFirstSymbol("let   baz    =   123"))
  end)

  it("should return nil for invalid input", function()
    assert.is_nil(getFirstSymbol("const = 42"))
  end)

  it("should handle ts types", function()
    assert.are.equal("MyType", getFirstSymbol("type MyType = { foo: string }"))
    assert.are.equal("MyType2", getFirstSymbol("export type MyType2 = { foo: string }"))
  end)

  it("should be able to search classes", function()
    assert.are.equal("OnsiApiMembersController", getFirstSymbol("export class OnsiApiMembersController {"))
  end)
end)
