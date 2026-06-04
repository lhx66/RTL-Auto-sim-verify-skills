# RTL Refactor

Use for compile errors, `[TB_ERROR]`, or abnormal monitor logs.

## Rules

- Find the root cause before editing.
- Distinguish RTL bugs from testbench/assertion false alarms.
- Prefer small diffs; do not rewrite unrelated logic.
- Ask before major protocol, FSM, or datapath behavior changes.
- Rerun simulation after each edit.

## Workflow

### 1. Locate Root Cause

Use Phase 2 log slices and source code to determine:

- file, module, logic block
- failing timestamp
- previous-cycle state and signals
- issue type: compile, reset, latency mismatch, FSM deadlock, datapath error, protocol violation, or testbench false alarm

State the cause briefly.

### 2. Choose Fix

RTL issue: name the state transition, reset assignment, enable condition, counter, or datapath assignment to change.

TB issue: name the wrong stimulus, expected latency, checker, or assertion condition.

### 3. Edit Code

Edit only the related `.v`, `.sv`, or testbench file.

Use a short diff when helpful:

```verilog
// before
always @(posedge clk) begin
    if (en) count <= count + 1;
end

// after: add reset
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= 0;
    else if (en) count <= count + 1;
end
```

### 4. Regress

Return to simulation and rerun `./tb_script/sim.bat`.

Stop only when:

- compile logs are clean
- no `[TB_ERROR]` remains
- `[TB_INFO] Simulation Finished!` appears
