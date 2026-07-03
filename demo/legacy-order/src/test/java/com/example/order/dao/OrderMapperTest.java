package com.example.order.dao;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.Reader;
import java.sql.Connection;
import java.util.List;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.jdbc.ScriptRunner;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.junit.BeforeClass;
import org.junit.Test;

import com.example.order.entity.Order;
import com.example.order.form.Scr0201Form;

/**
 * OrderMapper 単体テスト。Spring を起動せず SqlSessionFactory + H2 で実施（本システムの慣習）。
 * テストデータは data.sql（合成データ）。メソッド名にトレーサビリティIDを埋め込む。
 */
public class OrderMapperTest {

    private static SqlSessionFactory factory;

    @BeforeClass
    public static void setUpClass() throws Exception {
        try (Reader reader = Resources.getResourceAsReader("mybatis-test-config.xml")) {
            factory = new SqlSessionFactoryBuilder().build(reader);
        }
        try (SqlSession session = factory.openSession(true)) {
            Connection con = session.getConnection();
            ScriptRunner runner = new ScriptRunner(con);
            runner.setLogWriter(null);
            runner.runScript(Resources.getResourceAsReader("schema.sql"));
            runner.runScript(Resources.getResourceAsReader("data.sql"));
        }
    }

    /** T_ORDER-DB-001: resultMap 全列マッピング（STATUS→statusCode を含む） */
    @Test
    public void t_order_db_001_resultMap全列マッピング() {
        try (SqlSession session = factory.openSession()) {
            OrderMapper mapper = session.getMapper(OrderMapper.class);
            Order order = mapper.selectByKey("0000000001");
            assertNotNull(order);
            assertEquals("0000000001", order.getOrderNo());
            assertEquals("山田商事株式会社", order.getCustomerName());
            assertEquals("01", order.getStatusCode());
            assertNotNull(order.getOrderDate());
            assertEquals(Integer.valueOf(150000), order.getAmount());
        }
    }

    /** SCR0201-SCREEN-001: キーワード部分一致検索 */
    @Test
    public void scr0201_screen_001_キーワード部分一致検索() {
        try (SqlSession session = factory.openSession()) {
            OrderMapper mapper = session.getMapper(OrderMapper.class);
            Scr0201Form form = newForm();
            form.setKeyword("山田");
            assertEquals(2, mapper.countByCondition(form));
            List<Order> list = mapper.selectByCondition(form);
            assertEquals(2, list.size());
        }
    }

    /** SCR0201-SCREEN-002: ステータス絞込（キーワードとのAND） */
    @Test
    public void scr0201_screen_002_ステータス絞込() {
        try (SqlSession session = factory.openSession()) {
            OrderMapper mapper = session.getMapper(OrderMapper.class);
            Scr0201Form form = newForm();
            form.setKeyword("山田");
            form.setStatusCode("02");
            List<Order> list = mapper.selectByCondition(form);
            assertEquals(1, list.size());
            assertEquals("山田製作所", list.get(0).getCustomerName());
        }
    }

    /** SCR0201-SCREEN-003: ページング境界（LIMIT/OFFSET） */
    @Test
    public void scr0201_screen_003_ページング境界() {
        try (SqlSession session = factory.openSession()) {
            OrderMapper mapper = session.getMapper(OrderMapper.class);
            Scr0201Form form = newForm();
            form.setLimit(2);
            form.setOffset(4);
            List<Order> list = mapper.selectByCondition(form);
            // 全5件中 OFFSET 4 → 最終1件のみ
            assertEquals(1, list.size());
            assertEquals("0000000005", list.get(0).getOrderNo());
        }
    }

    /** SCR0201-SCREEN-004: ソート列（AMOUNT 昇順） */
    @Test
    public void scr0201_screen_004_金額昇順ソート() {
        try (SqlSession session = factory.openSession()) {
            OrderMapper mapper = session.getMapper(OrderMapper.class);
            Scr0201Form form = newForm();
            form.setSortColumn("AMOUNT");
            List<Order> list = mapper.selectByCondition(form);
            assertEquals(5, list.size());
            for (int i = 1; i < list.size(); i++) {
                assertTrue("金額昇順であること",
                        list.get(i - 1).getAmount() <= list.get(i).getAmount());
            }
        }
    }

    private Scr0201Form newForm() {
        Scr0201Form form = new Scr0201Form();
        form.setSortColumn("ORDER_NO");
        form.setLimit(20);
        form.setOffset(0);
        return form;
    }
}
