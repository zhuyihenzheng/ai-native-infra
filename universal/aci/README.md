# Agent-Computer Interface (ACI)

> 本层受 SWE-agent 论文启发：软件工程 agent 不应该只面对裸 shell，而应有一组小而稳定、输出受控、带 guardrail 的接口。

## 为什么需要 ACI

对齐规则告诉 agent **应该怎样写**；ACI 告诉 agent **怎样和仓库交互**。两者缺一不可：

- 对齐规则防止风格和架构跑偏。
- ACI 防止上下文爆炸、误读大文件、无证据改动、验证结果含糊。

SWE-agent 的关键经验是：面向 LM 的接口设计会显著影响软件工程任务表现。这里不复刻 SWE-agent，而是把它的 ACI 原则落到本基础设施：

1. **少量命令**：观察仓库时优先用固定命令，而不是任意拼 shell。
2. **有限输出**：搜索、查看、diff 都默认截断并提示细化查询。
3. **明确反馈**：没有输出也要返回成功消息，避免 agent 把空输出误读成失败。
4. **验证优先**：promote、validate、traceability 都是独立门禁，不靠口头承诺。
5. **编辑不混在观察里**：编辑仍用 agent 原生编辑能力；ACI 负责定位、证据、状态和验证。

## 标准命令

部署后在目标项目根目录使用：

```bash
bash ai-infra/tools/aci.sh state
bash ai-infra/tools/aci.sh find OperationLog
bash ai-infra/tools/aci.sh grep "CommonResult" src/main/java
bash ai-infra/tools/aci.sh view src/main/java/.../Xxx.java 1 100
bash ai-infra/tools/aci.sh trace API0100-API-001
bash ai-infra/tools/aci.sh evidence src/main/java/.../Xxx.java:42
bash ai-infra/tools/aci.sh diff
bash ai-infra/tools/aci.sh promote-check
bash ai-infra/tools/aci.sh validate
```

在模板仓库自身开发时，脚本自动把当前仓库当作 project root。复制进业务项目后（通常命名为 `ai-infra/`，也可改名），脚本自动把 infra 目录的父目录当作 project root。特殊布局可用 `ACI_PROJECT_ROOT=/path/to/project` 覆盖。

项目级 `find` / `grep` / `trace` 默认排除 infra 目录自身，避免把规则文档当成业务代码证据。要检查基础设施文件时，显式传 scope，例如：

```bash
bash ai-infra/tools/aci.sh find aci ai-infra
bash ai-infra/tools/aci.sh grep "ALIGN_STATE" ai-infra/project
```

## 给 agent 的工作循环

1. `state`：确认对齐状态、live 入口、git 状态。
2. `find` / `grep` / `view`：用受控输出定位证据；不要一次性读无关大文件。
3. 原生编辑工具：只改与任务直接相关的文件。
4. `diff`：检查改动是否越界。
5. `validate` + 项目 build/test：用机器结果收口。
6. 结果报告：说明证据、验证命令、剩余风险。

## 论文映射

| SWE-agent ACI 经验 | 本仓库落点 |
|---|---|
| LM-centric commands and feedback | `tools/aci.sh` 固定命令集 |
| File viewer shows bounded windows | `aci.sh view` 默认最多 100 行 |
| Directory search returns concise matches | `aci.sh find/grep/trace` 默认最多 50 条 |
| Guardrails around edits and invalid states | `promote.sh` gate + `validate-ai-docs.sh` + `promote-check` |
| Concise environment feedback every turn | 空输出成功消息、截断提示、证据行检查 |

参考：Yang et al., “SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering”, NeurIPS 2024 / arXiv:2405.15793.
