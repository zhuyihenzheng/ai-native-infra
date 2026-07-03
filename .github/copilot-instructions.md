# Copilot Instructions

本项目使用 AI Native Java 工作台（Java / Spring Boot / MyBatis / 式样书驱动的既存系统改修）。

## 核心规则

- **项目实测事实 > 通用惯例**：核心契约在 `ai/kb/rules/core-contract.md`，项目事实在 `ai/kb/PROJECT-FACTS.md`。项目实际怎么写就怎么写，不"现代化"遗留结构。
- 生成某层代码前，参照 `ai/kb/examples/` 该层的真实样例。
- **最小 diff**：不顺手格式化、不重命名、不改无关行。
- 改路由 / public 签名 / SQL 列 / 表结构，必须有式样书或用户明示依据。
- MyBatis：强制 `#{}` 绑定，禁止 `${}` 拼接（白名单排序列除外）；XML 与接口对应关系遵守 `ai/kb/rules/mybatis.md`。
- 测试 fixture 全部合成数据，禁止真实个人信息 / 凭证 / 客户数据。
- 改动收尾运行 `bash ai/tools/verify.sh`，如实报告结果。

## 分层规则与工作流

- 各层 path-scoped 规则：`.github/instructions/*.instructions.md`（`/onboard` 对齐时按本项目真实包路径生成）。
- 可复用工作流：`.github/prompts/`（薄指针，正本在 `.claude/commands/`，内容工具中立）。
- 修改既存代码的完整安全规则：`ai/kb/rules/change-safety.md`。
