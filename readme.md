# RTL-Auto-sim-verify-skills

## Quick Navigation

- [English](#english)
- [中文](#中文)

---

## English

> **An autonomous RTL verification and auto-repair skill based on log-driven verification.**

This skill is designed for AI agents with terminal execution and file editing capabilities, such as **Claude Code**, **Codex**, and **Cursor**. It combines the agent's reasoning ability with dynamic testbench logs to build a self-driven RTL verification loop:

```text
code analysis -> assertion-aware testbench generation -> silent simulation -> log mining -> focused code repair -> regression
```

Workflow characteristics:

1. Help engineers reduce manual effort during RTL module or project verification by letting the agent run verification and repair loops in the background.
2. Repair quality depends on the model and tool environment connected to the agent.
3. Before allowing multiple automated code-repair iterations, carefully confirm that the agent's inferred design intent is correct.

**Important:** The current version only supports the **ModelSim** simulator. The `vsim` command-line tool must be available in the system environment.

## Project Architecture

The project keeps two source variants. During installation, the selected variant is copied into the unified `skills/` directory.

```text
README.md
install_skills.sh
skills/                            # Generated during installation; active skill entry
skills_cn/                         # Chinese skill variant
  SKILL.md
  Skill_1_RTL_Analyzer.md
  Skill_2_Simulation_Controller.md
  Skill_3_RTL_Refactor.md
  agents/openai.yaml
skills_en/                         # English skill variant
  SKILL.md
  Skill_1_RTL_Analyzer.md
  Skill_2_Simulation_Controller.md
  Skill_3_RTL_Refactor.md
  agents/openai.yaml
```

### 1. Main Orchestrator (`SKILL.md`)

Controls the full verification loop and switches between phases. The loop succeeds only when the simulation log prints `[TB_INFO] Simulation Finished!` and the full run contains no `Error`.

### 2. RTL Analysis and Self-Checking Testbench Generation (`Skill_1_RTL_Analyzer.md`)

- **Hierarchy inference:** Analyze `.v` and `.sv` files, infer the module dependency tree, and identify the top module.
- **Intent alignment:** Require the user to confirm the inferred design intent before generating assertions or test scenarios.
- **Self-checking instrumentation:** Generate testbench logic with `[TB_MONITOR]`, `[TB_DATA]`, and `[TB_ERROR]` labels, SVA assertions, and dense text logs.

### 3. Simulation Control and Log Mining (`Skill_2_Simulation_Controller.md`)

- **Path discipline and idempotence:** Keep simulation scripts under `./tb_script/` and use correct relative paths in filelists.
- **Silent background execution:** Run ModelSim in command-line mode with scripts such as `.do` and `.bat`.
- **Automated log extraction:** Read `vlog.log` and `vsim.log`, extract failing timestamps, state transitions, and assertion context.

### 4. RTL Refactor and Repair (`Skill_3_RTL_Refactor.md`)

- **Root cause before edits:** Trace one or more cycles back from the failing log timestamp to decide whether the issue is an RTL bug, FSM deadlock, or testbench false alarm.
- **Focused repair:** Apply small, local diffs without damaging unrelated logic, then rerun `./tb_script/sim.bat` for regression.

## Installation

Run the installer from any terminal. On Windows, Git Bash is recommended.

```bash
curl -fsSL https://raw.githubusercontent.com/lhx66/RTL-Auto-sim-verify-skills/main/install_skills.sh | sh
```

The installer asks which language variant to install. Chinese is the default. The selected variant is copied into `skills/` and distributed to detected AI environments.

The installer distributes the skill to detected AI environments:

- **Claude Code:** `.claude/skills/rtl-verify/`
- **Cursor Rules:** `.cursor/rules/rtl-verify/`
- **Codex:** `.codex/skills/rtl-verify/`
- **Gemini CLI / Goose:** installed when their standard config directories are detected

## Usage

1. Provide existing RTL code, or use another skill to generate RTL code.
2. Open an AI agent with local file and terminal access from the RTL project root, for example:

```bash
claude
```

3. Ask the agent to use `/rtl-verify` or invoke the skill by name.
4. Confirm the detected top module, hierarchy, design intent, and critical signals.
5. Let the agent generate a self-checking testbench, run ModelSim, analyze logs, repair focused issues, and rerun regression until the loop converges.

## Roadmap

1. Important-version reporting.
2. Analysis based on VCD or other waveform files.
3. The installer has currently been verified with Codex and Claude Code; other tools still need validation.

## Contact

```email
1501566255@qq.com
```

---

## 中文

> **基于日志驱动验证 (Log-Driven Verification) 的全自动 RTL 验证与自动修复 SKILL。**

本 skill 是一套专门为具备终端执行与文件读写能力的 AI Agent（如 **Claude Code**, **Codex**, **Cursor** 等）打造的数字 IC 自动验证方案。它将 AI 的文本逻辑推理能力与 Testbench 动态日志相结合，构筑起一个自驱动闭环：

```text
代码分析 -> 智能断言 TB 构建 -> 静默仿真运行 -> 日志自检挖掘 -> 外科手术式代码修复 -> 回归测试
```

本 skill 的工作流特征如下：

1. 在 RTL 项目或模块功能验证中帮助工程师减少手动工作，由 agent 在后台完成代码功能修复与验证。
2. 当前修复代码的能力取决于接入的大模型能力。
3. 在进行多次自动迭代修改前，**请务必确认 AI 总结的代码实现意图是否正确**。

**重要说明**：当前版本**暂时仅支持 ModelSim 仿真器**，要求系统环境变量中已配置好 `vsim` 命令行工具。

## 项目架构

项目保留两个源版本。安装时，脚本会把用户选择的版本复制到统一的 `skills/` 目录。

```text
README.md
install_skills.sh
skills/                            # 安装时生成，作为实际 skill 入口
skills_cn/                         # 中文 skill
  SKILL.md
  Skill_1_RTL_Analyzer.md
  Skill_2_Simulation_Controller.md
  Skill_3_RTL_Refactor.md
  agents/openai.yaml
skills_en/                         # 英文 skill
  SKILL.md
  Skill_1_RTL_Analyzer.md
  Skill_2_Simulation_Controller.md
  Skill_3_RTL_Refactor.md
  agents/openai.yaml
```

### 1. 中央统筹大脑 (`SKILL.md`)

作为整个验证闭环的控制核心。它负责在不同阶段动态切换 AI 的角色，监控整个闭环是否收敛。只有当仿真日志中明确打印 `[TB_INFO] Simulation Finished!` 且全程未触发任何 `Error` 时，才判定验证成功。

### 2. 源码分析与强自检 TB 构筑 (`Skill_1_RTL_Analyzer.md`)

- **层级倒推**：自动分析 `.v` 或 `.sv` 文件，通过例化关系倒推模块依赖树，定位 Top Module。
- **意图确认**：引入强制交互机制，推断设计意图并要求用户确认，直到理解完全一致后再进入下一步。
- **自检插桩**：在 Testbench 中注入 `[TB_MONITOR]`、`[TB_DATA]`、`[TB_ERROR]` 标签、SVA 断言和高密度文本打印。

### 3. 环境统筹与日志自动挖掘 (`Skill_2_Simulation_Controller.md`)

- **路径溯源与幂等性**：强制将仿真环境收拢到工程根目录的 `./tb_script/` 文件夹下，并在 `.f` 文件中使用正确相对路径。
- **静默后台运行**：通过 `.do` 和 `.bat` 脚本在命令行模式下运行 ModelSim。
- **日志自动提取**：自动精读 `vlog.log` 和 `vsim.log`，提取报错时间点、状态转移切片和断言上下文。

### 4. 代码重构与修复流程 (`Skill_3_RTL_Refactor.md`)

- **先定因，再开刀**：根据日志时间戳向前追溯一拍或几拍，定位是 RTL 逻辑缺陷、状态机死锁还是 TB 误报。
- **外科手术式修复**：利用 Agent 的文件编辑能力，精准局部替换缺陷代码，不破坏其余逻辑。随后自动重新触发 `./tb_script/sim.bat` 开启新一轮验证。

## 安装方法

在终端中执行以下命令。Windows 环境建议使用 Git Bash。

```bash
curl -fsSL https://raw.githubusercontent.com/lhx66/RTL-Auto-sim-verify-skills/main/install_skills.sh | sh
```

安装脚本会询问安装中文还是英文版本，默认中文。选中的版本会被复制到 `skills/`，再分发到检测到的 AI 环境。

安装脚本会自动分发到检测到的 AI 环境：

- **Claude Code**：`.claude/skills/rtl-verify/`
- **Cursor Rules**：`.cursor/rules/rtl-verify/`
- **Codex**：`.codex/skills/rtl-verify/`
- **Gemini CLI / Goose**：检测到对应标准配置目录时自动安装

## 使用说明

1. 用户提供已有 RTL 代码，或配合其它 skill 生成代码。
2. 在 RTL 工程根目录下启动具备本地文件和终端权限的 AI 工具，例如：

```bash
claude
```

3. 使用 `/rtl-verify` 或直接要求 agent 使用本 skill。
4. 配合 AI 确认顶层模块、模块层级、设计意图和关键监控信号。
5. 让 agent 自动生成自检 Testbench、运行 ModelSim、分析日志、精准修复问题并重复回归，直到验证闭环收敛。

## 待开发

1. 重要版本汇报。
2. 基于 VCD 等仿真波形文件的结果分析。
3. 目前仅验证了 Codex 与 Claude Code 的安装，其它工具待验证。

## 联系方式

```email
1501566255@qq.com
```
