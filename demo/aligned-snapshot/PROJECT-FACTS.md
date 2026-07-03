# PROJECT FACTS — 受注管理システム（legacy-order）

<!-- ALIGN_STATE: aligned -->

> 状态：`ALIGNED @ 2026-07-03`（对 demo/legacy-order 的对齐快照；路径以该目录为基准）
> 每条断言带 `路径:行号` 证据。

## 1. 构建与栈
- Maven, Spring Boot 2.7.18（parent 继承）—— pom.xml:9-10  [confirmed]
- Java 8（`<java.version>8</java.version>`）—— pom.xml:20  [confirmed]
- MyBatis（mybatis-spring-boot-starter 2.3.2, XML mapper）—— pom.xml:31  [confirmed]
- 无 Lombok；getter/setter 全手写 —— form/Scr0201Form.java  [confirmed]
- 视图层：Controller 返回视图名（`scr0201/index`），仓库内无模板文件 —— web/Scr0201Controller.java:33  [confirmed]

## 2. 包结构与请求流
- 根包 `com.example.order`；分层包：`web` / `blogic` / `dao` / `entity` / `form` / `common`  [confirmed]
- **请求流：Controller → BLogic → Mapper(XML) → Entity。没有 Service 层。**
  证据：web/Scr0201Controller.java:38（Controller 直调 `orderSearchBLogic.execute(form)`）  [confirmed]

## 3. 各层写法
- 入口层：画面 ID 路由（`@RequestMapping("/scr0201")` + `/init` `/search`），`@ModelAttribute` 绑定 Form，
  返回视图名字符串 —— web/Scr0201Controller.java:23-24  [confirmed]
- 业务层：**BLogic 模式**。类名 `XxxBLogic`，继承 `AbstractBLogic<P,R>` 模板方法基类，
  实现 `doExecute`；运行时异常由基类统一转 `msg.common.e999` —— blogic/OrderSearchBLogic.java:18,
  blogic/AbstractBLogic.java:12-14  [confirmed]
- **检索结果总件数写回 Form**（照会画面共通方式）—— blogic/OrderSearchBLogic.java:35  [confirmed]
- 无事务注解（本 demo 全部照会系）；更新系出现时需另行确认  [assumed→用户已接受]
- MyBatis：**XML 放 `resources/sqlmap/`**（非 mapper/），namespace = 接口全限定名 ——
  sqlmap/OrderMapper.xml:4  [confirmed]
- **不规则列映射：`STATUS` → `statusCode`**，resultMap 为正，未开 map-underscore-to-camel-case ——
  sqlmap/OrderMapper.xml:10, application.yml  [confirmed]
- 排序：`ORDER BY ${sortColumn}`，值由 BLogic 用 `CodeConst.SORT_WHITELIST` 解析（白名单外用默认列）——
  sqlmap/OrderMapper.xml:39, blogic/OrderSearchBLogic.java:26, common/CodeConst.java:27  [confirmed]
- 分页：**手写 `LIMIT #{limit} OFFSET #{offset}`**（无 PageHelper），页大小 `CodeConst.PAGE_SIZE=20` ——
  sqlmap/OrderMapper.xml:40, common/CodeConst.java:20  [confirmed]
- Mapper 入参：**直接传画面 Form**（不建查询条件对象）—— dao/OrderMapper.java:16-23  [confirmed]

## 4. 命名约定
- 画面类/Form 以画面 ID 命名：`Scr0201Controller` / `Scr0201Form`；业务类 `XxxBLogic`；
  Mapper `XxxMapper`；表 `T_XXX`；列 SNAKE_CASE  [confirmed]

## 5. 异常与消息
- 异常不抛出到 Controller：BLogic 基类捕捉并转 `BLogicResult`（status + messageId）——
  blogic/AbstractBLogic.java:12-14  [confirmed]
- 消息 = properties key（`msg.<画面>.<番号>`）—— messages.properties:2  [confirmed]

## 6. 会话 / 上下文
- 本 demo 无登录概念  [confirmed]

## 7. 测试现状
- **JUnit 4**（junit:junit）—— pom.xml:41  [confirmed]
- **无 Mockito**：BLogic 测试用手写匿名类 stub，同包直接给 package-private 字段赋值 ——
  src/test/.../OrderSearchBLogicTest.java:33  [confirmed]
- Mapper 测试不起 Spring：`SqlSessionFactoryBuilder` + H2 内存库 + ScriptRunner 投入 schema/data ——
  src/test/.../OrderMapperTest.java:30-33, mybatis-test-config.xml  [confirmed]
- 测试方法名嵌 traceability ID（如 `scr0201_screen_001_...`）  [confirmed]

## 8. 式样书 / DEF 现状
- 式样书：`docs/spec/`（Markdown，機能設計書形式，带 ID）；DEF：`docs/def/`（YAML）  [confirmed]

## 9. 已有 AI 配置
- 无  [confirmed]

## 10. 构建与验证命令
- `mvn test`（JUnit4 × 11 件）—— 已固化进 verify.conf  [confirmed]

## ⚠️ 待确认 / 矛盾点
- （已清空——事务规约一条经用户裁决按 [assumed] 接受，见 §3）
