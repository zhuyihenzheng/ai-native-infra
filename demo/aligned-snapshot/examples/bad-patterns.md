# Bad Patterns — 存在但禁止模仿的旧写法

## 1. 字符串拼接 SQL（OrderCsvDao）

```java
// src/main/java/com/example/order/dao/OrderCsvDao.java:31-32
String sql = "SELECT ORDER_NO, CUSTOMER_NAME, AMOUNT FROM T_ORDER"
        + " WHERE STATUS = '" + statusCode + "' ORDER BY ORDER_NO";
```

- **为什么别学**：SQL 注入面；绕过 Mapper 层（列映射/条件不走 resultMap 与 `<sql>` 共用片段）。
- **现状**：其他系统联携批处理依赖此类，冻结中（类头注释有明示）。**新代码一律走 Mapper XML + `#{}`。**
- 若式样书要求改修此类，先 `/impact` 查批处理依赖，并列为高风险项请用户裁决。
