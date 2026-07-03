package com.example.order.blogic;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.example.order.common.CodeConst;
import com.example.order.dao.OrderMapper;
import com.example.order.entity.Order;
import com.example.order.form.Scr0201Form;

/**
 * SCR0201 受注一覧検索 BLogic。
 * 仕様: docs/spec/SCR0201_受注一覧照会.md（SCR0201-SCREEN-001 / E01）
 */
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
