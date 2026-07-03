# Traceability — 稳定 ID 机制

用稳定 ID 串起 式样书/DEF → 测试 case → 可执行测试 → fixture，让 AI 能对任意改动算**爆炸半径**。

## ID 格式

```
{TARGET}-{TYPE}-{NUMBER}
```

- TARGET：画面/API/表/业务类，如 `SCR0100`、`API0100`、`T_ORDER`
- TYPE：`SCREEN` | `API` | `DB` | `SERVICE` | `MAPPER` | `SESSION` | `EXCEPTION` | `PAGINATION`
- NUMBER：零填充序号（异常系可用 `E01` 形式）

例：`SCR0100-SCREEN-001`、`T_ORDER-DB-002`、`SCR0100-SCREEN-E02`

## 链路

| 层 | 位置 | 带法 |
|---|---|---|
| 式样书 / DEF | `ai/specs/**`、项目 docs | 条目/字段段落标 ID |
| 测试 case | `ai/work/<ticket>/testcases.md` | case 标题 = ID |
| 可执行测试 | `src/test/**` | 方法名 / `@DisplayName` 嵌 ID |
| fixture | testdata 目录 | 文件名或 `caseId` 字段引用 ID |
| 产品代码 | `src/main/**` | 新代码 Javadoc/注释挂 ID |

## 用法

- 改一段式样书/DEF → 全仓搜该 ID（Grep），列出所有要连带更新的 testcase / 测试 / fixture / 代码。
- 生成测试时**复用既有 ID**；DB fixture 由 seed 确定性生成时，seed 是唯一事实源。
