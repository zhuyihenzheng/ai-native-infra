---
description: "从目标项目的真实代码中摘取每层的 golden example（不编造），供后续生成对齐。对齐流水线第 2 步。"
mode: agent
tools: ['codebase', 'search', 'read']
slash: align-extract
---

# /align-extract — 摘真实样例

基于 `ai-infra/project/PROJECT-FACTS.md`，从**真实代码**里挑出每层"最典型、最规范"的一个样本，作为本项目的 golden example。AI 后续生成代码会对齐这些样例，而不是对齐通用模板。

## 铁律

- **样例来自真实文件，不许编造、不许"美化"。** 允许删节无关行，但要标 `// …（略）` 并保留文件路径行号。
- 挑"代表性最好"的，不是"最复杂"的。每层 1 个，最多 2 个（一个正常、一个边界/特殊）。
- 同时摘一份反例：如果项目里存在明显不该模仿的旧写法，记到 `bad-patterns.md` 并说明为什么别学。

## 要摘的层（按 PROJECT-FACTS 实际存在的层，缺则跳过）

- 入口层（Controller / Action）
- 业务层（Service / BLogic）
- MyBatis Mapper 接口 + 对应 XML（**重点**：要能看出本项目 resultMap、动态 SQL、参数绑定、分页的真实写法）
- 实体 / DTO / Form
- 异常处理
- 单元测试 / 集成测试

## 输出

每层一个文件到 `ai-infra/project/examples/`：

```markdown
# Golden Example — <层名>
> 取自 src/.../RealClass.java（commit <hash>）。这是本项目该层的标准写法，生成新代码对齐此样式。

## 关键约定（从样本归纳）
- <命名/注解/结构要点，逐条>

## 样例
```java
// src/.../RealClass.java:10-60
<真实代码，可略节>
```
```

外加 `ai-infra/project/examples/bad-patterns.md`（若有）。

更新 `ALIGN-STATUS.md`：`extract: done`。完成后建议 `/align-draft`。
