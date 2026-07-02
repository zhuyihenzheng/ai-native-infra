---
description: "把对齐产物装配成生效入口文件并启用三个工具。对齐流水线第 5 步（生效）。"
mode: agent
tools: ['codebase', 'read', 'editFiles', 'runCommands']
slash: align-activate
---

# /align-activate — 装配并生效

把 `project/` 的对齐产物装配到工具真正会读的生效位置。这是"让 copilot-instructions.md 之类生效"的唯一入口。

## 前置闸门（不满足就停）

- `project/ALIGN-STATUS.md` 顶部状态必须是 `aligned`。否则**拒绝**，提示先跑 `/align-review` 清空待确认项。
- `project/aligned-rules.md` 存在且无 `{{占位符}}`。

## 执行

**第 0 步：固化验证入口。** 把 `PROJECT-FACTS.md` §构建/验证命令固化成可执行的 `project/verify.sh`（无占位符；含 JDK/工具链选择等本机事实；只做只读构建/测试，不改代码不发布）。写完跑一次 `bash ai-infra/tools/aci.sh verify` 确认真的通过——这是 agent 以后收尾的一键门禁。

然后运行装配脚本（它负责备份 + 装配 + 开关）：

```bash
bash ai-infra/activate/promote.sh
```

脚本会：
1. **备份**目标项目已有的 `CLAUDE.md` / `AGENTS.md` / `.github/copilot-instructions.md` / `.github/instructions/` 到 `ai-infra/_backup-<时间戳>/`（绝不静默覆盖用户原有配置）。
2. 用 `activate/*.tpl` + `project/aligned-rules.md` **装配**生成：
   - 根 `CLAUDE.md`（核心契约 + 指向 `ai-infra/universal/prompts` 工作流 + Claude 专属）
   - 根 `AGENTS.md`（核心契约宪法，给 Codex）
   - `.github/copilot-instructions.md`（薄版，来自 `project/copilot-instructions.md`）
   - 拷 `project/instructions/*` → `.github/instructions/`
   - 拷 `project/examples/*`、工作流 prompts → `.github/prompts/`（供 Copilot slash）
3. 合并 `activate/settings.snippet.json` 进 `.vscode/settings.json`（开 `github.copilot.chat.codeGeneration.useInstructionFiles`）。

## 校验
- 跑 `bash ai-infra/tools/validate-ai-docs.sh`。
- 跑 `bash ai-infra/tools/aci.sh state`，确认 live entry files 已生成、git status 可解释。
- 跑 `bash ai-infra/tools/aci.sh verify`，确认一键验证入口绿。
- 抽查生成的根 `CLAUDE.md` / `.github/copilot-instructions.md`：核心契约在、无占位符、证据链在。

## 完成
- 更新 `ALIGN-STATUS.md`：`activate: done @ <时间戳>`。
- 告诉用户：已生效，三个工具现在按本项目对齐规则工作；如何回滚（从 `_backup-*` 恢复）；后续改规则要改 `project/` 源再重跑本步骤（build 模型）。
