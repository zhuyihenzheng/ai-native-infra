# AGENTS.md

> 本文件由 `ai-infra/activate/promote.sh` 装配生成。**请勿手改**——改 `ai-infra/project/aligned-rules.md` 源后重跑 promote。

本项目编码 agent（Codex / Copilot coding agent）的正本「宪法」。下方"核心契约"是本项目对齐后的硬规则；动手前必须遵守。

## 工作约定

- 本契约是从**本项目真实代码**对齐而来（证据见 `ai-infra/project/PROJECT-FACTS.md`）。**项目事实 > 通用默认**，冲突以事实为准。
- 生成新代码前，参照对应层的真实样例：`{{INFRA_DIR}}/project/examples/`。
- 标 `[assumed]` 的规则是模板默认、尚未被代码证实，按它行事时要标注、留给人确认。
- 可复用任务工作流在 `{{INFRA_DIR}}/universal/prompts/workflow/`。
- 仓库观察优先用 ACI：`bash {{INFRA_DIR}}/tools/aci.sh state/find/grep/view/trace/diff/validate`，让搜索/查看/验证输出受控、可复盘。
- 安全：所有 fixture 用合成数据，禁止写入真实个人信息/凭证/客户数据。

---
（核心契约见下）
