# Agent-Computer Interface (ACI)

> 本层受 SWE-agent 论文启发，但**不照搬**。论文教训要分两半看，只有一半适合落在本基础设施这一层。

## 论文教训的正确切分

SWE-agent（Yang et al., NeurIPS 2024）的结论是给 **harness 构建者**的：当 agent 面对裸 shell 时，LM-friendly 命令、有界输出、明确反馈能显著提升软件工程表现。

但本基础设施不是 harness——它是被 Claude Code / Codex / Copilot 这些**成熟 harness 消费的配置层**。到 2026 年，这些 harness 的原生工具（有界读取、行号、截断提示、快速仓库搜索）已经内置了论文的全部 *observation* 教训。在配置层重造一套 find/grep/view 并要求 agent「优先使用」，只会把 agent 从优化过的原生工具推向更慢的 shell 子进程——这是反优化。

论文教训在**配置层**的正确落点是另一半：**给 agent 提供 harness 不可能自带的、领域特定的确定性动作和验证门禁**，并保证它们输出受控、反馈明确。

## 两类命令

### 门禁类（本层的主体价值——harness 原生没有）

```bash
bash ai-infra/tools/aci.sh state           # 对齐状态 + live 入口文件 + git 一览
bash ai-infra/tools/aci.sh verify          # ★ 一键跑本项目对齐的 build/test（project/verify.sh）
bash ai-infra/tools/aci.sh validate        # 文档治理校验（证据路径/占位符/泄漏粗检）
bash ai-infra/tools/aci.sh promote-check   # 生效门禁 dry-run
bash ai-infra/tools/aci.sh trace API0100-API-001            # traceability 爆炸半径
bash ai-infra/tools/aci.sh evidence src/.../Xxx.java:42     # 证据引用核查
bash ai-infra/tools/aci.sh diff            # 改动越界检查
```

`verify` 是收口命令：对齐流水线把 PROJECT-FACTS 里勘探到的构建/测试命令**固化成可执行的** `project/verify.sh`（含 JDK 选择等本机事实），agent 收尾时一条命令得到确定的 ✓/✗，失败只回显有界尾部输出。「构建命令写成 prose」不算 AI-native；「机器可执行 + 反馈受控」才算。

### 观察类（仅作 fallback）

```bash
bash ai-infra/tools/aci.sh find OperationLog
bash ai-infra/tools/aci.sh grep "CommonResult" src/main/java
bash ai-infra/tools/aci.sh view src/main/java/.../Xxx.java 1 100
```

**有原生搜索/读取工具的 agent（Claude Code、Codex、Copilot agent mode）不要用这些**，用原生工具更快、更省上下文。它们只服务 shell-only 的弱环境（CI 里的裸脚本 agent、无工具的对话式使用），输出同样有界、空结果显式返回成功。

## Windows

每个脚本都有同名 PowerShell 版（`aci.ps1` / `validate-ai-docs.ps1` / `promote.ps1`），兼容 Windows 自带的 PowerShell 5.1（UTF-8 BOM，不依赖 pwsh 7）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ai-infra/tools/aci.ps1 state
powershell -NoProfile -ExecutionPolicy Bypass -File ai-infra/tools/aci.ps1 verify
```

约定：
- 入口文件里的 ACI 调用形式由 promote 按**运行 promote 的 OS** 展开（`{{ACI}}` 占位符）：macOS/Linux 跑 `promote.sh` 得到 `bash .../aci.sh`，Windows 跑 `promote.ps1` 得到 `powershell -File .../aci.ps1`。**换 OS 后重跑对应 promote 重新装配**。
- 验证入口同理成对：`project/verify.sh`（macOS/Linux）/ `project/verify.ps1`（Windows）。`aci.ps1 verify` 优先跑 `verify.ps1`，没有时若装了 Git Bash 会回退跑 `verify.sh`。
- 装了 Git Bash 的 Windows 机器也可以直接用 `.sh` 全家（`bash ai-infra/tools/aci.sh ...`），两条路等价。

## 部署与作用域

在模板仓库自身开发时，脚本自动把当前仓库当作 project root。复制进业务项目后（通常命名为 `ai-infra/`，也可改名），脚本自动把 infra 目录的父目录当作 project root。特殊布局可用 `ACI_PROJECT_ROOT=/path/to/project` 覆盖。

项目级 `find` / `grep` / `trace` 默认排除 infra 目录自身，避免把规则文档当成业务代码证据。要检查基础设施文件时，显式传 scope：

```bash
bash ai-infra/tools/aci.sh grep "ALIGN_STATE" ai-infra/project
```

## 给 agent 的工作循环

1. `state`：确认对齐状态、live 入口、git 状态。
2. **原生工具**定位证据（Grep/Glob/Read 等）；改 spec/DEF 时先 `trace <ID>` 算爆炸半径。
3. 原生编辑工具：只改与任务直接相关的文件。
4. `diff`：检查改动是否越界。
5. `verify` + `validate`：用机器结果收口，不靠口头承诺。
6. 结果报告：说明证据、验证命令、剩余风险。

## 论文映射（修正后）

| SWE-agent ACI 经验 | 2026 年的归属 |
|---|---|
| Bounded file viewer / concise search | **harness 原生工具已内置**——本层不重复，仅留 shell-only fallback |
| LM-centric commands and feedback | `aci.sh` 门禁命令集：固定动作、✓/✗ 明确反馈、空输出显式成功 |
| Guardrails around invalid states | `promote.sh` gate + `promote-check` + `validate` + `evidence` |
| One-command, deterministic verification | `aci.sh verify` → 对齐时固化的 `project/verify.sh` |

参考：Yang et al., "SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering", NeurIPS 2024 / arXiv:2405.15793.
