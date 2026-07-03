package com.example.order.entity;

import java.util.Date;

/**
 * 受注エンティティ（T_ORDER）。列マッピングは sqlmap/OrderMapper.xml の resultMap を正とする。
 * 注意：STATUS 列はフィールド名 statusCode にマッピングする（歴史的経緯）。
 */
public class Order {

    /** 受注番号（ORDER_NO, PK） */
    private String orderNo;

    /** 得意先名（CUSTOMER_NAME） */
    private String customerName;

    /** 受注ステータス（STATUS → statusCode。CodeConst 参照） */
    private String statusCode;

    /** 受注日（ORDER_DATE） */
    private Date orderDate;

    /** 受注金額（AMOUNT） */
    private Integer amount;

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(String statusCode) {
        this.statusCode = statusCode;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }
}
