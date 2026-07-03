-- T_ORDER: 受注テーブル（DEF: docs/def/db/T_ORDER.table.yml / T_ORDER-DB-001）
CREATE TABLE IF NOT EXISTS T_ORDER (
    ORDER_NO       CHAR(10)     NOT NULL,
    CUSTOMER_NAME  VARCHAR(40)  NOT NULL,
    STATUS         CHAR(2)      NOT NULL,
    ORDER_DATE     DATE         NOT NULL,
    AMOUNT         INT          NOT NULL,
    PRIMARY KEY (ORDER_NO)
);
