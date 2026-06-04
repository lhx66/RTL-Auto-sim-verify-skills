# Simulation Controller

Use to create the ModelSim environment, run simulation, and extract log evidence.

## Rules

- Put all simulation files under `./tb_script/`.
- Use paths relative to `./tb_script/` in `modelsim_filelist.f`.
- Run ModelSim in command-line mode.
- Read logs directly; do not ask the user to inspect long logs.

## Required Files

### `./tb_script/modelsim_filelist.f`

List RTL and testbench files with correct relative paths.

### `./tb_script/modelsim_sim.do`

Use this template; change only names and paths:

```tcl
set tbname [replace_with_testbench_top]

proc all {} {
    global tbname
    sim
    run -all
    set wlf_files [glob -nocomplain -- "wlf*"]
    foreach f $wlf_files { file delete -force $f }
    quit -sim
    quit -f
}

proc sim {} {
    global tbname
    if {![file isdirectory work]} { vlib work }
    if {![file isdirectory log]} { file mkdir log }
    vmap work work

    vlog -sv -incr -v work -override_timescale 1ns/10ps -f modelsim_filelist.f -l ./log/vlog.log
    vopt +acc +nospecify work.${tbname} -o voptsim -l ./log/vopt.log
    vsim -c -nowlf +nospecify voptsim -l ./log/vsim.log
}

all
```

Remove `-nowlf` if unsupported.

### `./tb_script/sim.bat`

```bat
@echo off
echo [AI Copilot] Starting simulation...
vsim -c -do modelsim_sim.do
echo [AI Copilot] Simulation finished.
exit /b
```

## Log Analysis

Run `sim.bat` in `tb_script`, then inspect:

1. `./tb_script/log/vlog.log`
   - Extract `Error` and `Fatal`.
   - Include file, line, and likely cause.
2. `./tb_script/log/vsim.log`
   - Extract `[TB_ERROR]` timestamps and reasons.
   - Extract relevant `[TB_MONITOR]` and `[TB_DATA]` before failure.
   - Check for `[TB_INFO] Simulation Finished!`.

If errors remain, pass the smallest useful log slice to the repair phase.
