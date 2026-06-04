# 仿真控制

用于创建 ModelSim 环境、运行仿真、提取日志证据。

## 规则

- 所有仿真文件放在 `./tb_script/`。
- `modelsim_filelist.f` 使用相对 `./tb_script/` 的路径。
- 使用命令行模式运行 ModelSim。
- 自行读取日志，不让用户手动看长日志。

## 必要文件

### `./tb_script/modelsim_filelist.f`

列出 RTL 和 Testbench 文件，路径必须正确。

### `./tb_script/modelsim_sim.do`

使用模板，只改模块名和路径：

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

若 `-nowlf` 不支持，删除该参数。

### `./tb_script/sim.bat`

```bat
@echo off
echo [AI Copilot] Starting simulation...
vsim -c -do modelsim_sim.do
echo [AI Copilot] Simulation finished.
exit /b
```

## 日志分析

在 `tb_script` 下运行 `sim.bat`，然后检查：

1. `./tb_script/log/vlog.log`
   - 提取 `Error`、`Fatal`。
   - 给出文件、行号、可能原因。
2. `./tb_script/log/vsim.log`
   - 提取 `[TB_ERROR]` 时间点和原因。
   - 提取失败前相关 `[TB_MONITOR]`、`[TB_DATA]`。
   - 检查 `[TB_INFO] Simulation Finished!`。

若仍有错误，将最小日志切片交给修复阶段。
