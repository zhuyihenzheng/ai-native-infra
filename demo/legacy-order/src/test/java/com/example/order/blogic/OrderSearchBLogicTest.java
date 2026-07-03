package com.example.order.blogic;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import java.util.ArrayList;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.example.order.dao.OrderMapper;
import com.example.order.entity.Order;
import com.example.order.form.Scr0201Form;

/**
 * OrderSearchBLogic 単体テスト。Mapper は手書きスタブで差し替える（本システムは Mockito を使わない）。
 */
public class OrderSearchBLogicTest {

    private OrderSearchBLogic blogic;
    private int stubCount;
    private List<Order> stubList;
    private boolean throwOnCount;

    @Before
    public void setUp() {
        blogic = new OrderSearchBLogic();
        stubCount = 0;
        stubList = new ArrayList<Order>();
        throwOnCount = false;
        // 手書きスタブ（同一パッケージのため package-private フィールドに直接代入）
        blogic.orderMapper = new OrderMapper() {
            @Override
            public int countByCondition(Scr0201Form condition) {
                if (throwOnCount) {
                    throw new RuntimeException("DB障害を模擬");
                }
                return stubCount;
            }

            @Override
            public List<Order> selectByCondition(Scr0201Form condition) {
                return stubList;
            }

            @Override
            public Order selectByKey(String orderNo) {
                return null;
            }
        };
    }

    /** SCR0201-SCREEN-001: 検索結果ありは OK、総件数がフォームに書き戻される */
    @Test
    public void scr0201_screen_001_検索結果あり_OK() {
        stubCount = 3;
        stubList.add(new Order());

        Scr0201Form form = new Scr0201Form();
        BLogicResult<List<Order>> result = blogic.execute(form);

        assertEquals(BLogicResult.STATUS_OK, result.getStatus());
        assertEquals(3, form.getTotalCount());
        assertEquals(1, result.getData().size());
    }

    /** SCR0201-SCREEN-E01: 0件は警告 msg.scr0201.w001 */
    @Test
    public void scr0201_screen_e01_検索結果0件_警告() {
        stubCount = 0;

        BLogicResult<List<Order>> result = blogic.execute(new Scr0201Form());

        assertEquals(BLogicResult.STATUS_WARN, result.getStatus());
        assertEquals("msg.scr0201.w001", result.getMessageId());
        assertNull(result.getData());
    }

    /** SCR0201-SCREEN-004: 不正ソートキーはデフォルト列 ORDER_NO に解決（ホワイトリスト） */
    @Test
    public void scr0201_screen_004_不正ソートキーはデフォルト列() {
        stubCount = 1;
        stubList.add(new Order());

        Scr0201Form form = new Scr0201Form();
        form.setSortKey("AMOUNT; DROP TABLE T_ORDER");
        blogic.execute(form);

        assertEquals("ORDER_NO", form.getSortColumn());
    }

    /** SCR0201-SCREEN-004: 正当ソートキーは物理列名に解決 */
    @Test
    public void scr0201_screen_004_正当ソートキーは物理列に解決() {
        stubCount = 1;
        stubList.add(new Order());

        Scr0201Form form = new Scr0201Form();
        form.setSortKey("amount");
        blogic.execute(form);

        assertEquals("AMOUNT", form.getSortColumn());
    }

    /** SCR0201-SCREEN-003: ページ番号→OFFSET 計算（2ページ目 = OFFSET 20） */
    @Test
    public void scr0201_screen_003_ページ番号からOFFSET計算() {
        stubCount = 50;
        stubList.add(new Order());

        Scr0201Form form = new Scr0201Form();
        form.setPageNo(2);
        blogic.execute(form);

        assertEquals(20, form.getLimit());
        assertEquals(20, form.getOffset());
    }

    /** 共通: 実行時例外はシステムエラー msg.common.e999（AbstractBLogic の責務） */
    @Test
    public void common_e999_例外時システムエラー() {
        throwOnCount = true;

        BLogicResult<List<Order>> result = blogic.execute(new Scr0201Form());

        assertEquals(BLogicResult.STATUS_ERROR, result.getStatus());
        assertEquals("msg.common.e999", result.getMessageId());
    }
}
