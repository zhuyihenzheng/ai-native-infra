---
description: 式样书/方针 → 测试观点 + 测试 case（Markdown，带 traceability ID）
argument-hint: <ticket编号 或 式样书路径>
---

# /test-design — 测试设计

为 `$ARGUMENTS` 生成测试观点与测试 case，产物写入 `ai/work/<ticket>/testcases.md`。

## 步骤

1. 定位输入：式样书 + 关联 DEF + `ai/work/<ticket>/plan.md`（若有）。
2. 派 `test-designer` 子代理执行，明确传给它：式样书/DEF/plan 路径、输出路径、
   是否为既存改修（是则必须含回归观点）。
3. 收到产物后抽查三件事：
   - **観点走查表**是否覆盖 `ai/testing/viewpoints.md` 全目录（不适用项有理由）；
   - ID 是否复用式样书/DEF 的 traceability ID（不许另造编号）；
   - boundary case 的字段/桁/code 值是否与 DEF 一致。
4. 向用户呈现 case 统计（boundary/behavior/回归 各几条）+ 需要人判断的观点空白。

case 定稿后提示继续 `/impl-tests`（需要 fixture 数据时先按 case 的 Input/Expected 生成合成数据文件）。
