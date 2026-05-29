---
name: rtl-verification-copilot
description: Use when verifying or debugging Verilog/SystemVerilog RTL with ModelSim, generating self-checking testbenches, running simulations, mining logs, or iterating fixes from vlog/vsim errors and [TB_ERROR] logs.
---

# RTL Verification Copilot

Use this skill to run a log-driven RTL verification and repair loop for Verilog or SystemVerilog projects with ModelSim.

## Required Workflow

1. Read `Master_Skill_RTL_Copilot.md` first and follow it as the orchestration entry point.
2. Use `Skill_1_RTL_Analyzer.md` when analyzing RTL structure, identifying the top module, confirming design intent with the user, and generating or improving a self-checking testbench.
3. Use `Skill_2_Simulation_Controller.md` when creating or updating ModelSim scripts, running `vsim`, and extracting `vlog.log` or `vsim.log` diagnostics.
4. Use `Skill_3_RTL_Refactor.md` when tracing `[TB_ERROR]`, compile errors, assertion failures, or monitor anomalies back to RTL or testbench fixes.

## Operating Rules

- Confirm the intended RTL behavior with the user before generating assertions or making behavior-changing fixes.
- Keep all generated simulation files under `./tb_script/`.
- Prefer text-log evidence from `[TB_MONITOR]`, `[TB_DATA]`, `[TB_ERROR]`, `vlog.log`, and `vsim.log` over waveform-only reasoning.
- Treat `[TB_INFO] Simulation Finished!` with no errors as the success condition for the verification loop.
- Make focused RTL or testbench edits and rerun the simulation loop until the result is clean or user input is required.

## Resource Files

- `Master_Skill_RTL_Copilot.md`: overall orchestration and phase switching.
- `Skill_1_RTL_Analyzer.md`: RTL analysis and self-checking testbench generation.
- `Skill_2_Simulation_Controller.md`: ModelSim environment generation and log analysis.
- `Skill_3_RTL_Refactor.md`: root-cause tracing, code repair, and regression.
