# legacy-order — 工作台验证靶场

一个**刻意做旧**的受注管理迷你项目，用来实测/演示本工作台的对齐能力。不是最佳实践示范——恰恰相反，
它浓缩了真实日本 SI 遗留系统的典型形态：

| 遗留特征 | 位置 |
|---|---|
| BLogic 模式 + 模板方法基类（无 Service 层） | `blogic/AbstractBLogic.java` |
| 画面 ID 路由（`/scr0201/*`）、Controller 直调 BLogic | `web/Scr0201Controller.java` |
| Mapper XML 放 `sqlmap/`（非常见的 `mapper/`） | `resources/sqlmap/` |
| 列↔字段不规则映射（`STATUS` → `statusCode`） | `OrderMapper.xml` resultMap |
| `${}` 排序列 + Java 侧白名单 | `OrderMapper.xml` + `CodeConst` |
| 手写 LIMIT/OFFSET 分页、总件数写回 Form | `OrderSearchBLogic.java` |
| JUnit4 + 手写 stub（无 Mockito）、SqlSessionFactory 直建 | `src/test/` |
| 字符串拼接 SQL 的旧 DAO（模仿禁止的坏样例） | `dao/OrderCsvDao.java` |

配套：式样书 `docs/spec/SCR0201_受注一覧照会.md` + DEF `docs/def/`（含 traceability ID）。

## 怎么用

1. **看对齐应该产出什么**：`../aligned-snapshot/` 是对本项目跑完 `/onboard` 的标准产出（事实卡、核心契约、样例摘录）。
2. **实测工作台**：把工作台文件（`CLAUDE.md`、`.claude/`、`ai/`）复制进本目录，运行 `/onboard`，与 snapshot 对比——事实卡应识别出上表所有遗留特征，`bad-patterns` 应抓到 `OrderCsvDao`。
3. **实测工作流**：改一条式样书（例：把 0 件从警告改为错误），走 `/impact → /plan → /implement → /test-design → /impl-tests → /review` 全链路。

## 构建

```bash
mvn test    # JUnit4 × 11 件（Mapper 単体 5 + BLogic 単体 6）
```
