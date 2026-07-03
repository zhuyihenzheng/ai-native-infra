---
description: 按对齐规则 + checklist review 当前改动
argument-hint: "[diff范围，默认工作区未提交改动]"
---

# /review — 代码 review

对 `$ARGUMENTS`（默认 `git diff` + `git diff --cached`，可指定分支/commit 范围）做 review。

## 步骤

1. 派 `code-reviewer` 子代理执行，传给它 diff 范围和关联的 ticket（若知道，
   让它顺带核对改动是否都在 `ai/work/<ticket>/plan.md` 的文件清单内）。
2. 原样呈现其结构化指摘（严重度 高/中/低 + 依据 + 建议）与 checklist 走查结果。
3. **只读不自动改**；用户要求修复时，按指摘逐条最小修复，改完重跑 `bash ai/tools/verify.sh`。
4. 出现「高」严重度指摘、或同类问题第二次出现时，提示用户运行 `/remember` 把它沉淀进
   `ai/kb/lessons.md`——review 指摘是项目记忆最重要的来源。
