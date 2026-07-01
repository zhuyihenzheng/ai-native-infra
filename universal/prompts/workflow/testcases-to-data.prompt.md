---
description: "测试 case → 测试数据 fixture（input/expected），caseId 回链测试 ID。"
mode: agent
tools: ['codebase', 'search', 'read', 'editFiles']
slash: testcases-to-data
---

# /testcases-to-data

把测试 case 的 Input/Expected 落成可执行的数据 fixture。

## 步骤
1. 读目标 `testcases/**/*.md`。
2. 按本项目 fixture 约定（对齐时记录的 `testdata/` 结构）生成 `input/` 与 `expected/` 数据文件。
3. 每个 fixture 带 `caseId` 字段回链测试 ID。
4. DB fixture 若由 seed 确定性生成，则改 seed/生成脚本，不手改生成产物。

## 铁律
- **全部合成数据**。禁止真实个人信息/凭证/客户数据/真实内部标识符。
- 数据要触发该 case 的断言主题（边界 case 用边界值，异常 case 用非法值）。

跑 `validate-ai-docs.sh`。
