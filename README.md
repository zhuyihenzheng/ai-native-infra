# AI Native Java 开发工作台

一套可复制进任何既存 Java 项目的 AI 开发工作台，面向 **Java / Spring Boot / MyBatis / 日本 SI 式样书驱动开发**。
让 Claude Code、Codex、GitHub Copilot 在既存企业系统上做到：理解项目 → 调查影响 → 读式样书 → 出实装方针 → 改代码 → 出测试观点与 case → review → **沉淀项目记忆**。

## 设计原则

1. **对齐先行**：AI 的一切产出对齐「本项目实测事实」，不对齐通用惯例。事实带 `路径:行号` 证据，无证据标 `[assumed]` 留人裁决。
2. **结构与行为分离**：DEF（YAML 定义 = 结构契约）决定字段/型/桁/列映射，AI 照抄；式样书（= 行为契约）决定流程/异常/遷移，AI 判断。
3. **人卡在关口，不卡在过程**：人只在三个点介入——对齐裁决、実装方針承认、review 定夺；其余步骤 AI 自走。
4. **记忆是闭环不是文档**：`/remember` 把每个案件的经验分拣进知识库，review 高频指摘会升级成规则；记忆有保洁规则，不无限膨胀。
5. **一份正本，三工具共享**：规则与流程只写一遍（`ai/` + `.claude/commands/`），三个工具的入口文件都是薄指针——没有装配脚本，没有生成产物，改了立即生效。

## 目录结构

```
CLAUDE.md                    # Claude Code 入口（薄：读什么、闸门、命令表、铁律）
AGENTS.md                    # Codex / 通用代理入口（同源精简版）
.github/
├── copilot-instructions.md  # Copilot 入口（薄）
├── instructions/            # Copilot 分层规则（/onboard 按真实包路径生成）
└── prompts/                 # Copilot slash（薄指针 → .claude/commands/）
.claude/
├── agents/                  # 子代理：code-analyst / test-designer / code-reviewer
└── commands/                # 8 个工作流命令（工具中立的流程正本）
ai/
├── kb/                      # ★ 项目记忆（知识库）
│   ├── PROJECT-FACTS.md     #   事实卡（带证据，/onboard 填充）
│   ├── rules/               #   core-contract（对齐填充）· change-safety（免对齐）· mybatis
│   ├── examples/            #   各层 golden example（从真实代码摘）
│   ├── decisions/           #   设计取舍记录（ADR-lite）
│   ├── modules/             #   模块笔记（状态机/隐藏前提/慎动点）
│   └── lessons.md           #   踩坑教训（review 必读，有保洁规则）
├── specs/
│   ├── templates/           #   機能設計書 · 変更設計書 模板
│   └── def/                 #   DEF 结构契约（YAML 模板：table/screen/api）
├── testing/                 #   观点目录 · case 格式 · traceability ID 机制
├── review/checklist.md      #   review 走查清单
├── tools/verify.sh          #   一键验证（对齐时固化本项目 build/test 命令）
└── work/<ticket>/           #   案件工作区（impact / plan / testcases）
```

## 使用流程

**导入（一次）**：把 `CLAUDE.md`、`AGENTS.md`、`.claude/`、`.github/` 下三件、`ai/` 复制进目标项目根
（目标已有同名入口文件时手动合并，`/onboard` 会检测并提示）。然后运行 **`/onboard`**：
AI 勘探事实 → 摘各层真实样例 → 特化核心契约 → **逐条向你裁决 `[assumed]` 项** → 固化 verify.sh 并生效。

**每个案件**：

```
式样书（用 ai/specs/templates/ 起草，或读既有定义书）
   │
   ▼
/impact   影响调查（code-analyst 代理，带证据的影响范围报告）
   ▼
/plan     実装方針書 → ai/work/<ticket>/plan.md   ← ★ 人 review 承认
   ▼
/implement  按方针实装：结构照 DEF、行为照式样书、写法照 examples；verify 收口
   ▼
/test-design → /impl-tests   观点走查 → 测试 case → 项目风格 JUnit
   ▼
/review   checklist 走查 + 严重度指摘                ← ★ 人定夺
   ▼
/remember  经验分拣进 kb（事实/决策/教训/模块笔记）
```

小改动可跳过 `/plan`；`/impact` 与 verify 收口不可跳。

## 关键决策与理由

- **子代理只设三个，且分工按「上下文形态」而非「职能全覆盖」**：影响调查（海量只读检索，sonnet 降本）、测试展开（机械走查观点目录，sonnet）、review（需要判断力，继承主模型）。实装方针和编码留在主线程——它们需要与人交互，切子代理只会丢上下文。
- **命令文件 = 工具中立的流程正本**：`.claude/commands/*.md` 同时是 Claude 的 slash、Codex 的流程说明书（AGENTS.md 指过去）、Copilot 的 prompt 指针目标。一份维护，三处生效。
- **不用装配/promote 机器**：前身方案用脚本把规则装配进入口文件（附 Windows 镜像脚本，约 1300 行）。本版入口文件天生是薄指针，规则改动即时生效，维护面缩到一个 40 行的 verify.sh。对齐闸门由 shell 检查改为事实卡状态行（`PLACEHOLDER` → 禁止生成业务代码），对 2026 年的 agent 而言 prose 闸门足够可靠，且人可直读。
- **记忆分四层**：稳定事实（事实卡）、硬规则（rules/）、经验（lessons/decisions/modules）、案件过程产物（work/，可丢弃）。生命周期不同的信息不混放，这是记忆能长期保鲜的前提。
- **変更設計書与機能設計書分开**：既存改修的核心是「変更前/変更後/影響範囲/回帰観点」，与新規功能的文档形态完全不同——这正是多数 AI 工作流对 brownfield 失效的原因。

## 安全底线（摘要，全文见 `ai/kb/rules/change-safety.md`）

影响调查先行 · 改公开面必须有式样书依据 · 最小 diff 不夹带重构 · 禁批量脚本重写 ·
MyBatis 禁 `${}` · fixture 全合成数据 · verify 机器收口 · `[assumed]` 与破坏性操作停下问人。

## License

[MIT](LICENSE)
