# DEF — 结构契约（机器可读定义）

> **DEF = 结构**（有什么：字段/型/桁/必須/列映射/code 值）→ 可确定性派生，AI 照抄不臆造。
> **式样书 = 行为**（做什么：流程/异常/遷移/業務ルール）→ 需要判断。
> 两者分离，AI 才分得清「照抄」和「判断」。

| DEF 类 | 文件 | 派生物 |
|---|---|---|
| DB 定義 | `db/*.table.yml` | Entity + ResultMap/Mapper + DDL/seed + 桁·型边界测试 |
| 画面項目定義 | `screen/*.screen.yml` | Form + 校验注解 + 画面项目 + 边界测试 |
| IF 定義 | `api/*.api.yml` | ApiClient + req/res 映射 + mock + API 测试 |
| コード定義 | `code/code-master.yml` | enum / list-master + code 值测试 |
| メッセージ定義 | `message/messages.yml` | message bundle + 异常消息 |

约定：

- 定义书原件是 Excel 时，正规化成 YAML 后再喂 AI（可 diff、可 review、确定）。Excel 仍是客户正本的场合，YAML 头部注明出处与版数。
- DEF 变更 = 结构变更 → 重生派生物 + 全仓搜 traceability ID 做闭环检查。
- 模板见 `templates/`。项目已有等价定义书体系时，**沿用项目的**，本目录只作补充。
