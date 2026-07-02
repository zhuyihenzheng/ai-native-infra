# AI Native Dev Infrastructure — *alignment-first*

**English** | [简体中文](README.zh-CN.md)

> A tool-neutral scaffold that lets **Claude Code**, **GitHub Copilot**, and **Codex** modify an **existing** Java / Spring Boot / MyBatis codebase **without drifting from that codebase's real conventions**.
>
> 一套**工具中立**的 AI 开发基础设施：先让 AI 和已有项目**对齐**，再让 `copilot-instructions.md` 之类的规则生效——避免"规则是模板的假设、代码是项目的事实"导致 AI 跑偏。

<p align="left">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
  <img alt="Tools" src="https://img.shields.io/badge/agents-Claude%20Code%20%7C%20Copilot%20%7C%20Codex-6f42c1">
  <img alt="Stack" src="https://img.shields.io/badge/target-Spring%20Boot%20%2B%20MyBatis-6db33f">
</p>

---

## The problem

Generic AI instruction files (`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`) encode **assumptions** — "use a Service layer", "REST controllers", "camelCase entities". A real brownfield project encodes **facts** — maybe it uses `BLogic`, XML mappers, screen-named routes, a legacy base class. Turn the generic rules on before reconciling the two and every AI edit fights the codebase.

**This repo's answer:** the AI instruction files are not hand-written and not turned on by default. They are **built** from your project's *measured facts* by a short alignment pipeline, and only then activated.

## Core idea: `source → align → build`

```
universal/   (reusable, never edited per-project) ─┐
project/     (this project's aligned facts)        ─┼─ promote.sh ─▶  LIVE entry files (build artifacts)
_staging/    (drafts awaiting human review)        ─┘                  ./CLAUDE.md  ./AGENTS.md
                                                                       .github/copilot-instructions.md
                                                                       .github/instructions/*.instructions.md
```

