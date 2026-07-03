---
description: 按已审的実装方針实装代码（最小 diff + verify 收口）
argument-hint: <ticket编号 或 plan.md 路径>
---

# /implement — 实装

按 `ai/work/$ARGUMENTS/plan.md`（状态须为 `APPROVED`；无方针的小改动须用户明示可直接实装）执行编码。

## 步骤

1. 读方针 + 式样书 + DEF + 各层 examples + `change-safety.md`。
2. 按方针「変更ファイル一覧」逐文件实装：
   - **结构照 DEF**（字段/型/桁/列映射/code 值），**行为照式样书**，**写法照 examples**。
   - 沿本项目真实请求流逐层实现，不跳层、不新增项目没有的层。
   - 新代码在类/方法 Javadoc 或注释中挂 traceability ID，回链式样书条目。
3. 方针未覆盖但实装中发现必须改的文件：**先停下来报告**，更新方针后再继续。
4. 未実装范围只生成骨架并标注 `// TODO 未実装（<式样书条目>）`，不静默留空。

## 收口（不可省略）

1. `git diff --stat` 自查：改动文件是否都在方针清单内？有无越界？
2. 跑 `bash ai/tools/verify.sh`，红/绿如实报告；失败则基于报错最小修复，不顺手改无关区域。
3. 报告：改了什么（按层）、traceability ID、verify 结果、与方针的偏差、遗留风险。

代码完成 ≠ 案件完成：提示用户继续 `/test-design`。
