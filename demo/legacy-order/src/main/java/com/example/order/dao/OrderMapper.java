package com.example.order.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.order.entity.Order;
import com.example.order.form.Scr0201Form;

/**
 * 受注テーブル（T_ORDER）Mapper。SQL 本体は resources/sqlmap/OrderMapper.xml。
 * 検索条件は画面フォームをそのまま渡す方式（本システムの慣習）。
 */
@Mapper
public interface OrderMapper {

    /** 検索条件に合致する総件数 */
    int countByCondition(Scr0201Form condition);

    /** 検索条件・ページング・ソートに従い一覧取得 */
    List<Order> selectByCondition(Scr0201Form condition);

    /** 主キー取得 */
    Order selectByKey(@Param("orderNo") String orderNo);
}
