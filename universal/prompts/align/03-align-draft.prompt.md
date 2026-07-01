---
description: "把 universal 规则模板特化成本项目对齐规则草稿（落 _staging，不直接生效）。对齐流水线第 3 步。"
mode: agent
tools: ['codebase', 'search', 'read', 'editFiles']
slash: align-draft
---

# /align-draft — 特化规则草稿

把 `ai-infra/universal/rules-templates/*` 里的**通用模板**（带 `{{占位符}}`），用 `PROJECT-FACTS.md` + `project/examples/` 里的**项目事实**填实，产出对齐规则草稿。

## 输入
- `ai-infra/project/PROJECT-FACTS.md`（事实，含证据）
- `ai-infra/project/examples/*`（真实样例）
- `ai-infra/universal/rules-templates/*.md`（待特化模板）
- `ai-infra/universal/maps/traceability.md`（ID 机制，原样沿用）

## 铁律
- **占位符必须被真实事实替换**，不许留 `{{...}}`，也不许编造没证据的内容。无事实可填的条目标 `<!-- assumed: 模板默认，待确认 -->`。
- **冲突时事实优先**：模板说"用 Service 层"，项目实际是"BLogic"，就写 BLogic。模板是建议，项目是法律。
- 每条规则尽量回链证据（`见 PROJECT-FACTS §x` 或 `路径:行号`）。
- 产物落 `ai-infra/_staging/`，**不要**写进 `.github/` 或根入口文件——那是 `/align-activate` 的事。

## 产出（全部写到 `ai-infra/_staging/`）

1. `_staging/aligned-rules.md` — **核心契约**（会被装配进三个入口）：项目身份/栈、真实请求流（不可跳层）、各层硬约束、forbidden、命令、安全。控制在 ~1.5 屏，浓缩、可执行。
2. `_staging/instructions/*.instructions.md` — 各层 path-scoped 规则，**带 `applyTo` glob**（按本项目真实包路径写 glob！）。每个对应一层，引用对应 golden example。
3. `_staging/copilot-instructions.md` — Copilot 薄版：最关键 5~10 条 do/don't + 指向 instructions。
4. 每条规则标 `[confirmed]` / `[assumed]`。

## 完成
更新 `ALIGN-STATUS.md`：`draft: done`，汇总 `assumed` 条目到待确认清单。提示用户：草稿在 `_staging/`，下一步 `/align-review` 核对，**尚未生效**。
