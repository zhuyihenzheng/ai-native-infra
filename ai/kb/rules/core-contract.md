# 核心契约 —（待对齐）

> `/onboard` 用项目事实替换 `{{占位符}}` 后生效。冲突时**项目实测事实 > 本模板默认**。
> 每条标 `[confirmed]`（有代码证据）或 `[assumed]`（模板默认，待人裁决）。

## 本项目是什么

{{一句话：业务域 + 技术栈 + 新规/既存改修}}

## 请求流（不可跳层）

```
{{REQUEST_FLOW}}
```
<!-- 例: Browser → Controller → Service → Mapper(XML) → Entity → View
     或遗留: Browser → Action → BLogic → DAO → FormBean → JSP -->

上层不得绕过本层直达下下层；不新增本项目没有的层（Service/UseCase/Context 等）。

## 各层硬约束

| 层 | 包/位置 | 职责 | 禁止 |
|---|---|---|---|
| 入口 | `{{CONTROLLER_PKG}}` | {{路由/绑定/返回约定}} | 写业务逻辑；直接碰 Mapper |
| 业务 | `{{SERVICE_PKG}}` | {{命名/事务/base class 约定}} | 拼 SQL；处理 HTTP 细节 |
| 数据 | `{{MAPPER_PKG}}` | 见 `mybatis.md` | 放业务判断 |
| 模型 | `{{ENTITY_PKG}}` | 持数据/映射，来源=DEF | 放逻辑 |

事务边界：{{TX_RULE}}
异常处理：{{EXCEPTION_RULE}}
登录用户获取：{{LOGIN_CONTEXT_RULE}}

## 命名约定（从真实样本归纳）

| 对象 | 约定 | 证据 |
|---|---|---|
| Controller/入口类 | {{...}} | |
| 业务类 | {{...}} | |
| Mapper 接口 / SQL id | {{...}} | |
| 实体/DTO/Form | {{...}} | |
| 表 / 列 | {{...}} | |
| 测试类/方法 | {{...}} | |

## 禁止事项（forbidden，违反即错误产出）

- 无式样书依据不改：路由、public 签名、字段/属性名、SQL 列名、表结构。
- 不引入项目未使用的技术栈；不"现代化"遗留结构。
- MyBatis 禁 `${}` 拼接（白名单排序列除外，白名单位置：{{...}}）。
- 不硬编码 code 名称（code master / list master：{{...}}）。
- fixture 禁真实个人信息 / 凭证 / 客户数据。
- {{本项目特有禁忌，对齐时补充}}

## 命令

- build：{{...}}
- 全量测试：{{...}} / 单模块：{{...}}
- 一键验证：`bash ai/tools/verify.sh`
