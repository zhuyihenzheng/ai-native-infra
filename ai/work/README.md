# work/ — 案件工作目录

每个案件（ticket）一个目录，存放该案件的 AI 工作产物：

```
ai/work/<ticket>/
├── impact.md      # /impact 影响调查结果
├── plan.md        # /plan 実装方針書（人审后状态 APPROVED）
└── testcases.md   # /test-design 测试观点 + case
```

- 这些是**过程产物**：案件合并后是否保留/提交由团队决定（保留则天然形成变更履历）。
- 跨案件仍有价值的知识不留在这里——用 `/remember` 沉淀进 `ai/kb/`。
