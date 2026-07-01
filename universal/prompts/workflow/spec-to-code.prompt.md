---
description: "DEF(结构) + 式样书(行为) → 对齐本项目的代码骨架与实装。输入: spec=docs/specs/.../Xxx.md"
mode: agent
tools: ['codebase', 'search', 'read', 'editFiles']
slash: spec-to-code
---

# /spec-to-code

以**式样书（行为契约）+ DEF（结构契约）**为正本，生成/更新代码，并对齐本项目真实写法。

## 前置
- 项目必须已对齐：`ai-infra/project/ALIGN-STATUS.md` = `aligned`。否则先跑对齐流水线。

## 步骤
1. 读输入式样书；找到它引用的 DEF（`ai-infra/.../defs/` 或项目内定义书）。
2. 读对齐规则：`project/aligned-rules.md`、相关 `project/instructions/*`、对应层 `project/examples/*`。
3. **结构来自 DEF**：字段名/型/桁/必須/列映射/code 值——直接照 DEF，不臆造。
4. **行为来自式样书**：路由、业务流程、画面遷移、异常分支。
5. 按本项目请求流逐层实装，**对齐 examples 的样式**（命名/注解/结构）。
6. 给每个产物挂 traceability ID（见 `universal/maps/traceability.md`），回链式样书区段。

## 约束
- 遵守 `project/aligned-rules.md` 的 forbidden 段。标 `[assumed]` 的规则按假设处理并提示用户。
- 未实装范围只生成骨架并标注「未実装」。

## 收尾
- 跑本项目 build/test（命令见 aligned-rules）；涉及画面/接口按对齐规则做端到端验证。
- 跑 `bash ai-infra/tools/validate-ai-docs.sh`。
