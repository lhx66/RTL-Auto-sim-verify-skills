# RTL Analyzer

Use before writing a testbench.

```text
Exit criteria:
Design intent is confirmed by the user.
Test goals are confirmed by the user.
If no requirements document exists, a maintenance document has been created.
```

## Steps

### 1. Search Requirements

Search workspace documents for:

`requirement`, `spec`, `design`, `README`, `test case`, `verification`, `需求`, `规格`, `设计说明`, `测试用例`, `验证目标`.

If found, read only relevant parts:

- design goals
- interface behavior
- timing or latency constraints
- boundary conditions
- test cases or verification goals

### 2. Analyze RTL

Read `.v` and `.sv` files. Report:

- top module candidate
- submodule hierarchy
- clocks and resets
- key inputs and outputs
- FSMs, counters, handshakes, and data paths

If requirements exist, compare RTL against them:

- matching behavior
- unclear assumptions
- likely mismatches
- questions for the user

If no requirements exist, infer the design goal from RTL and label it as an inference.

### 3. Confirm Design Intent

Stop and ask the user to confirm hierarchy, design goal, and key monitored signals. Do not plan tests before confirmation.

### 4. Confirm Test Cases

After design intent is confirmed:

- If requirements contain test cases, summarize them by category.
- Otherwise propose tests for reset, basic function, boundary inputs, bursts/continuous input, invalid/protocol cases, latency, and key state transitions.

Stop and ask whether to add, remove, or change tests.

### 5. Create Maintenance Document

Run only when no requirements document exists. After the user confirms design intent and test cases, create:

```text
./rtl_verify_requirements.md
```

Record at least:

- design intent
- top module and interface assumptions
- key timing/protocol behavior
- confirmed test goals
- test case list
- open questions or future additions

### 6. Plan Testbench

After test goals are confirmed, choose:

1. generate a new self-checking testbench, or
2. inject monitors and assertions into an existing testbench.

Use structured logs:

```verilog
$display("[TB_MONITOR] Time: %0t | State Changed: %0d -> %0d", $time, old_state, new_state);
$display("[TB_DATA] Time: %0t | Data = 0x%h", $time, data_out);
$error("[TB_ERROR] Time: %0t | reason", $time);
$display("[TB_INFO] Simulation Finished!");
```

Use SVA or behavioral checks for protocol and data correctness.
