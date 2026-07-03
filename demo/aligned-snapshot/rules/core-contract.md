# 核心契约 — 受注管理システム（legacy-order 对齐快照）

> 由 /onboard 从 PROJECT-FACTS 特化。冲突时项目实测事实优先。

## 本项目是什么

受注管理系统（既存改修）。Spring Boot 2.7 / Java 8 / MyBatis(XML)，画面驱动的照会・更新系业务。

## 请求流（不可跳层）

```
Browser → Scr××××Controller → XxxBLogic(AbstractBLogic継承) → XxxMapper(XML) → Entity
```

**没有 Service 层，禁止新建**。Controller 只编成，业务全部在 BLogic 的 `doExecute`。

## 各层硬约束

| 层 | 包 | 职责 | 禁止 |
|---|---|---|---|
| 入口 | `com.example.order.web` | 画面 ID 路由（`/scrXXXX/动作`）、`@ModelAttribute` 绑 Form、调 BLogic、装 Model | 业务逻辑；直接碰 Mapper |
| 业务 | `com.example.order.blogic` | `XxxBLogic extends AbstractBLogic<P,R>`，实现 `doExecute`；结果用 `BLogicResult`（status+messageId）；**总件数写回 Form** | 抛异常到上层（基类兜底 e999）；拼 SQL |
| 数据 | `com.example.order.dao` | `@Mapper` 接口 + `resources/sqlmap/*.xml`；**入参直接传 Form** | 业务判断 |
| 模型 | `entity` / `form` | 手写 getter/setter（无 Lombok）；列映射以 resultMap 为正 | 逻辑 |

事务边界：本项目当前无更新系，出现时需用户确认规约 [assumed]
异常处理：BLogic 基类统一捕捉 → `msg.common.e999`
消息：`messages.properties`，key 形如 `msg.<画面>.<番号>`

## 命名约定

| 对象 | 约定 | 证据 |
|---|---|---|
| 画面类/Form | `Scr<4桁>Controller` / `Scr<4桁>Form` | web/Scr0201Controller.java |
| 业务类 | `XxxBLogic` | blogic/OrderSearchBLogic.java |
| Mapper / SQL id | `XxxMapper` / 动词ByXxx（`countByCondition`） | dao/OrderMapper.java |
| 表 / 列 | `T_XXX` / SNAKE_CASE | schema.sql |
| 测试方法 | 小写蛇形 + traceability ID | src/test |

## 禁止事项（forbidden）

- 不新建 Service/UseCase 层；不引入 Lombok/Mockito/PageHelper 等项目没有的库。
- MyBatis 禁 `${}`——唯一既存例外是排序列 `${sortColumn}`，且值必须经
  `CodeConst.SORT_WHITELIST` 解析（新增可排序列必须同步登记白名单）。
- 不改 `STATUS→statusCode` 等既存列映射；resultMap 为正，不开 camelCase 自动映射。
- 不模仿 `dao/OrderCsvDao.java` 的字符串拼接 SQL（见 examples/bad-patterns.md）。
- fixture 全合成数据。

## 命令

- build/全量测试：`mvn test`
- 一键验证：macOS/Linux `bash ai/tools/verify.sh` / Windows `ai\tools\verify.cmd`
