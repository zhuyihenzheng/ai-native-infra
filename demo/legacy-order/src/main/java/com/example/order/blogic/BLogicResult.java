package com.example.order.blogic;

/**
 * 業務ロジック実行結果。ステータス＋メッセージID＋結果データを運ぶ。
 * メッセージIDは messages.properties のキー。
 */
public class BLogicResult<R> {

    /** 正常 */
    public static final String STATUS_OK = "0";
    /** 警告（業務エラー） */
    public static final String STATUS_WARN = "1";
    /** システムエラー */
    public static final String STATUS_ERROR = "9";

    private final String status;
    private final String messageId;
    private final R data;
    private final Throwable cause;

    private BLogicResult(String status, String messageId, R data, Throwable cause) {
        this.status = status;
        this.messageId = messageId;
        this.data = data;
        this.cause = cause;
    }

    public static <R> BLogicResult<R> ok(R data) {
        return new BLogicResult<R>(STATUS_OK, null, data, null);
    }

    public static <R> BLogicResult<R> warn(String messageId, R data) {
        return new BLogicResult<R>(STATUS_WARN, messageId, data, null);
    }

    public static <R> BLogicResult<R> systemError(String messageId, Throwable cause) {
        return new BLogicResult<R>(STATUS_ERROR, messageId, null, cause);
    }

    public String getStatus() {
        return status;
    }

    public String getMessageId() {
        return messageId;
    }

    public R getData() {
        return data;
    }

    public Throwable getCause() {
        return cause;
    }
}
