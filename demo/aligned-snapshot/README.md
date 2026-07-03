# aligned-snapshot — /onboard 标准产出快照

对 `../legacy-order/` 跑完 `/onboard` 应产出的**基准答案**（不含 hooks/闸门状态等本机文件）：

```
PROJECT-FACTS.md        # 事实卡：全部条目带 路径:行号 证据
rules/core-contract.md  # 特化后的核心契约（占位符已替换为靶场事实）
examples/blogic.md      # 业务层 golden example
examples/mapper.md      # Mapper 接口+XML golden example（重点层）
examples/bad-patterns.md# 抓到的坏样例（OrderCsvDao）
verify.conf             # 固化的验证命令
```

## 用途

1. **活文档**：新用户看这里就知道"对齐后长什么样"。
2. **工作台回归基准**：改了 `/onboard` 流程或规则模板后，在靶场重跑一次对齐，
   与本快照 diff——关键事实（BLogic 模式、sqlmap 位置、STATUS→statusCode 映射、
   `${}` 白名单、JUnit4 手写 stub、总件数写回 Form）漏了任何一条即为退化。

> 证据行号以 `demo/legacy-order/` 下路径为基准。靶场代码变更后需同步更新本快照。
