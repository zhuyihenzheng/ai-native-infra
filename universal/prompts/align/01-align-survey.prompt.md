---
description: "勘探目标已有项目的真实结构与约定，产出带代码证据的事实卡。对齐流水线第 1 步。"
mode: agent
tools: ['codebase', 'search', 'read']
slash: align-survey
---

# /align-survey — 勘探事实

你是接手一个**已有项目（brownfield）**的 AI 架构勘探员。目标：把这个项目**真实**的技术栈与约定，提炼成一张事实卡 `ai-infra/project/PROJECT-FACTS.md`。

## 铁律

- **只读，不改任何业务代码。**
- **每条断言必须带证据**：`说法 —— 见 src/.../Xxx.java:行号`。没有证据的条目标 `assumed`，宁缺毋假。
- **写事实，不写理想**：项目实际怎么写就怎么记，哪怕它"不规范"。对齐的目的是贴合现状，不是纠正它。
- 不臆造层。项目没有 Service 层就别写 Service 层。

## 勘探清单（逐项找证据填写）

1. **构建与栈**：构建工具（Maven/Gradle）、Java 版本、Spring Boot 版本、关键依赖（MyBatis 版本、Lombok？校验框架？视图层 JSP/Thymeleaf/REST-only？）。证据：`pom.xml` / `build.gradle`。
2. **包结构与分层**：根包、各层包名（controller? action? service? businesslogic? mapper? dao? entity? dto? form?）。真实请求流是什么（`Controller → ? → ? → Mapper → ?`）。证据：列出每层 2~3 个真实类路径。
3. **各层写法**：
   - Controller/入口：注解、路由风格（REST `@GetMapping` 还是屏幕名）、入参绑定方式、返回类型。
   - 业务层：类怎么命名、事务注解在哪层、业务逻辑归处、有没有 base class / 模板方法。
   - **MyBatis**：XML mapper 还是注解？XML 放哪（`resources/mapper/`?）、namespace 约定、resultMap 用法、动态 SQL、是否有 `${}` 风险、分页机制（PageHelper? 手写 limit?）。证据：1 个真实 mapper 接口 + 对应 XML 路径。
   - 实体/DTO：字段命名（camelCase？）、列↔字段映射方式。
4. **命名约定**：包/类/方法/SQL id/表/列 的真实命名规律（从样本归纳，别照搬通用规范）。
5. **异常与消息**：异常分层、统一异常处理（`@ControllerAdvice`?）、消息来源（properties? code master?）。
6. **会话/上下文**：登录用户从哪取（SecurityContext? ThreadLocal? session?）。
7. **测试现状**：测试框架（JUnit4/5）、Mock（Mockito/MockMvc）、有没有集成测试、测试数据怎么准备、测试类命名。
8. **DEF / 式样书现状**：项目里有没有定义书/规格（Excel? Markdown? `docs/`?）。有就记位置；没有就标 `none`。
9. **已有 AI 配置**：是否已存在 `CLAUDE.md` / `AGENTS.md` / `.github/copilot-instructions.md` / `.github/instructions/` / `.cursorrules` 等。**逐一列出路径**——`/align-activate` 要决定备份/合并/覆盖。
10. **构建与验证命令**：怎么 build、怎么跑测试、怎么本地起服务。证据：脚本或 README。

## 输出

写 `ai-infra/project/PROJECT-FACTS.md`，结构：

```markdown
# PROJECT FACTS — <项目名>
> 勘探日期 / 勘探者(AI) / commit hash
> 状态：SURVEYED（未 review）

## 1. 构建与栈
- Java 17, Spring Boot 3.x —— 见 pom.xml:12  [confirmed]
...
## 9. 已有 AI 配置（promote 前必看）
- 存在 .github/copilot-instructions.md —— 路径...  [confirmed]
...
## ⚠️ 待确认 / 矛盾点
- <列出所有 assumed 和发现的不一致>
```

最后更新 `ai-infra/project/ALIGN-STATUS.md`：`survey: done`，并把每个 `assumed`/矛盾点登记进待确认清单。**不要**把状态改成 `aligned`。

## 完成提示

告诉用户：事实卡已生成，列出 `assumed` 项数量，建议下一步 `/align-extract`。
