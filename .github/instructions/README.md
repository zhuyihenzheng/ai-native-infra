# instructions/ — Copilot path-scoped 分层规则（待对齐）

`/onboard` 第 3 步按本项目**真实包路径**生成 `*.instructions.md`（每层一个，带 `applyTo` glob）。
内容 = 该层硬约束（来自 `ai/kb/rules/core-contract.md`）+ 指向 `ai/kb/examples/` 对应样例。

生成示例：

```markdown
---
applyTo: "src/main/java/com/example/**/mapper/**"
---
本层规则见 ai/kb/rules/mybatis.md；写法对齐 ai/kb/examples/mapper.md。
强制 #{} 绑定；namespace = 接口全限定名；resultMap 来源 = DB 定義。
```
