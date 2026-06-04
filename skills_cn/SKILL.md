---
name: rtl-verify
description: Use when verifying or debugging Verilog/SystemVerilog RTL with ModelSim, generating self-checking testbenches, running simulations, mining logs, or iterating fixes from vlog/vsim errors and [TB_ERROR] logs.
---

# RTL 自动验证

目标：按“需求/代码分析 -> 测试目标确认 -> 生成 Testbench -> ModelSim 仿真 -> 日志诊断 -> 定点修复 -> 回归”的闭环验证 RTL。

以文本日志为主要证据：

- `[TB_MONITOR]`：状态、控制信号、关键时序变化。
- `[TB_DATA]`：有效事务和输出数据。
- `[TB_ERROR]`：断言或检查器失败，触发诊断。
- `[TB_INFO] Simulation Finished!`：仿真正常结束标记。

```text
硬性规则：
确认设计目标前，不规划测试。
确认测试目标前，不生成 Testbench。
无需求文档时，确认设计目标和测试目标后，必须生成维护文档。
```

## 流程

### 1. 对齐设计目标

1. 先搜索工作区中的需求、规格、设计说明、README、spec、requirement、test case、verification 等文档。
2. 阅读 RTL，识别 Top Module、层级、接口、时钟、复位、状态机和关键数据通路。
3. 若存在需求文档，比对 RTL 功能与设计目标，报告一致点、疑点和潜在偏差。
4. 若无需求文档，根据代码推断设计目的，并明确说明这是推断。
5. 停下来让用户确认设计目标；确认前不要规划测试。

### 2. 确认测试目标

1. 若需求文档包含测试用例、验证目标或验收条件，先汇总。
2. 若没有相关描述，根据代码提出建议用例：复位、基础功能、边界输入、连续/突发输入、非法/协议场景、延迟、关键状态跳转。
3. 停下来询问用户是否补充、删减或调整测试用例。
4. 若无需求文档，用户确认设计目标和测试目标后，创建维护文档，记录设计目的、接口假设、关键行为、测试目标、测试用例和用户确认结论。
5. 用户确认测试目标后，才能生成 Testbench。

### 3. 生成 Testbench

Testbench 必须包含：

- 覆盖已确认测试目标的定向激励。
- SVA 或行为级检查。
- `[TB_MONITOR]`、`[TB_DATA]`、`[TB_ERROR]` 日志。
- 结束前打印 `$display("[TB_INFO] Simulation Finished!");`。

### 4. 运行仿真

所有 ModelSim 文件放在 `./tb_script/`：

- `modelsim_filelist.f`
- `modelsim_sim.do`
- `sim.bat`

运行 `./tb_script/sim.bat` 后读取：

- `vlog.log`：编译错误、文件、行号。
- `vsim.log`：`[TB_ERROR]`、`[TB_MONITOR]`、`[TB_DATA]`、结束标记。

### 5. 修复与回归

1. 将失败定位到 RTL 或 Testbench 根因。
2. 简要说明修复策略。
3. 只修改相关 `.v`、`.sv` 或 Testbench 代码。
4. 重新仿真，直到编译无错、无 `[TB_ERROR]`，且出现 `[TB_INFO] Simulation Finished!`。

涉及核心协议、状态机或数据通路的大改时，先问用户确认。

```text
成功条件：
vlog.log 无 Error/Fatal。
vsim.log 无 [TB_ERROR]。
vsim.log 出现 [TB_INFO] Simulation Finished!。
```
