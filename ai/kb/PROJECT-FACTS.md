# PROJECT FACTS —（待对齐）

<!-- ALIGN_STATE: not-aligned -->
<!-- ↑ 机器闸门标记，由 /onboard 第 5 步把值改为 aligned（精确 token，本注释故意不写全）。
     值不是 aligned 时，PreToolUse hook 硬拦截对业务代码的编辑（ai/tools/hooks/）。 -->

> 状态：`PLACEHOLDER` —— 运行 `/onboard` 后由 AI 用真实代码证据填充。
> 在那之前本文件不代表任何项目事实，**禁止据此生成代码**。
> 对齐后状态改为 `ALIGNED @ <日期> @ <commit>`；每条断言带 `路径:行号` 证据并标 `[confirmed]`/`[assumed]`。

## 1. 构建与栈
<!-- 构建工具、Java 版本、Spring Boot 版本、MyBatis 版本、Lombok/校验框架、视图层(JSP/Thymeleaf/REST-only)。证据: pom.xml / build.gradle -->

## 2. 包结构与请求流
<!-- 根包、各层包名、真实请求流(如 Controller → Service → Mapper(XML) → Entity，或遗留 Action → BLogic → DAO)。每层列 2~3 个真实类路径 -->

## 3. 各层写法
<!-- 入口层: 注解/路由风格/入参绑定/返回类型。业务层: 命名/事务注解位置/base class。
     MyBatis: XML位置/namespace约定/resultMap/动态SQL/分页机制/${} 现状。实体: 字段命名/列映射方式 -->

## 4. 命名约定
<!-- 包/类/方法/SQL id/表/列 的真实命名规律，从样本归纳 -->

## 5. 异常与消息
<!-- 异常分层、统一处理(@ControllerAdvice?)、消息来源(properties? code master?) -->

## 6. 会话 / 上下文
<!-- 登录用户从哪取(SecurityContext? ThreadLocal? session?) -->

## 7. 测试现状
<!-- 框架(JUnit4/5)、Mock 方式、集成测试有无、测试数据准备方式、测试类命名 -->

## 8. 式样书 / DEF 现状
<!-- 项目里定义书/式样书的位置与格式(Excel? Markdown?)；没有则标 none -->

## 9. 已有 AI 配置
<!-- 既存 CLAUDE.md / AGENTS.md / copilot-instructions / .cursorrules 逐一列路径，对齐生效前必看 -->

## 10. 构建与验证命令
<!-- build / 全量测试 / 单模块测试 / 本地起服务。对齐时固化进 ai/tools/verify.conf（UNIX= / WIN=） -->

## ⚠️ 待确认 / 矛盾点
<!-- 所有 [assumed] 与代码内不一致处登记于此；/onboard 第 4 步逐条请用户裁决 -->
