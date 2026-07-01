# 分层细则（模板）

> `/align-draft` 拆成各层 `project/instructions/*.instructions.md`（带 `applyTo` glob，按本项目真实包路径）。

## 入口层（Controller / Action）
- 路由风格：{{ROUTE_STYLE}}；入参绑定：{{PARAM_BINDING}}；返回：{{RETURN_TYPE}}。
- 只编排，不写业务。调用业务层方式：{{HOW_TO_CALL_BUSINESS}}。

## 业务层（Service / BLogic）
- 业务逻辑唯一归处。事务：{{TX_RULE}}。入出参：{{IO_BEAN_RULE}}。
- 有无 base class / 模板方法：{{BASE_CLASS_RULE}}。

## 数据层（Mapper / DAO）
- 见 `mybatis-rules.md`。

## 模型层（Entity / DTO / Form）
- 只持状态，不放逻辑。校验注解来源 = DEF（画面定義/DB定義）。
- 展示对象不渲染原始 JSON / 不渲染默认 `toString()`：{{DISPLAY_RULE}}。

## 异常 / 会话
- 异常分层与统一处理：{{EXCEPTION_RULE}}。
- 当前用户获取：{{LOGIN_CONTEXT_RULE}}。
