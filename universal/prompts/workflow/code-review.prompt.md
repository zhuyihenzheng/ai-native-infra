---
description: "按本项目对齐规则 + checklist 自审当前 diff，输出结构化指摘（带 ID + 严重度）。"
mode: agent
tools: ['codebase', 'search', 'read']
slash: code-review
---

# /code-review

对当前改动做对齐性自审。**只读，不自动改**（除非用户要求）。

## 审查维度
1. **对齐性**：是否符合 `project/aligned-rules.md`、各层 `instructions`、`examples` 样式？是否引入了项目没有的层/栈？
2. **forbidden**：有没有踩 `aligned-rules.md` 的禁止事项（改了无关路由/字段/列名、`${}` 拼接、原始 JSON 进视图等）？
3. **正确性**：跳层？事务边界？N+1？空值/边界？异常吞没？
4. **可追溯**：新代码挂了 ID 吗？改了式样书有没有连带测试/数据？
5. **安全**：fixture 是否全合成？无真实 PII？

## 输出
逐条指摘：`[严重度 高/中/低] 文件:行 — 问题 — 对齐依据(规则/示例) — 建议`。
按严重度排序。无问题则明说"未发现对齐性问题"。
