# 架构规约（模板）

> 这是**通用模板**。`/align-draft` 会用 `PROJECT-FACTS.md` 把 `{{占位符}}` 换成本项目真实事实。
> 替换原则：项目实际怎样就写怎样，模板默认无证据时标 `[assumed]`。

## 请求流（不可跳层）

```
{{REQUEST_FLOW}}
```
> 例：`Browser → Controller → Service → Mapper(XML) → Entity → View/DTO`
> 或遗留：`Browser → Action → InputBean → executeBusinessProcess → BLogic → Mapper/DAO → FormBean → JSP`

逐层禁止跳过；上层不得绕过本层直达下下层。

## 各层职责

| 层 | 包/位置 | 职责 | 不该做 |
|---|---|---|---|
| 入口 | `{{CONTROLLER_PKG}}` | {{CONTROLLER_ROLE}} | 写业务逻辑 / 直接碰 Mapper |
| 业务 | `{{SERVICE_PKG}}` | {{SERVICE_ROLE}} | 拼 SQL / 处理 HTTP 细节 |
| 数据 | `{{MAPPER_PKG}}` | {{MAPPER_ROLE}} | 放业务判断 |
| 模型 | `{{ENTITY_PKG}}` | 持有数据/映射 | 放逻辑 |

## 事务边界
{{TX_RULE}}  <!-- 例：@Transactional 只加在 Service 层 -->

## 优先级声明
**本项目实测事实 > 通用模板默认。** 冲突时以 PROJECT-FACTS 证据为准。
