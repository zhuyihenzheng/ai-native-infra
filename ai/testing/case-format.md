# 测试 case 格式

```markdown
## {TARGET}-{TYPE}-{NUMBER}（式样书/DEF の ID を複用、不另造编号）

- Target:        被测对象（类#方法 / 画面 / API）
- Source:        式样书条目 / DEF 字段（带 ID）
- Category:      boundary(来自DEF) | behavior(来自式样书) | regression(回归)
- Viewpoint:     观点（对应 viewpoints.md 条目号）
- Preconditions: 前置条件（DB 状态 / 登录角色）
- Input:         输入（内联或指向 fixture 文件）
- Steps:         步骤（可省略，单步时）
- Expected:      期望结果（画面/返回值/DB 值/消息 ID）
- Notes:         手動 / 自動化不可 等标记
```

- 一条 case 一个断言主题。
- 实装成测试代码时方法名或 `@DisplayName` 嵌同一 ID（见 `traceability.md`）。
- 文末附観点走查表：viewpoints.md 每个观点 → case ID 或「対象外：理由」。
