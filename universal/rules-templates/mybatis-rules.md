# MyBatis 规约（模板）

> `/align-draft` 用本项目真实 mapper 写法替换 `{{占位符}}`。MyBatis 是最易出事的层，单独成篇强约束。

## 硬约束（默认即适用，除非项目有明确反例）

- **强制 `#{}` 参数绑定，禁止 `${}` 拼接**（SQL 注入）。唯一例外：动态列名/排序方向，且必须走**白名单**校验。 [confirmed-by-default]
- XML 与接口对应：`{{MAPPER_XML_LOCATION}}`，namespace = 接口全限定名，`<select id>` = 方法名。
- resultMap / 列↔字段映射来源 = **DB定義（DEF）**，不手写脏映射。`{{RESULTMAP_CONVENTION}}`
- 动态 SQL 用 `<where>/<if>/<foreach>/<choose>`，不在 Java 端拼 SQL 字符串。
- **分页**：{{PAGINATION_MECHANISM}}（例：PageHelper / 手写 limit+offset）。排序字段走白名单。
- 避免 N+1：{{NPLUS1_RULE}}（关联查询用 join 或显式 batch，不在循环里查）。
- 一条 SQL 一个职责；复杂查询写注释说明意图。

## 本项目真实写法
参照 `ai-infra/project/examples/mapper-xml.md`（从真实代码摘）。生成新 mapper 对齐它。

## 命名
SQL id / 接口方法 / 表 / 列 命名见 `naming-rules.md`。
