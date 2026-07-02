# Copilot Instructions

> 由 `ai-infra/activate/promote.sh` 装配生成。理想情况下应使用 `ai-infra/project/copilot-instructions.md` 的薄版；本文件为兜底（直接附完整核心契约）。

GitHub Copilot 在本项目工作时遵守下方"核心契约"。详细的各层规则会通过 `.github/instructions/*.instructions.md` 按你正在编辑的文件**自动注入**；可复用任务在 `.github/prompts/`。

**最高优先级**：本项目实测事实 > 通用默认。标 `[assumed]` 的规则需人确认。

机器门禁：任务开始运行 `{{ACI}} state`，结束前运行 `verify`（本项目对齐的 build/test）与 `validate`；`trace`/`evidence` 用于溯源与证据核查。仓库观察用你的原生工具即可。

---
（核心契约见下）
