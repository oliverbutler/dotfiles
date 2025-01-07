import { describe, expect, it } from "bun:test";
import { getTestExpectedObject } from "./index";
import { objectStringsAreEqual } from "./test-helpers";

describe("getTestExpectedObject", () => {
  it("should for a basic jest output", () => {
    const result = getTestExpectedObject({
      testOutput: `
should get the tax and remainder for a withdrawal fee: failed
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 1
+ Received  + 1

  Object {
-   "amount": 20,
+   "amount": 19,
    "currency": "GBP",
  }
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = `
{
  amount: 19,
  currency: "GBP"
}`;

    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for output with dates", () => {
    const result = getTestExpectedObject({
      testOutput: `
should get the tax and remainder for a withdrawal fee: failed
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 1
+ Received  + 1

  Object {
-   "mydate": 2021-12-12T00:00:00.000Z,
+   "mydate": 2025-01-07T11:41:07.258Z,
  }
    at Object.<anonymous> ()
[Terminal closed]

`,
    });

    const expectedOutput = `
{
     mydate: expect.any(Date)
} 
    `;

    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for boolean output", () => {
    const result = getTestExpectedObject({
      testOutput: `
Error: expect(received).toEqual(expected) // deep equality

Expected: true
Received: false
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = "\n     true\n      ";
    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for string output", () => {
    const result = getTestExpectedObject({
      testOutput: `
Error: expect(received).toEqual(expected) // deep equality

Expected: "hello world"
Received: "goodbye world"
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = `"hello world"`;
    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for number output", () => {
    const result = getTestExpectedObject({
      testOutput: `
Error: expect(received).toEqual(expected) // deep equality

Expected: 42
Received: 24
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = "42";
    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for nested object with arrays", () => {
    const result = getTestExpectedObject({
      testOutput: `
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 2
+ Received  + 2

  Object {
    "items": Array [
      Object {
-       "id": 1,
+       "id": 2,
        "name": "test",
-       "values": Array [1, 2, 3],
+       "values": Array [4, 5, 6],
      },
    ],
  }
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = `
{
  items: [
    {
      id: 2,
      name: "test",
      values: [4, 5, 6]
    }
  ]
}`;

    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for object with multiple dates", () => {
    const result = getTestExpectedObject({
      testOutput: `
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 2
+ Received  + 2

  Object {
-   "createdAt": 2023-01-01T00:00:00.000Z,
+   "createdAt": 2024-01-01T00:00:00.000Z,
    "user": Object {
-     "lastLogin": 2023-12-31T23:59:59.999Z,
+     "lastLogin": 2024-01-01T00:00:00.000Z,
    },
  }
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = `
{
  createdAt: expect.any(Date),
  user: {
    lastLogin: expect.any(Date)
  }
}`;

    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for array output", () => {
    const result = getTestExpectedObject({
      testOutput: `
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 1
+ Received  + 1

  Array [
-   1,
+   2,
    3,
    4,
  ]
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = `
[
  2,
  3,
  4
]`;

    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for null output", () => {
    const result = getTestExpectedObject({
      testOutput: `
Error: expect(received).toEqual(expected) // deep equality

Expected: null
Received: undefined
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = "null";
    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });
});
