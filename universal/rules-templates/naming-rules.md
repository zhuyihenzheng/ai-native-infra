# 命名规约（模板）

> `/align-draft` 从 `PROJECT-FACTS §4` 真实样本**归纳**填充，不照搬通用规范。

| 对象 | 本项目约定 | 证据 |
|---|---|---|
| 根包 | `{{ROOT_PKG}}` | |
| Controller/入口类 | `{{CONTROLLER_NAMING}}` | |
| 业务类 | `{{SERVICE_NAMING}}` | |
| Mapper 接口 | `{{MAPPER_NAMING}}` | |
| Mapper XML id | `{{SQLID_NAMING}}` | |
| 实体/DTO/Form | `{{MODEL_NAMING}}` | |
| 表名 | `{{TABLE_NAMING}}` | |
| 列名 | `{{COLUMN_NAMING}}` | |
| 测试类/方法 | `{{TEST_NAMING}}` | |

> 字段命名（camelCase / snake_case 列映射）以本项目真实代码为准；与"标准 Java 规范"冲突时**服从项目现状**。
