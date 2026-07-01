---
description: "DEF + 式样书 → Markdown 测试 case（结构/边界来自 DEF，行为来自式样书）。输入: target=Xxx"
mode: agent
tools: ['codebase', 'search', 'read', 'editFiles']
slash: spec-to-testcases
---

# /spec-to-testcases

为目标生成测试 case 定义（Markdown，带 ID）。核心思想：**两类来源**。

## 两类测试 case
1. **结构/边界 case（来自 DEF，可确定性派生）**：每个字段的 必須 / 型 / 桁上限 / code 值合法集 / 边界值。覆盖率高、机械、别漏。
2. **行为 case（来自式样书，需判断）**：正常系 / 异常系 / 业务エラー / 画面遷移 / 前置条件组合。

## 步骤
1. 读式样书 + 对应 DEF。
2. 从 DEF 自动展开边界 case；从式样书展开行为 case。
3. 套测试观点补漏：`ai-infra/universal/testing/`（按层）。
4. 用 `universal/testing/test-case-format.md` 的格式输出到项目 `testcases/**/*.md`。
5. **复用式样书/DEF 的 ID，不另造编号**（见 traceability）。

## 收尾
跑 `validate-ai-docs.sh`。提示可继续 `/testcases-to-data`、`/testcases-to-junit`。
