# RTL 修复

用于处理编译错误、`[TB_ERROR]` 或异常 monitor 日志。

## 规则

- 先定位根因，再改代码。
- 区分 RTL 缺陷和 Testbench/断言误报。
- 优先小 diff，不重写无关逻辑。
- 涉及协议、状态机、关键数据通路的大改，先问用户。
- 每次修改后必须回归仿真。

## 流程

### 1. 定位根因

结合 Phase 2 日志切片和源码，确定：

- 文件、模块、逻辑块
- 失败时间点
- 前一拍状态和信号
- 问题类型：编译、复位、延迟不匹配、状态机死锁、数据通路错误、协议违例、TB 误报

简要说明根因。

### 2. 选择修复

RTL 问题：指出要改的状态跳转、复位赋值、使能条件、计数器或数据通路赋值。

TB 问题：指出错误的激励、预期延迟、checker 或 assertion 条件。

### 3. 修改代码

直接修改相关 `.v`、`.sv` 或 Testbench 文件，保留无关代码。

必要时用简短 diff 说明，比如：

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

### 4. 回归

返回仿真阶段，重新运行 `./tb_script/sim.bat`。

停止条件：

- 编译日志无错误
- 无 `[TB_ERROR]`
- 出现 `[TB_INFO] Simulation Finished!`
