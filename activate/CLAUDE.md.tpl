# CLAUDE.md

> 本文件由 `ai-infra/activate/promote.sh` 装配生成。**请勿手改**——改 `ai-infra/project/aligned-rules.md` 源后重跑 promote。

Claude Code 在本项目工作时的入口。先读下方"核心契约"（本项目对齐规则），再按需取用工作流。

## Claude 专属

- **工作流 prompts**（slash / 按需读取，不常驻）：`{{INFRA_DIR}}/universal/prompts/workflow/`
  - ACI 任务循环：`aci-task-loop.prompt.md`
  - 式样书→代码：`spec-to-code.prompt.md`
  - 式样书→测试 case：`spec-to-testcases.prompt.md`
  - 测试 case→数据：`testcases-to-data.prompt.md`
  - 测试 case→JUnit：`testcases-to-junit.prompt.md`
  - 自审：`code-review.prompt.md`
- **ACI 命令**：优先用 `bash {{INFRA_DIR}}/tools/aci.sh state/find/grep/view/trace/diff/validate` 获取受控反馈；不要用无界 `cat`/大范围 `grep` 填满上下文。
- **DEF 结构契约** 模型：`{{INFRA_DIR}}/universal/defs-model/`；**traceability ID** 机制：`{{INFRA_DIR}}/universal/maps/traceability.md`。
- **对齐产物正本**：`{{INFRA_DIR}}/project/`（事实卡 `PROJECT-FACTS.md`、层规则 `instructions/`、真实样例 `examples/`）。生成代码时对齐 `examples/`。
- **验证纪律**：改动后必须跑本项目的 build/test（见核心契约的命令段）；涉及画面/接口的改动，按对齐规则做端到端验证，不要只靠编译通过。
- 遇到核心契约里标 `[assumed]` 的规则，按假设处理时**显式提示用户需确认**。
- **优先级**：本项目实测事实（核心契约 + PROJECT-FACTS）> 任何通用默认。冲突以前者为准。
