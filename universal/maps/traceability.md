# Traceability（通用机制，免对齐）

用稳定 ID 串起 DEF/spec → testcase → test → fixture，让 AI 能算出任意改动的**爆炸半径**。

## ID 格式
```
{TARGET}-{TYPE}-{NUMBER}
```
- TARGET：屏幕/API/表/业务类名，如 `SCR0100`、`API0100`、`T_ORDER`。
- TYPE：`SCREEN` | `API` | `DB` | `SERVICE` | `MAPPER` | `SESSION` | `EXCEPTION` | `PAGINATION`。
- NUMBER：零填充序号，如 `001`。

例：`SCR0100-SCREEN-001`、`API0100-API-003`、`T_ORDER-DB-002`。

## 链路
| 层 | 位置 | 怎么带 ID |
|---|---|---|
| DEF / 式样书 | `defs/**`、`docs/specs/**` | 每个需求/字段段标 ID |
| 测试 case | `testcases/**/*.md` | 每条 case 标题以 ID 开头 |
| 可执行测试 | `src/test/**`、`tests/**` | 方法名 / `@DisplayName` 嵌 ID |
| Fixture / DB | `testdata/**`、`mocks/**` | 文件名或 `caseId` 字段引用 ID |

## AI 怎么用
- 改一段式样书/DEF → 全仓搜该 ID，找出所有要连带更新的 testcase/test/data。
- 生成测试时**复用既有 ID，不另造编号**。
- DB fixture 从 seed 确定性生成，seed 是唯一事实源。
