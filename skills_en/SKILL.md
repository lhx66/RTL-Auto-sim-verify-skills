---
name: rtl-verify
description: Use when verifying or debugging Verilog/SystemVerilog RTL with ModelSim, generating self-checking testbenches, running simulations, mining logs, or iterating fixes from vlog/vsim errors and [TB_ERROR] logs.
---

# RTL Verify

Run this loop:

```text
requirements/code review -> test goal confirmation -> testbench -> ModelSim -> log diagnosis -> focused fix -> regression
```

Use text logs as evidence:

- `[TB_MONITOR]`: state, control, and timing changes.
- `[TB_DATA]`: valid transactions and output data.
- `[TB_ERROR]`: assertion/checker failure.
- `[TB_INFO] Simulation Finished!`: clean completion marker.

```text
Hard rules:
Do not plan tests before design intent is confirmed.
Do not generate a testbench before test goals are confirmed.
If no requirements document exists, create a maintenance document after design and test goals are confirmed.
```

## Workflow

### 1. Align Design Intent

1. Search the workspace for requirement/spec/design documents: `requirement`, `spec`, `design`, `README`, `test case`, `verification`, `需求`, `规格`, `设计说明`, `测试用例`, `验证目标`.
2. Read RTL and identify top module, hierarchy, interfaces, clocks, resets, state machines, and data paths.
3. If requirements exist, compare RTL behavior against design goals and report matches, doubts, and likely mismatches.
4. If no requirements exist, infer the design goal from code and label it as an inference.
5. Stop and ask the user to confirm the design goal before planning tests.

### 2. Confirm Test Goals

1. If requirements list test cases, verification goals, or acceptance criteria, summarize them.
2. Otherwise, propose tests for reset, basic function, boundary inputs, bursts/continuous input, invalid/protocol cases, latency, and key state transitions.
3. Stop and ask whether to add, remove, or change tests.
4. If no requirements document exists, create a maintenance document after the user confirms design and test goals. Record design intent, interface assumptions, key behavior, test goals, test cases, and user confirmations.
5. Generate a testbench only after confirmation.

### 3. Generate Testbench

The testbench must include:

- directed stimulus for confirmed tests
- SVA or behavioral checks
- `[TB_MONITOR]`, `[TB_DATA]`, `[TB_ERROR]` logs
- final `$display("[TB_INFO] Simulation Finished!");`

### 4. Run Simulation

Put all ModelSim files under `./tb_script/`:

- `modelsim_filelist.f`
- `modelsim_sim.do`
- `sim.bat`

Run `./tb_script/sim.bat`, then read:

- `vlog.log`: compile errors, files, lines
- `vsim.log`: `[TB_ERROR]`, `[TB_MONITOR]`, `[TB_DATA]`, completion marker

### 5. Fix and Regress

1. Trace the failure to RTL or testbench root cause.
2. Explain the fix briefly.
3. Edit only related `.v`, `.sv`, or testbench code.
4. Rerun until compile logs are clean, no `[TB_ERROR]` remains, and `[TB_INFO] Simulation Finished!` appears.

Ask before major protocol, FSM, or datapath behavior changes.

```text
Success criteria:
vlog.log has no Error/Fatal.
vsim.log has no [TB_ERROR].
vsim.log contains [TB_INFO] Simulation Finished!.
```
