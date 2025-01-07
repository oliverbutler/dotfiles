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
    at Object.<anonymous> (/Users/olly/projects/collective-application/libs/shared/util-money/src/lib/shared-util-money.spec.ts:173:17)
    at Promise.then.completed (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/utils.js:298:28)
    at new Promise (<anonymous>)
    at callAsyncCircusFn (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/utils.js:231:10)
    at _callCircusTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:316:40)
    at async _runTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:252:3)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:126:9)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:121:9)
    at async run (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:71:3)
    at async runAndTransformResultsToJestFormat (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/legacy-code-todo-rewrite/jestAdapterInit.js:122:21)
    at async jestAdapter (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/legacy-code-todo-rewrite/jestAdapter.js:79:19)
    at async runTestInternal (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-runner@29.6.4/node_modules/jest-runner/build/runTest.js:367:16)
    at async runTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-runner@29.6.4/node_modules/jest-runner/build/runTest.js:444:34)
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
    at Object.<anonymous> (/Users/olly/projects/collective-application/libs/shared/util-money/src/lib/shared-util-money.spec.ts:175:36)
    at Promise.then.completed (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/utils.js:298:28)
    at new Promise (<anonymous>)
    at callAsyncCircusFn (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/utils.js:231:10)
    at _callCircusTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:316:40)
    at async _runTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:252:3)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:126:9)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:121:9)
    at async run (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:71:3)
    at async runAndTransformResultsToJestFormat (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/legacy-code-todo-rewrite/jestAdapterInit.js:122:21)
    at async jestAdapter (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/legacy-code-todo-rewrite/jestAdapter.js:79:19)
    at async runTestInternal (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-runner@29.6.4/node_modules/jest-runner/build/runTest.js:367:16)
    at async runTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-runner@29.6.4/node_modules/jest-runner/build/runTest.js:444:34)
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

  it("should work for non-object output", () => {
    const result = getTestExpectedObject({
      testOutput: `
      should get the tax and remainder for a withdrawal fee: failed
Error: expect(received).toEqual(expected) // deep equality

Expected: true
Received: {"foo": "bar"}
    at Object.<anonymous> (/Users/olly/projects/collective-application/libs/shared/util-money/src/lib/shared-util-money.spec.ts:175:28)
    at Promise.then.completed (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/utils.js:298:28)
    at new Promise (<anonymous>)
    at callAsyncCircusFn (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/utils.js:231:10)
    at _callCircusTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:316:40)
    at async _runTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:252:3)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:126:9)
    at async _runTestsForDescribeBlock (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:121:9)
    at async run (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/run.js:71:3)
    at async runAndTransformResultsToJestFormat (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/legacy-code-todo-rewrite/jestAdapterInit.js:122:21)
    at async jestAdapter (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-circus@29.6.4/node_modules/jest-circus/build/legacy-code-todo-rewrite/jestAdapter.js:79:19)
    at async runTestInternal (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-runner@29.6.4/node_modules/jest-runner/build/runTest.js:367:16)
    at async runTest (/Users/olly/projects/collective-application/node_modules/.pnpm/jest-runner@29.6.4/node_modules/jest-runner/build/runTest.js:444:34)

`,
    });

    const expectedOutput = `
     true
      `;

    expect(
      objectStringsAreEqual(result, expectedOutput),
      `Expected normalized strings to match.\nGot: ${result}\nExpected: ${expectedOutput}`,
    ).toBe(true);
  });
});
