import { describe, expect, it } from "bun:test";
import { getTestExpectedObject } from "./index";
import { formatWithPrettier } from "./format";

/**
 * Compares two object strings using prettier for normalization
 */
export async function objectStringsAreEqual(
  actual: string,
  expected: string,
): Promise<boolean> {
  const formattedActual = await formatWithPrettier("return" + actual);
  const formattedExpected = await formatWithPrettier("return" + expected);

  return formattedActual === formattedExpected;
}

describe("getTestExpectedObject", () => {
  it("should for a basic jest output", async () => {
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

    const expectedOutput = `{
  amount: 19,
  currency: "GBP",
}`;

    expect(
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for output with dates", async () => {
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

    const expectedOutput = `{
     mydate: expect.any(Date),
} 
    `;

    expect(
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for boolean output", async () => {
    const result = getTestExpectedObject({
      testOutput: `
Error: expect(received).toEqual(expected) // deep equality

Expected: true
Received: false
    at Object.<anonymous> ()
`,
    });

    const expectedOutput = "true";
    expect(
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for string output", async () => {
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
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for number output", async () => {
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
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for nested object with arrays", async () => {
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

    const expectedOutput = `{
  items: [
    {
      id: 2,
      name: "test",
      values: [4, 5, 6]
    }
  ]
}`;

    expect(
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for object with multiple dates", async () => {
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

    const expectedOutput = `{
  createdAt: expect.any(Date),
  user: {
    lastLogin: expect.any(Date),
  },
}`;

    expect(
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for array output", async () => {
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

    const expectedOutput = `[
  2,
  3,
  4,
]`;

    expect(
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for null output", async () => {
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
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });

  it("should work for multiple objects in a top level array", async () => {
    const result = getTestExpectedObject({
      testOutput: `
      should return MISSING_EMAIL error when the email is either not provided or is just spaces: failed
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 1
+ Received  + 1

  Array [
    Object {
      "foo": "bar",
    },
    Object {
-     "foo": "bazWRONG",
+     "foo": "baz",
    },
  ]
    at Object.<anonymous> (/Users/olly/projects/collective-application/libs/bmo/feature-member-actions/src/lib/member-actions.utils.spec.ts:96:24)
    at Promise.then.completed (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/utils.js:298:28)
    at new Promise (<anonymous>)
    at callAsyncCircusFn (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/utils.js:231:10)
    at _callCircusTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:316:40)
    at async _runTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:252:3)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:126:9)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:121:9)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:121:9)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:121:9)
    at async run (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:71:3)
    at async runAndTransformResultsToJestFormat (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/legacy-code-todo-rewrite/jestAdapterInit.js:122:21)
    at async jestAdapter (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/legacy-code-todo-rewrite/jestAdapter.js:79:19)
    at async runTestInternal (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-runner@29.6.4/node_modules/jest-runner/build/runTest.js:367:16)
    at async runTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-runner@29.6.4/node_modules/jest-runner/build/runTest.js:444:34)
`,
    });

    const expectedOutput = `[
      {
        foo: "bar",
      },
      {
        foo: "baz",
      }
    ]`;

    expect(
      await objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });
});
