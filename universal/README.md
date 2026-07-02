# universal/ — 免对齐，跨项目复用

这里的内容**不随项目变化**，复制到任何项目都直接用。不要往这里写项目特定事实（那是 `project/` 的活）。

- `prompts/align/` — ★ 对齐流水线 5 步（survey→extract→draft→review→activate）。
- `prompts/workflow/` — 日常工作流（spec→code / →testcases / →data / →junit / code-review）。
- `aci/` — Agent-Computer Interface 约定：给 AI agent 使用的受控搜索、查看、trace、验证接口。
- `rules-templates/` — 规则**模板**（带 `{{占位符}}`）；`/align-draft` 特化进 `project/`。
- `testing/` — 测试 case 格式 + 方针。
- `defs-model/` — DEF 结构契约模型 + YAML 模板。
- `maps/traceability.md` — 稳定 ID 机制。

> 升级这套基础设施 = 改 `universal/`，再到各项目重跑 `/align-draft` + `/align-activate`。
