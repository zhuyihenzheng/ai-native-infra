# 测试 case 格式（通用）

```text
## {TARGET}-{TYPE}-{NUMBER}

- Target:          被测对象
- Source:          DEF / 式样书 区段（带 ID）
- Category:        boundary(来自DEF) | behavior(来自式样书)
- Viewpoint:       测试观点
- Preconditions:   前置条件
- Input:           输入（指向 testdata input 文件）
- Steps:           步骤
- Expected:        期望结果（指向 expected 文件）
- Data files:      关联 fixture
- Notes:
```

一条 case 一个断言主题。ID 复用 DEF/式样书的编号，不另造。
