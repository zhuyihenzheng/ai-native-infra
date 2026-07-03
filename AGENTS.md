# AGENTS.md — Codex / 通用编码代理入口

本项目使用 AI Native Java 工作台（Java / Spring Boot / MyBatis / 式样书驱动的既存系统改修）。
本文件与根 `CLAUDE.md` 同源同则；此处为通用代理的精简版。

## 必读（按顺序）

1. `ai/kb/rules/core-contract.md` — 核心契约
2. `ai/kb/rules/change-safety.md` — 既存代码修改安全规则（最高优先级）
3. `ai/kb/PROJECT-FACTS.md` — 项目事实卡（带证据）
4. 写某层代码前看 `ai/kb/examples/` 对应样例

`PROJECT-FACTS.md` 状态为 `PLACEHOLDER` 时项目未对齐：先按 `.claude/commands/onboard.md` 的流程对齐，不要直接生成业务代码。

## 工作流程序书

`.claude/commands/*.md` 是工具中立的**流程说明书**，不是 Claude 专属。按场景直接照做：

- 对齐：`onboard.md` · 影响调查：`impact.md` · 实装方针：`plan.md`
- 实装：`implement.md` · 测试设计：`test-design.md` / `impl-tests.md`
- review：`review.md` · 记忆沉淀：`remember.md`

## 铁律

- 项目实测事实 > 通用惯例；贴合现状，不擅自现代化。
- 最小 diff；不改无关行；不做与任务无关的格式化/重命名。
- MyBatis 禁 `${}` 拼接（白名单排序列除外）；规则见 `ai/kb/rules/mybatis.md`。
- 收尾必跑 verify：macOS/Linux `bash ai/tools/verify.sh`，Windows `ai\tools\verify.cmd`。如实报告红/绿。
- `[assumed]` 规则要提示用户确认；fixture 全合成数据。