- **Staging area = the `ai-infra/` subfolder.** Tools do **not** read it. The template can sit inside your project without affecting anything.
- **Live area = project root `CLAUDE.md`/`AGENTS.md` + `.github/`.** Tools read this. **Only `promote.sh` writes here**, and it **refuses** unless alignment is finished (`ALIGN_STATE: aligned`).
- Entry files are **artifacts**, not sources. Change a rule → edit `universal/` or `project/` → re-run `promote.sh`. (Because Copilot can't `import`, assembling from one source keeps all three tools consistent without copy-paste drift.)

## Quickstart

```bash
# 1. Drop the template into an existing project (as an inert subfolder)
cp -r ai-native-infra  /path/to/your-project/ai-infra

# 2. Run the 5-step alignment pipeline with any of the three agents
/align-survey     # read real code → project/PROJECT-FACTS.md   (every fact cites file:line)
/align-extract    # lift golden examples from real code → project/examples/
/align-draft      # specialize universal rule templates → _staging/ drafts
/align-review     # tag confirmed / assumed; you only vet the "assumed" items
/align-activate   # promote.sh assembles & enables the live entry files

# Agent-facing gates: state at task start, verify (aligned build/test) at task end
bash ai-infra/tools/aci.sh state
bash ai-infra/tools/aci.sh verify

# Windows (no Git Bash needed): .cmd wrappers embed -ExecutionPolicy Bypass,
# avoiding "not digitally signed" execution-policy errors (GPO AllSigned aside)
#   ai-infra\tools\aci.cmd state
#   ai-infra\activate\promote.cmd
# Troubleshooting (Unblock-File, GPO AllSigned): see universal/aci/README.md

# Template maintainers can run the deployed-mode smoke suites
bash tools/smoke-aci.sh
pwsh -NoProfile -File tools/smoke-aci.ps1
```

Before activation your project's existing `.github/copilot-instructions.md` (if any) is left untouched; `promote.sh` **backs it up** before writing.

## How the three agents plug in (after alignment)

| Agent | Reads | `promote.sh` assembles |
|---|---|---|
| **Claude Code** | root `CLAUDE.md` | core contract + pointers to `ai-infra/universal/prompts` workflows + Claude-specific notes (subagents, verification discipline) |
| **Codex** | root `AGENTS.md` | the same core contract as a constitution + commands + safety |
| **GitHub Copilot** | `.github/copilot-instructions.md` (thin) + `.github/instructions/*.instructions.md` (path-scoped) + `.github/prompts/` | condensed contract + per-layer rules + workflow prompt files, and flips `useInstructionFiles` on in `.vscode/settings.json` |

All three share **one** core contract (`project/aligned-rules.md`) — assembled, never hand-copied.

Only using one of them? `promote.sh --tools=copilot` (Windows: `promote.cmd -Tools copilot`) generates just that tool's files and leaves the others untouched.

## What it supports

- **Agent-Computer Interface (ACI)** — SWE-agent-inspired **domain gates** the agent's harness cannot provide natively: alignment state, one-command project verification (`aci.sh verify` → `project/verify.sh`), doc governance, traceability blast-radius search, and evidence checks. Observation stays on the agent's native tools; `find/grep/view` are kept only as bounded fallbacks for shell-only contexts. See `universal/aci/`.
- **DEF ベース development** — machine-readable *structure* contracts (DB / screen / API / code / message definitions as YAML) that deterministically drive entity, mapper, form, validation, and boundary-test generation. See `universal/defs-model/`.
- **式様書 (spec)-driven development** — human-readable *behavior* contracts drive routing, business flow, screen transitions, and behavior tests.
- **Traceability** — stable `{TARGET}-{TYPE}-{NUMBER}` IDs link DEF/spec → test case → executable test → fixture, so an agent can compute the blast radius of any change.
- **Workflows** — `aci-task-loop`, `spec-to-code`, `spec-to-testcases`, `testcases-to-data`, `testcases-to-junit`, `code-review` (in `universal/prompts/workflow/`).

## Anti-drift guardrails

- **Evidence required** — every architectural/naming claim in `PROJECT-FACTS.md` must cite a real `path:line`; `tools/validate-ai-docs.sh` checks those paths exist.
- **Confidence tags** — each rule is `[confirmed]` (code-backed) or `[assumed]` (template default, needs sign-off); agents flag `assumed` when they rely on it.
- **Precedence** — *measured project facts > generic template defaults*, stated explicitly.
- **Activation gate** — `promote.sh` refuses unless `ALIGN_STATE: aligned`, refuses to run against a non-Java directory, and always backs up existing config first.
- **Machine-run verification** — `tools/aci.sh verify` runs the build/test command captured during alignment (`project/verify.sh`) with bounded output and an explicit ✓/✗, so "it builds" comes from the machine, not from the agent's prose.

## Layout

```
ai-native-infra/
├── universal/            # reusable, no alignment needed
│   ├── prompts/align/     #   ★ the 5-step alignment pipeline
│   ├── prompts/workflow/  #   spec→code / →testcases / →data / →junit / code-review
│   ├── aci/               #   Agent-Computer Interface guidance
│   ├── rules-templates/   #   rule templates with {{placeholders}}
│   ├── testing/  defs-model/  maps/traceability.md
├── project/              # ★ per-project alignment output (starts as placeholders)
│   ├── PROJECT-FACTS.md  aligned-rules.md  ALIGN-STATUS.md
│   ├── instructions/  examples/
├── _staging/             # review buffer
├── activate/             # entry-file shells (*.tpl) + promote.sh + settings snippet
└── tools/validate-ai-docs.sh  aci.sh  smoke-aci.sh   (+ .ps1 twins for Windows)
```

**Windows:** `aci.ps1` / `validate-ai-docs.ps1` / `promote.ps1` mirror the shell scripts and run on stock Windows PowerShell 5.1. `promote` expands the `{{ACI}}` placeholder in entry-file templates to the OS-appropriate invocation, so entry files always show runnable commands — re-run the matching promote after switching OS. The per-project verification entry is likewise a pair: `project/verify.sh` / `project/verify.ps1`.

## New project vs. existing project

Each project gets its **own** `project/` (its own facts). A new project = copy the template again and re-run the pipeline. Nothing is shared except `universal/`, so alignments never collide.

## Language

Rule/spec content is authored in **Chinese/Japanese** (the target audience is Japanese-enterprise SIer teams doing DEF ベース / 式様書 development). This README is English for discoverability; the mechanism is language-agnostic.

## Research note

The ACI layer is informed by [SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering](https://arxiv.org/abs/2405.15793) — applied selectively. The paper's *observation* lessons (bounded file views, concise search) are already built into the native tools of 2026 agent harnesses (Claude Code / Codex / Copilot), so this repo does **not** ask agents to route observation through wrappers; that would be a de-optimization. What this repo takes from the paper is the other half: agent-facing interfaces should offer a small set of deterministic, domain-specific actions with explicit feedback and guardrails around invalid states — here that means alignment gates, traceability/evidence checks, and one-command verification, applied to brownfield alignment and enterprise Java workflows rather than vendoring SWE-agent itself.

## License

[MIT](LICENSE).
