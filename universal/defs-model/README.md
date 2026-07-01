# DEF 结构契约模型

> DEF = **机器可读的结构契约**（定义书正规化成 YAML），决定"有什么"。
> 式样书 = **行为契约**，决定"做什么"。两者都喂 AI，但角色不同：DEF 可确定性派生，式样书需判断。

## 为什么独立于式样书
代码/测试里的**字段名/型/桁/必須/列映射/code 值**只能来自 DEF，不许 AI 臆造。把结构从行为里剥离，AI 才分得清"照抄"(DEF) 和"判断"(spec)。

## 每类 DEF → 固定派生物（写进 project，对齐时校准）

| DEF 类 | 文件 | 派生 |
|---|---|---|
| DB定義 | `db/*.table.yml` | Entity + MyBatis ResultMap/Mapper + DDL/seed + 桁/型测试 |
| 画面項目定義 | `screen/*.screen.yml` | FormBean + 校验注解 + 画面项目 + 边界测试 |
| IF定義 | `api/*.api.yml` | ApiClient + req/res mapper + API mock + API 测试 |
| コード定義 | `code/code-master.yml` | enum / list-master + code 值测试 |
| メッセージ定義 | `message/messages.yml` | message bundle + 异常消息 |

## 工作约定
- 定义书原件常是 Excel → 用脚本正规化成 YAML（AI 消费 YAML：可 diff、可 review、确定）。
- DEF 变更 = 结构变更 → 重生派生物 + 跑 traceability ID 闭环检查。
- 模板见 `templates/`。
