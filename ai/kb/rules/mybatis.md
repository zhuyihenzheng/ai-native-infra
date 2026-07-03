# MyBatis 规约

> 硬约束段免对齐即生效；「本项目段」由 `/onboard` 填充。MyBatis 是最易出事的层，单独强约束。

## 硬约束（默认适用，除非项目有明确反例）

- **强制 `#{}` 参数绑定，禁止 `${}` 拼接**（SQL 注入）。唯一例外：动态列名/排序方向，且必须走白名单校验。
- XML 与接口对应：namespace = 接口全限定名，`<select id>` = 方法名。
- resultMap / 列↔字段映射来源 = DB 定義（DEF），不手写脏映射。
- 动态 SQL 用 `<where>/<if>/<foreach>/<choose>`，不在 Java 端拼 SQL 字符串。
- 避免 N+1：关联用 join 或显式 batch，不在循环里发查询。
- 一条 SQL 一个职责；复杂查询写注释说明意图。
- 改既存 SQL 前确认动态分支全集（`<if>` 组合），改动不得改变未涉及分支的语义。

## 本项目段（对齐时填充）

- XML 位置：{{MAPPER_XML_LOCATION}}
- 分页机制：{{PAGINATION_MECHANISM}} <!-- PageHelper / RowBounds / 手写 limit -->
- 排序白名单位置：{{SORT_WHITELIST}}
- resultMap 约定：{{RESULTMAP_CONVENTION}}
- 真实样例：`ai/kb/examples/mapper.md`（生成新 mapper 对齐它）
