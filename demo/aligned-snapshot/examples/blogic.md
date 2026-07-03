# Golden Example — 业务层（BLogic）

> 取自 src/main/java/com/example/order/blogic/OrderSearchBLogic.java。生成新 BLogic 对齐此样式。

## 关键约定（从样本归纳）

- 类名 `XxxBLogic`，`@Component`，继承 `AbstractBLogic<入参, 结果>`，业务写在 `doExecute`
- 入参直接用画面 Form；**总件数写回 Form**（`form.setTotalCount`）
- 排序列先经 `CodeConst.SORT_WHITELIST` 解析再进 SQL；分页由 BLogic 算 limit/offset
- 業務エラー返回 `BLogicResult.warn(messageId, ...)`；不抛异常（基类兜底系统错误）
- 注释头回链式样书路径与 traceability ID

## 样例

```java
// src/main/java/com/example/order/blogic/OrderSearchBLogic.java:17-45
@Component
public class OrderSearchBLogic extends AbstractBLogic<Scr0201Form, List<Order>> {

    @Autowired
    OrderMapper orderMapper;

    @Override
    protected BLogicResult<List<Order>> doExecute(Scr0201Form form) {
        // ソート列はホワイトリストで解決。リスト外・未指定はデフォルト列（SCR0201-SCREEN-004）
        String column = CodeConst.SORT_WHITELIST.get(form.getSortKey());
        form.setSortColumn(column != null ? column : CodeConst.DEFAULT_SORT_COLUMN);

        // ページング計算（1始まりページ番号 → OFFSET）
        int pageNo = form.getPageNo() < 1 ? 1 : form.getPageNo();
        form.setLimit(CodeConst.PAGE_SIZE);
        form.setOffset((pageNo - 1) * CodeConst.PAGE_SIZE);

        int total = orderMapper.countByCondition(form);
        form.setTotalCount(total);

        // 0件は業務警告（SCR0201-SCREEN-E01）
        if (total == 0) {
            return BLogicResult.warn("msg.scr0201.w001", null);
        }

        List<Order> list = orderMapper.selectByCondition(form);
        return BLogicResult.ok(list);
    }
}
```
