local getFirstSymbol = require("search-symbols").get_first_symbol

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
end)
