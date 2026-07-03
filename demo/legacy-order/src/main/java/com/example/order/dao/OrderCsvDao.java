package com.example.order.dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * 受注CSV出力用DAO（旧世代実装）。
 *
 * ※ 注意：文字列連結でSQLを組み立てる旧方式のまま残っている。
 *   新規実装で本クラスの書き方を模倣しないこと（Mapper XML + #{} を使う）。
 *   改修候補だが他システム連携バッチが依存しているため凍結中。
 */
@Component
public class OrderCsvDao {

    @Autowired
    private DataSource dataSource;

    public List<String> exportCsv(String statusCode) {
        List<String> lines = new ArrayList<String>();
        // 旧方式：SQL文字列連結（模倣禁止）
        String sql = "SELECT ORDER_NO, CUSTOMER_NAME, AMOUNT FROM T_ORDER"
                + " WHERE STATUS = '" + statusCode + "' ORDER BY ORDER_NO";
        try (Connection con = dataSource.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                lines.add(rs.getString(1) + "," + rs.getString(2) + "," + rs.getInt(3));
            }
        } catch (SQLException e) {
            throw new RuntimeException("CSV出力に失敗しました", e);
        }
        return lines;
    }
}
