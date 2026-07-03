# examples/ — 本项目 golden examples（待对齐）

由 `/onboard` 从**本项目真实代码**摘取。AI 生成新代码时对齐这些样式，而非通用模板。

对齐后按项目实际存在的层各一份（每份含「关键约定归纳」+ 带 `路径:行号` 的真实代码摘录）：

- `controller.md`（或 action）· `service.md`（或 blogic）· `mapper.md`（接口 + XML，重点层）
- `entity.md` · `exception.md` · `test.md`
- `bad-patterns.md` — 项目里存在但**不该模仿**的旧写法及理由（若有）

铁律：样例来自真实文件，不许编造、不许"美化"；允许删节但标 `// …略` 并保留出处。
