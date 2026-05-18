### RTL-Auto-sim-verify-skills

> **基于日志驱动验证 (Log-Driven Verification) 范式的全自动 RTL 验证与自动修复智能体技能库**

本工程是一套专门为具备终端执行与文件读写能力的 AI Agent（如 **Claude Code**, **Codex**, **Cursor** 等）量身打造的数字 IC 自动验证方案，旨在将 AI 强大的文本逻辑推理能力与 Testbench 动态日志相结合，构筑起一个**【代码分析 -> 智能断言 TB 构建 -> 静默仿真运行 -> 日志自检挖掘 -> 外科手术式代码修复 -> 回归测试】**的无限自驱动闭环代码功能修复。
本工程的目的在于解放双手，由agent在后台静默完成代码功能的修复与验证。修复代码的能力取决于接入的大模型能力。在进行代码多次迭代修改前，**请务必确认好AI总结的代码实现意图是否正确**。

⚠️ **重要说明**：当前版本**暂时仅支持 ModelSim 仿真器**（要求系统环境变量中已配置好 `vsim` 命令行工具）。

---

## 🏗️ 项目架构 (Project Architecture)

项目采用**多智能体协作 / 多阶段流水线**的分层架构，核心功能由放置在 `skills/` 文件夹下的 Markdown 技能文档（System Prompt）进行定义与约束。项目架构如下：
├── README.md                     # 本说明文档
├── install_skills.sh             # 一键远端/本地环境部署脚本
└── skills/
    ├── Master_Skill_RTL_Copilot.md     # 中央大脑：统筹全局验证闭环与身份切换
    ├── Skill_1_RTL_Analyzer.md         # Phase 1：架构分析、意图对齐与强自检型 TB 自动插桩构建
    ├── Skill_2_Simulation_Controller.md# Phase 2：仿真环境搭建、增量脚本管理、后台静默运行与日志精读
    └── Skill_3_RTL_Refactor.md         # Phase 3：缺陷精准溯源、代码/TB 外科手术式覆写、回归测试触发


### 1. 中央统筹大脑 (`Master_Skill_RTL_Copilot.md`)

作为整个验证闭环的控制核心。它负责在不同阶段动态切换 AI 的角色，监控整个闭环是否收敛。只有当仿真日志中明确打印出 `[TB_INFO] Simulation Finished!` 且全程未触发任何 `Error` 时，才会判定验证成功并结束验证流程。

### 2. 源码分析与强自检 TB 构筑 (`Skill_1_RTL_Analyzer.md`)

* **层级倒推**：自动分析用户上传的一批 `.v` 或 `.sv` 文件，通过例化关系倒推模块依赖树，精准定位 Top Module。
* **意图硬死磕**：引入**强制交互迭代机制**，推断设计意图并强制用户确认，直到理解完全一致后才放行。
* **自检插桩**：抛弃传统 VCD 导出，强制在生成的 Testbench 中注入带有 `[TB_MONITOR]`、`[TB_DATA]`、`[TB_ERROR]` 统一标签的定向测试用例（SVA 断言及高密度文本打印），让 Testbench 自己长上“嘴巴”汇报时序。

### 3. 环境统筹与日志自动挖掘 (`Skill_2_Simulation_Controller.md`)

* **路径溯源与幂等性**：强制将仿真环境规范化收拢在工程根目录的 `./tb_script/` 文件夹下。在 `.f` 文件中自动回溯正确的相对路径，且绝不重复生成带后缀的垃圾脚本文件。
* **静默后台运行**：在 `.do` 和 `.bat` 脚本中强挂 `-c` 等静默参数，完全在命令行模式下运行仿真，绝不弹窗打扰用户前台浏览。
* **日志全自动提取**：全自动精读 `vlog.log` 和 `vsim.log`，提取报错时间点与状态转移切片，拒绝把长篇日志抛给人类肉眼看。

### 4. 代码重构与修复流程 (`Skill_3_RTL_Refactor.md`)

* **先定因，再开刀**：根据日志时间戳向前追溯一拍或几拍，定位是 RTL 逻辑缺陷、状态机死锁还是 TB 误报。
* **外科手术式修复**：利用 Agent 的文件覆写能力，精准局部替换缺陷代码（Diff），不破坏其余完好逻辑。随后**自动重新触发 `./tb_script/sim.bat**` 开启新一轮验证。

---

## 🚀 安装方法 (Installation)

我们在项目根目录下提供了一个全自动的远程部署脚本 `install_skills.sh`。它可以直接在你的任意数字 IC 开发工程中一键运行，自动从本 Git 仓库拉取最新技能，并分发部署到你常用的 AI 工具配置中。

### 1. 自动远程下载并安装

在你的 RTL 开发工程根目录下，打开终端执行以下命令：

```bash
# 下载远程安装脚本
curl -fsSL https://raw.githubusercontent.com/lhx66/RTL-Auto-sim-verify-skills/main/install_skills.sh | sh
```

### 2. 脚本自动适配的环境

脚本在运行时会全自动为你初始化以下 AI 环境的技能池：

* **Claude Code**：自动分发至 `.claude-plugin/rtl-copilot/` 目录并生成标准插件元数据 `marketplace.json`。
* **Cursor Rules**：自动分发至 `.cursor/rules/` 目录，Cursor 引擎会自动将其作为最高优先级的本地行为守则。
* **Codex System**：自动分发至 `.codex/skills/` 目录并生成对应的技能组描述文件 `codex_config.json`。

---

## 📖 使用说明 (Usage Instructions)

环境部署完成后，你可以通过以下极其简单的四步体验全自动硬件设计验证闭轮：

### 第一步：启动 AI Agent

在工程根目录下唤醒你支持本地操作的 AI 工具，例如启动 Claude Code：

```bash
claude
```

### 第二步：唤醒验证统筹引擎

直接在对话框中发出一句明确的激活指令，并将你的 `.v` 源码文件提供给它：

> **指令**：**使用/rtl-verify来启动本skill**
> **提示词示例**：“我上传了 core.v 和 sub_module.v 文件，请启动 `RTL Verification Orchestrator` 对其进行全自动仿真验证。”

### 第三步：配合 AI 进行意图对齐 (关键)

AI 会首先解析出顶层模块与子模块树。随后，它会停留并强制向你提问。

* 请在这里准确回复它的问题。例如告诉它：“*正确，这是一个带流水线的16位乘加器，我最关心在输入有效数据突发（valid连续拉高）时，输出在 3 拍后是否能准确打出数据，且不发生溢出截断。*”
* 当你回复“*确认，完全正确*”后，验证引擎的闸门将正式开启。

### 第四步：进入无人值守的验证修复流程

此时，你可以双手离开键盘。AI 将自动执行以下全自动化链条：

1. 为你生成内嵌定向边界激励与 SystemVerilog 断言（SVA）的高自检性 Testbench。
2. 自动在 `./tb_script/` 目录下生成 ModelSim 命令行运行脚本。
3. 在后台静默跑起 `vsim` 仿真，并在完毕后自动精读日志。
4. 如果断言在 150ns 时报错 `[TB_ERROR]`，它会提取该时刻的状态转换日志，并自动修改源码中对应 always 块的控制条件。
5. 修改完成后，它会再次自动在后台跑仿真，直到没有任何 Error，完美打印出 `[TB_INFO] Simulation Finished!`。

验证彻底收敛后，AI 会向你提交最终的战报以及一份被“精准修复”好的、完好无损的 RTL 源码文件。


## 待开发

1. 自动备份重要版本
2. 基于仿真波形文件等的共同结果分析