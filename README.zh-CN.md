# AI Native 开发基础设施 — *alignment-first（对齐优先）*

[English](README.md) | **简体中文**

> 一套**工具中立**的脚手架，让 **Claude Code**、**GitHub Copilot**、**Codex** 在改动**已有的** Java / Spring Boot / MyBatis 代码库时，**不偏离这个代码库的真实约定**。
>
> 核心思路：先让 AI 和已有项目**对齐**，再让 `copilot-instructions.md` 之类的规则生效——避免"规则是模板的假设、代码是项目的事实"导致 AI 跑偏。

<p align="left">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
  <img alt="Tools" src="https://img.shields.io/badge/agents-Claude%20Code%20%7C%20Copilot%20%7C%20Codex-6f42c1">
  <img alt="Stack" src="https://img.shields.io/badge/target-Spring%20Boot%20%2B%20MyBatis-6db33f">
</p>

---

## 要解决的问题

通用的 AI 指令文件（`CLAUDE.md`、`AGENTS.md`、`.github/copilot-instructions.md`）写的是**假设**——"用 Service 层"、"REST controller"、"驼峰实体"。而真实的存量项目里是**事实**——可能用 `BLogic`、XML mapper、画面名路由、遗留基类。两者没对齐就把通用规则打开，AI 的每次改动都在和代码库打架。

**本仓库的答案：** AI 指令文件不手写、默认也不生效。它们由一条简短的对齐流水线，从你项目的*实测事实*中**构建**出来，然后才被激活。

## 核心思想：`source → align → build`

```
universal/   （跨项目复用，不随项目改）      ─┐
project/     （本项目的对齐事实）            ─┼─ promote.sh ─▶  生效入口文件（构建产物）
_staging/    （等待人工 review 的草稿）      ─┘                  ./CLAUDE.md  ./AGENTS.md
                                                                 .github/copilot-instructions.md
                                                                 .github/instructions/*.instructions.md
```

- **暂存区 = `ai-infra/` 子目录。** 工具**不读**它。模板可以放进你的项目而不影响任何东西。
- **生效区 = 项目根 `CLAUDE.md`/`AGENTS.md` + `.github/`。** 工具读这里。**只有 `promote.sh` 往这里写**，且对齐没完成（`ALIGN_STATE: aligned`）时它**拒绝运行**。
- 入口文件是**产物**，不是源码。改规则 → 改 `universal/` 或 `project/` → 重跑 `promote.sh`。（因为 Copilot 不支持 `import`，从单一源装配才能让三个工具保持一致、不靠复制粘贴。）

## 快速开始

```bash
# 1. 把模板作为惰性子目录放进已有项目
cp -r ai-native-infra  /path/to/your-project/ai-infra

# 2. 用三个 agent 中任意一个跑完 5 步对齐流水线
/align-survey     # 读真实代码 → project/PROJECT-FACTS.md（每条事实带 file:line 证据）
/align-extract    # 从真实代码摘取黄金样例 → project/examples/
/align-draft      # 特化通用规则模板 → _staging/ 草稿
/align-review     # 标注 confirmed / assumed；你只需要审 "assumed" 项
/align-activate   # promote.sh 装配并启用生效入口文件

# 面向 agent 的门禁：开工跑 state，收尾跑 verify（对齐的 build/test）
bash ai-infra/tools/aci.sh state
bash ai-infra/tools/aci.sh verify

# Windows（无需 Git Bash）：每个脚本都有 PowerShell 5.1 兼容的对应版
#   powershell -NoProfile -ExecutionPolicy Bypass -File ai-infra/tools/aci.ps1 state
#   powershell -NoProfile -ExecutionPolicy Bypass -File ai-infra/activate/promote.ps1

# 模板维护者可跑部署模式冒烟测试
bash tools/smoke-aci.sh
pwsh -NoProfile -File tools/smoke-aci.ps1
```

激活之前，你项目里已有的 `.github/copilot-instructions.md`（如果有）不会被碰；`promote.sh` 写入前会先**备份**。

## 三个 agent 怎么接入（对齐之后）

| Agent | 读什么 | `promote.sh` 装配出什么 |
|---|---|---|
| **Claude Code** | 根 `CLAUDE.md` | 核心契约 + 指向 `ai-infra/universal/prompts` 工作流 + Claude 专属注意点（subagent、验证纪律） |
| **Codex** | 根 `AGENTS.md` | 同一份核心契约作为"宪法" + 命令 + 安全约定 |
| **GitHub Copilot** | `.github/copilot-instructions.md`（薄版）+ `.github/instructions/*.instructions.md`（按路径注入）+ `.github/prompts/` | 精简契约 + 各层规则 + 工作流 prompt 文件，并在 `.vscode/settings.json` 打开 `useInstructionFiles` |

三个工具共享**同一份**核心契约（`project/aligned-rules.md`）——装配而来，绝不手抄。

