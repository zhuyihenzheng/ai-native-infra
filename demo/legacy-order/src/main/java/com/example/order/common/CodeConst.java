package com.example.order.common;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * コードマスタ定数。（本システムはDBコードマスタを持たず、定数クラスで管理する）
 */
public final class CodeConst {

    /** 受注ステータス：新規 */
    public static final String STATUS_NEW = "01";
    /** 受注ステータス：出荷済 */
    public static final String STATUS_SHIPPED = "02";
    /** 受注ステータス：キャンセル */
    public static final String STATUS_CANCELLED = "09";

    /** 一覧画面の1ページ表示件数 */
    public static final int PAGE_SIZE = 20;

    /**
     * ソートキー→物理列名のホワイトリスト。
     * ORDER BY はこの表で解決した列名のみ許可（SQLインジェクション対策）。
     * 新しいソート列を追加する場合は必ずここに登録すること。
     */
    public static final Map<String, String> SORT_WHITELIST;
    static {
        Map<String, String> m = new HashMap<String, String>();
        m.put("orderNo", "ORDER_NO");
        m.put("orderDate", "ORDER_DATE");
        m.put("amount", "AMOUNT");
        SORT_WHITELIST = Collections.unmodifiableMap(m);
    }

    /** デフォルトソート列 */
    public static final String DEFAULT_SORT_COLUMN = "ORDER_NO";

    private CodeConst() {
    }
}
