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
end)