## 支持什么

- **Agent-Computer Interface（ACI）** — 受 SWE-agent 启发的**领域门禁**，是 agent 的 harness 原生给不了的：对齐状态、一键项目验证（`aci.sh verify` → `project/verify.sh`）、文档治理校验、traceability 爆炸半径搜索、证据核查。仓库观察仍用 agent 的原生工具；`find/grep/view` 只作为 shell-only 环境的有界 fallback 保留。见 `universal/aci/`。
- **DEF ベース开发** — 机器可读的*结构*契约（DB / 画面 / API / code / message 定义书正规化为 YAML），确定性地派生 entity、mapper、form、校验和边界测试。见 `universal/defs-model/`。
- **式様書（spec）驱动开发** — 人类可读的*行为*契约，驱动路由、业务流程、画面遷移和行为测试。
- **Traceability** — 稳定的 `{TARGET}-{TYPE}-{NUMBER}` ID 把 DEF/spec → 测试 case → 可执行测试 → fixture 串起来，agent 能算出任意改动的爆炸半径。
- **工作流** — `aci-task-loop`、`spec-to-code`、`spec-to-testcases`、`testcases-to-data`、`testcases-to-junit`、`code-review`（在 `universal/prompts/workflow/`）。

## 防跑偏护栏

- **证据强制** — `PROJECT-FACTS.md` 里每条架构/命名断言必须引用真实 `path:line`；`tools/validate-ai-docs.sh` 校验这些路径存在。
- **置信标签** — 每条规则要么 `[confirmed]`（有代码证据）要么 `[assumed]`（模板默认、需人签字）；agent 依赖 `assumed` 规则时必须标注。
- **优先级** — *实测项目事实 > 通用模板默认*，显式写明。
- **激活闸门** — `promote.sh` 在 `ALIGN_STATE: aligned` 之前拒绝运行，拒绝对非 Java 目录运行，且写入前总是先备份已有配置。
- **机器验证** — `tools/aci.sh verify` 跑对齐时固化的 build/test 命令（`project/verify.sh`），输出有界、结果是明确的 ✓/✗——"能编译"由机器说了算，不靠 agent 的口头描述。

## 目录布局

```
ai-native-infra/
├── universal/            # 跨项目复用，免对齐
│   ├── prompts/align/     #   ★ 5 步对齐流水线
│   ├── prompts/workflow/  #   spec→code / →testcases / →data / →junit / code-review
│   ├── aci/               #   Agent-Computer Interface 指引
│   ├── rules-templates/   #   带 {{占位符}} 的规则模板
│   ├── testing/  defs-model/  maps/traceability.md
├── project/              # ★ 每个项目自己的对齐产物（初始为占位符）
│   ├── PROJECT-FACTS.md  aligned-rules.md  ALIGN-STATUS.md
│   ├── instructions/  examples/
├── _staging/             # review 中转区
├── activate/             # 入口文件外壳（*.tpl）+ promote.sh + settings 片段
└── tools/validate-ai-docs.sh  aci.sh  smoke-aci.sh   （+ 各自的 .ps1 Windows 对应版）
```

**Windows：** `aci.ps1` / `validate-ai-docs.ps1` / `promote.ps1` 与 shell 脚本一一对应，直接跑在 Windows 自带的 PowerShell 5.1 上。promote 会把入口文件模板里的 `{{ACI}}` 占位符展开为当前 OS 的可运行调用形式（macOS/Linux 得到 `bash .../aci.sh`，Windows 得到 `powershell -File .../aci.ps1`）——换 OS 后重跑对应的 promote 即可。每个项目的验证入口同样成对：`project/verify.sh` / `project/verify.ps1`。

## 新项目 vs 已有项目

每个项目有**自己的** `project/`（自己的事实）。新项目 = 再复制一次模板、重跑流水线。除 `universal/` 外互不共享，对齐结果不会互相污染。

## 语言

规则/式样书内容用**中文/日文**编写（目标用户是做 DEF ベース / 式様書开发的日企 SIer 团队）。英文 README 只为可发现性；机制本身与语言无关。

## 研究说明

ACI 层参考了 [SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering](https://arxiv.org/abs/2405.15793)——但是**选择性采用**。论文的 *observation* 教训（有界文件查看、精简搜索）已经内置在 2026 年主流 agent harness（Claude Code / Codex / Copilot）的原生工具里，所以本仓库**不**要求 agent 把观察绕道到包装脚本——那是反优化。本仓库采用的是另一半教训：面向 agent 的接口应该提供一小组确定性的、领域特定的动作，带明确反馈和对非法状态的护栏——落在这里就是对齐闸门、traceability/证据核查和一键验证，用于存量项目对齐与企业级 Java 工作流，而不是移植 SWE-agent 本身。

## License

[MIT](LICENSE)。
