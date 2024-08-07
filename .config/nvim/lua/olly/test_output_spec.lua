local process_test_output = require("test_output").process_test_output
describe("process_test_output", function()
  it("simple", function()
    local input = [[
should return empty history if no pay runs: failed
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 10
+ Received  + 10

  Object {
-    "id": "pc_clxx3786s0004ufmj6kwkf5cv",
+    "id": "pc_clxx3bt5600042dmj2vuvf3ym",
    "type": "PayCycle"
   }
    at Object.<anonymous> (/Users/olly/project/path/to/file.spec.ts:377:28)
    at processTicksAndRejections (node:internal/process/task_queues:95:5)
]]

    local expected_output = [[
{
id: "pc_clxx3bt5600042dmj2vuvf3ym",
type: "PayCycle"
}]]

    local output = process_test_output(input)

    assert.are.same(expected_output, output)
  end)

  it("simple array", function()
    local input = [==[
should return empty history if no pay runs: failed
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 3
+ Received  + 3

  Array [
    Object {
-     "id": "pc_clxx3786s0004ufmj6kwkf5cv",
+     "id": "pc_clxx3epdp0004upmjfjj94jr8",
      "type": "PayCycle",
    },
    Object {
-     "date": "2024-06-27 10:53:42",
-     "id": "pr_clxx3786u0005ufmj4q8mh2pu",
+     "date": "2024-06-27 10:59:31",
+     "id": "pr_clxx3epds0005upmj10sg9k4k",
      "type": "PayRun",
    },
  ]
    at Object.<anonymous> (/Users/olly/projects/collective-application/libs/bmo/feature-pay/src/lib/interface/partner-on-demand-pay.controller.spec.ts:377:28)
    at processTicksAndRejections (node:internal/process/task_queues:95:5)
]==]

    local expected_output = [==[
[
{
id: "pc_clxx3epdp0004upmjfjj94jr8",
type: "PayCycle",
},
{
date: "2024-06-27 10:59:31",
id: "pr_clxx3epds0005upmj10sg9k4k",
type: "PayRun",
},
]]==]

    local output = process_test_output(input)

    assert.are.same(expected_output, output)
  end)

  it("should return all ideal json properties", function()
    local input = [==[
should return a 400 when there are no eligible members for a pay run: failed
Error: expect(received).toEqual(expected) // deep equality

- Expected  - 1
+ Received  + 5

  Object {
    "body": Object {
-     "code": "BadRequest.Generic",
+     "issues": Array [
+       Object {
+         "code": "BadRequest",
          "message": "No eligible members found, please provide at least one eligible member",
+       },
+     ],
    },
    "status": 400,
  }
    at Object.<anonymous> (/Users/olly/projects/collective-application/libs/bmo/integrations/feature-api/src/lib/interface/onsi-api-pay.controller.spec.ts:651:54)
    at processTicksAndRejections (node:internal/process/task_queues:95:5)
]==]

    local expected_output = [==[
{
body: {
issues: [
{
code: "BadRequest",
message: "No eligible members found, please provide at least one eligible member",
},
],
},
status: 400,
}]==]

    local output = process_test_output(input)

    assert.are.same(expected_output, output)
  end)
end)
