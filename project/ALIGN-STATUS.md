# ALIGN STATUS

<!-- ALIGN_STATE: not-aligned -->

> ↑ 上面这行注释是**机器闸门**：`promote.sh` 只认 `ALIGN_STATE: aligned`。
> 人类可读状态：NOT-ALIGNED。
> 只有当对齐定稿、待确认清单清空后，由 `/align-review` 把该标记改成 `<!-- ALIGN_STATE: aligned -->`，才允许 promote 生效。

## 流水线进度

- [ ] survey   — `/align-survey`（产出 PROJECT-FACTS.md）
- [ ] extract  — `/align-extract`（产出 examples/）
- [ ] draft    — `/align-draft`（产出 _staging/ 草稿）
- [ ] review   — `/align-review`（定稿到 project/，清空待确认）
- [ ] activate — `/align-activate`（promote 生效）

## 待用户确认清单（assumed / conflict）

> 对齐过程中所有"无代码证据的假设"和"与代码矛盾的点"登记在此。
> 清单非空 → 状态不得置为 aligned。

_（尚未开始对齐）_
