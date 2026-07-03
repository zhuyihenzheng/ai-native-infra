---
description: 测试 case → 本项目风格的可执行测试（JUnit/MockMvc/Mapper test）
argument-hint: <ticket编号>
---

# /impl-tests — 测试实装

把 `ai/work/$ARGUMENTS/testcases.md` 实装成可执行测试。

## 步骤

1. 读测试 case + `ai/kb/examples/` 里的测试样例 + PROJECT-FACTS 的测试现状段
   （框架 JUnit4/5、Mock 方式、测试数据准备方式、命名——**照项目现状，不引入新测试栈**）。
2. 逐 case 实装：
   - 一条 case = 一个测试方法 = 一个断言主题。
   - 方法名或 `@DisplayName` 嵌 traceability ID（如 `SCR0100_SCREEN_001_必須チェック`）。
   - fixture 按项目既有约定放置（testdata 目录 / `@Sql` / builder——见事实卡）；**全合成数据**。
   - DB fixture 若由 seed 生成，改 seed 脚本，不手改生成产物。
3. case 无法自动化时（目视确认、外部系统依赖）：在 testcases.md 该条标注「手動」，不硬写假测试。

## 收口

跑本项目测试命令（`bash ai/tools/verify.sh` 或事实卡记录的单模块命令），
红/绿如实报告；失败先判断是**测试写错**还是**实装缺陷**再动手，不为凑绿弱化断言。
