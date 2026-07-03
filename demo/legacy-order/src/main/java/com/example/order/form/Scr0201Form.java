package com.example.order.form;

/**
 * SCR0201 受注一覧画面フォーム。
 * 検索条件のほか、ページング状態・解決済みソート列・総件数も本フォームで運ぶ
 * （検索実行後、BLogic が totalCount を書き戻す方式）。
 */
public class Scr0201Form {

    /** 検索条件：得意先名キーワード（部分一致） */
    private String keyword;

    /** 検索条件：受注ステータス（CodeConst 参照。未指定は全件） */
    private String statusCode;

    /** 現在ページ番号（1始まり） */
    private int pageNo = 1;

    /** 画面から渡る論理ソートキー（orderNo / orderDate / amount） */
    private String sortKey;

    /** BLogic が SORT_WHITELIST で解決した物理ソート列。SQL の ORDER BY に使う */
    private String sortColumn;

    /** SQL 用 LIMIT（BLogic が設定） */
    private int limit;

    /** SQL 用 OFFSET（BLogic が設定） */
    private int offset;

    /** 検索結果総件数（BLogic が書き戻す） */
    private int totalCount;

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public String getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(String statusCode) {
        this.statusCode = statusCode;
    }

    public int getPageNo() {
        return pageNo;
    }

    public void setPageNo(int pageNo) {
        this.pageNo = pageNo;
    }

    public String getSortKey() {
        return sortKey;
    }

    public void setSortKey(String sortKey) {
        this.sortKey = sortKey;
    }

    public String getSortColumn() {
        return sortColumn;
    }

    public void setSortColumn(String sortColumn) {
        this.sortColumn = sortColumn;
    }

    public int getLimit() {
        return limit;
    }

    public void setLimit(int limit) {
        this.limit = limit;
    }

    public int getOffset() {
        return offset;
    }

    public void setOffset(int offset) {
        this.offset = offset;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }
}
