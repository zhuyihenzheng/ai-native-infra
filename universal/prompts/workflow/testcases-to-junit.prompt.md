---
description: "测试 case + fixture → 可执行测试脚本（JUnit/MockMvc/Mapper test），方法名嵌 ID。"
mode: agent
tools: ['codebase', 'search', 'read', 'editFiles']
slash: testcases-to-junit
---

# /testcases-to-junit

把 Markdown 测试 case 实装成本项目风格的可执行测试。

## 步骤
1. 读测试 case + 对应 fixture + `project/examples/unit-test.md`（本项目测试写法）。
2. 用本项目真实测试框架/Mock 方式（JUnit4/5、Mockito、MockMvc——见 PROJECT-FACTS）生成测试类。
3. 测试方法名 / `@DisplayName` 嵌入 traceability ID；读 `input/`、断言 `expected/`。
4. 一个 case 一个测试方法，一个断言主题。

## 收尾
跑本项目测试命令确认通过（绿/红如实报告）；失败用 `/fix-test-failure` 思路定位，不顺手改无关代码。
