---
description: "按 ACI 循环执行一次仓库级任务：状态→定位→编辑→验证→复盘。适合 Claude Code/Codex 接到较大改动时使用。"
mode: agent
tools: ['codebase', 'search', 'read', 'editFiles', 'runCommands']
slash: aci-task-loop
---

# /aci-task-loop

你是接手既有项目的 coding agent。目标不是“尽快写代码”，而是用可观察、可恢复、可验证的循环完成任务。

## 前置

先运行：

```bash
bash ai-infra/tools/aci.sh state
```

（Windows 环境把本文所有 `bash ai-infra/tools/aci.sh` 替换为 `ai-infra\tools\aci.cmd`；
执行策略报错的排障见 `ai-infra/universal/aci/README.md`。）

确认：

- `ALIGN_STATE` 是否为 `aligned`。未对齐时，除非用户明确要求修基础设施本身，否则先执行对齐流水线。
- 当前 git status。不得覆盖用户已有改动。
- 根 `CLAUDE.md` / `AGENTS.md` / `.github/copilot-instructions.md` 是否已生效。

## 循环

1. **定位**
   - 优先用你的**原生**搜索/读取工具（如 Claude Code 的 Grep/Glob/Read）——它们已经是有界、带行号的。
   - 没有原生搜索能力的环境，才用 `bash ai-infra/tools/aci.sh find/grep/view`（输出受控的 fallback）。
   - 涉及 spec/DEF 变更时，先 `bash ai-infra/tools/aci.sh trace <ID>` 算出爆炸半径。
   - 输出太多时收窄查询，不要把大段无关上下文灌进推理。

2. **计划**
   - 写出 2-5 步短计划。
   - 标出会改哪些文件、为什么这些文件是任务所需。
   - 发现 `[assumed]` 规则、冲突或缺少证据时，明确登记。

3. **编辑**
   - 使用 agent 原生编辑工具。
   - 不用脚本批量重写未知代码。
   - 不做与任务无关的格式化、重命名、现代化。

4. **自审**
   - 运行 `bash ai-infra/tools/aci.sh diff`。
   - 对照 `ai-infra/project/aligned-rules.md`、`project/instructions/`、`project/examples/`。
   - 检查 traceability ID 是否贯通到 spec/test/data。

5. **验证**
   - 运行 `bash ai-infra/tools/aci.sh verify`（一键跑对齐时固化的 build/test，见 `project/verify.sh`）。
   - 缺 `project/verify.sh` 时按 aligned-rules 命令段手跑，并提示用户补齐 verify.sh。
   - 运行 `bash ai-infra/tools/aci.sh validate`；涉及画面/接口的改动按对齐规则补端到端验证。
   - 如果验证失败，基于错误最小修复；不要顺手改无关区域。

6. **报告**
   - 说明改了什么、证据在哪里、跑了哪些命令、结果如何。
   - 未验证项和风险要如实列出。

## 停止条件

遇到以下情况必须停下请求人类确认：

- 需要删除用户数据或业务数据。
- 需要提交到外部系统、发消息、上传文件、改账号权限或处理凭证。
- 对齐事实与用户要求冲突，且继续会改架构/接口/数据模型。
- 需要把 `[assumed]` 规则当作硬事实推广到 live 入口。

## 设计依据

本流程采用 SWE-agent 的 ACI 思路，但按 2026 年现实切分：受控观察窗口已由主流 harness 原生工具内置（所以定位优先原生工具）；本流程把论文教训用在 harness 给不了的地方——领域门禁（state/trace/evidence）与确定性验证收口（verify/validate）。不要把它理解成形式化流程；它的目的只是降低上下文噪声和错误动作概率。
