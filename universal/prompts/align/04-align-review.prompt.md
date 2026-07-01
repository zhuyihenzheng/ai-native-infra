---
description: "核对规则草稿与真实代码一致性，标 confirmed/assumed，搬进 project/。对齐流水线第 4 步。"
mode: agent
tools: ['codebase', 'search', 'read', 'editFiles']
slash: align-review
---

# /align-review — 核对并定稿

把 `_staging/` 的草稿逐条对照**真实代码**核验，区分"有证据的事实"和"模板默认的假设"，定稿到 `ai-infra/project/`。这是 promote 生效前最后的人/AI 把关。

## 步骤

1. 逐条读 `_staging/aligned-rules.md` 和 `_staging/instructions/*`。
2. 对每条规则：
   - 能在真实代码找到支撑 → 标 `[confirmed]`，附 `路径:行号`。
   - 找不到/与代码矛盾 → 标 `[assumed]` 或 `[conflict]`，写明分歧，**不要擅自当成事实**。
3. 校验 `instructions/*` 的 `applyTo` glob 是否真能命中本项目文件（用 search 验证至少命中 1 个真实文件）。
4. 把所有 `[assumed]` / `[conflict]` 汇总到 `ALIGN-STATUS.md` 的"待用户确认"区，**清晰列出每条该问用户什么**。

## 人工关口

- 向用户**逐条**呈现 `[assumed]` / `[conflict]`，请其裁决（采纳/改写/删除）。这是唯一需要人介入的节点。
- 用户裁决后，更新草稿，把状态从 `assumed` 升为 `confirmed`（带用户裁决记录）。

## 定稿

- 全部条目为 `confirmed`（或用户显式接受的 `assumed`）后，把草稿从 `_staging/` 移到：
  - `_staging/aligned-rules.md` → `project/aligned-rules.md`
  - `_staging/instructions/*` → `project/instructions/`
  - `_staging/copilot-instructions.md` → `project/copilot-instructions.md`
- 更新 `ALIGN-STATUS.md`：`review: done`。**只有当待确认清单清空时**，才把机器标记从 `<!-- ALIGN_STATE: not-aligned -->` 改成 `<!-- ALIGN_STATE: aligned -->`（这是 promote 的闸门，精确匹配该 token）。
- 跑 `bash ai-infra/tools/validate-ai-docs.sh` 确认无残留占位符、证据路径都存在。

## 完成
提示：对齐已定稿，可运行 `/align-activate` 生效；若仍有未决项，明确告诉用户还差哪几条。
