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
- **ACI 门禁**（领域命令，观察仓库仍用你的原生 Grep/Glob/Read）：开工先 `{{ACI}} state`；改 spec/DEF 前用 `trace <ID>` 算爆炸半径；核查证据引用用 `evidence <path:line>`；收尾必跑 `verify`（本项目对齐的 build/test 一键验证）+ `validate`。
- **DEF 结构契约** 模型：`{{INFRA_DIR}}/universal/defs-model/`；**traceability ID** 机制：`{{INFRA_DIR}}/universal/maps/traceability.md`。
- **对齐产物正本**：`{{INFRA_DIR}}/project/`（事实卡 `PROJECT-FACTS.md`、层规则 `instructions/`、真实样例 `examples/`）。生成代码时对齐 `examples/`。
- **验证纪律**：改动后必须跑 `{{ACI}} verify`（即核心契约命令段固化成的 project verify 脚本）；涉及画面/接口的改动，按对齐规则做端到端验证，不要只靠编译通过。
- 遇到核心契约里标 `[assumed]` 的规则，按假设处理时**显式提示用户需确认**。
- **优先级**：本项目实测事实（核心契约 + PROJECT-FACTS）> 任何通用默认。冲突以前者为准。
