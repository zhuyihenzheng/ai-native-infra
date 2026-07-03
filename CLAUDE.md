# CLAUDE.md — AI Native Java 工作台

本项目使用 AI Native Java 开发工作台，面向 Java / Spring Boot / MyBatis 既存系统的式样书驱动开发（日本 SI 流程）。

## 开工前必读（按顺序，缺一不可）

1. `ai/kb/rules/core-contract.md` — 本项目核心契约（技术栈、请求流、各层硬约束）
2. `ai/kb/rules/change-safety.md` — 修改既存代码的安全规则（**最高优先级**）
3. `ai/kb/PROJECT-FACTS.md` — 项目事实卡（每条带 `路径:行号` 证据）
4. 动手写某层代码前，先看 `ai/kb/examples/` 对应层的真实样例——**对齐样例，不对齐通用惯例**

## 对齐闸门

`ai/kb/PROJECT-FACTS.md` 头部状态为 `PLACEHOLDER` 时，本项目**尚未对齐**：
除 `/onboard` 外，不要生成或修改任何业务代码。

## 工作流（slash commands）

| 场景 | 命令 | 产物 |
|---|---|---|
| 首次导入 / 对齐项目 | `/onboard` | 事实卡 + 样例 + 核心契约 |
| 改动前影响调查 | `/impact <类/表/ID/式样书>` | 影响范围报告（含证据） |
| 式样书 → 实装方针 | `/plan <式样书路径>` | `ai/work/<ticket>/plan.md`（人 review 后再实装） |
| 方针 → 代码 | `/implement <ticket>` | 最小 diff 的代码改动 |
| 测试观点 + 测试 case | `/test-design <ticket>` | `ai/work/<ticket>/testcases.md` |
| case → JUnit | `/impl-tests <ticket>` | 项目风格的可执行测试 |
| 代码 review | `/review` | 按 checklist 的结构化指摘 |
| 沉淀项目记忆 | `/remember` | kb 更新（事实/决策/教训/模块笔记） |

标准链路：**式样书 → `/impact` → `/plan`（人审）→ `/implement` → `/test-design` → `/impl-tests` → `/review` → `/remember`**。
小改动可以跳过 `/plan`，但 `/impact` 和收尾 verify 不可跳过。

## 铁律（详细见 change-safety.md）

- **项目实测事实 > 通用惯例**。项目用 BLogic 就写 BLogic，不"现代化"遗留结构。
- **最小 diff**：不顺手格式化、不重命名、不改无关行。
- 改路由 / public 签名 / SQL 列 / 表结构，必须有式样书或用户明示依据。
- 收尾必跑 `bash ai/tools/verify.sh`（本项目对齐的 build/test），红/绿如实报告。
- 规则标 `[assumed]` 的，按假设行事并显式提示用户确认。
- 测试 fixture 全部合成数据，禁止真实个人信息 / 凭证 / 客户数据。

## 记忆义务

完成一个案件（或踩过坑）后运行 `/remember`：新事实进 `PROJECT-FACTS.md`、
设计取舍进 `ai/kb/decisions/`、踩坑教训进 `ai/kb/lessons.md`、模块知识进 `ai/kb/modules/`。
下次任务开工时，若涉及某模块，先读它的 `ai/kb/modules/<模块>.md`（若存在）。
