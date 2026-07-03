---
description: 对齐工作台与既存项目：勘探事实 → 摘样例 → 定契约 → 人工裁决 → 生效
---

# /onboard — 项目对齐

把工作台对齐到**这个项目的真实现状**。这是其他一切工作流的前提。
全程铁律：**只读业务代码；写事实不写理想；每条断言带 `路径:行号` 证据；没证据标 `[assumed]`**。

## 第 1 步：勘探事实 → `ai/kb/PROJECT-FACTS.md`

按事实卡里的清单逐项找证据填写（构建栈 / 包结构与请求流 / 各层写法 / MyBatis 细节 /
命名 / 异常与消息 / 会话 / 测试现状 / 式样书与 DEF 现状 / 已有 AI 配置 / 构建验证命令）。
项目大时可派 `code-analyst` 子代理分层勘探。矛盾点如实记录，不要抹平。

## 第 2 步：摘真实样例 → `ai/kb/examples/`

每层挑 1 个最典型的真实文件做 golden example（入口 / 业务 / Mapper 接口+XML / 实体 / 异常 / 测试）。
样例必须来自真实代码，允许删节（标 `// …略`）但保留 `路径:行号`。
存在明显不该模仿的旧写法时，另记 `examples/bad-patterns.md`。

## 第 3 步：特化规则

1. 用事实填 `ai/kb/rules/core-contract.md` 的 `{{占位符}}`。冲突时**事实优先**：模板说 Service、项目是 BLogic，就写 BLogic。
2. 核对 `ai/kb/rules/mybatis.md` 的项目段（XML 位置 / 分页 / resultMap 约定）。
3. 生成 `.github/instructions/*.instructions.md`：每层一个，`applyTo` glob 用**本项目真实包路径**，
   并用 Grep 验证 glob 至少命中 1 个真实文件。内容 = 该层硬约束 + 指向对应 example。

## 第 4 步：人工裁决（唯一需要人的节点）

汇总所有 `[assumed]` 与矛盾点，**逐条**向用户呈现并请其裁决（采纳/改写/删除）。
用户裁决后升级为 `[confirmed]`（附裁决记录）。**不许擅自把假设当事实。**

## 第 5 步：生效

1. 把 PROJECT-FACTS 里的构建/测试命令固化进 `ai/tools/verify.conf`（`UNIX=` 与 `WIN=` 两行；
   Windows 命令注意 wrapper 差异如 `mvnw.cmd`/`gradlew.bat`），然后按当前 OS 跑一次 verify
   （`bash ai/tools/verify.sh` 或 `ai\tools\verify.cmd`）确认真的通过。
2. 把 `PROJECT-FACTS.md` 头部状态从 `PLACEHOLDER` 改为 `ALIGNED @ <日期> @ <commit>`。
3. 若目标项目已有自己的 `CLAUDE.md` / `AGENTS.md` / copilot-instructions：**不覆盖**，向用户报告冲突并建议合并方式。

完成后报告：confirmed/assumed 条数、生成的文件清单、verify 结果。
