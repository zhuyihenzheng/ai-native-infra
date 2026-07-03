# Golden Example — Mapper（接口 + XML）

> 取自 src/main/java/com/example/order/dao/OrderMapper.java + src/main/resources/sqlmap/OrderMapper.xml。
> 生成新 Mapper 对齐此样式。**XML 放 `resources/sqlmap/`，不是 `mapper/`。**

## 关键约定（从样本归纳）

- namespace = 接口全限定名；SQL id = 方法名；入参直接传画面 Form
- 列映射以手写 resultMap 为正（注意既存不规则映射 `STATUS→statusCode`，禁改）
- 条件用 `<where>/<if>` + `#{}`；共用条件抽 `<sql>` + `<include>`
- 排序 `ORDER BY ${sortColumn}` 是**唯一** `${}` 例外——值必须是 BLogic 白名单解析产物
- 分页手写 `LIMIT #{limit} OFFSET #{offset}`

## 样例

```java
// src/main/java/com/example/order/dao/OrderMapper.java:15-24
@Mapper
public interface OrderMapper {
    int countByCondition(Scr0201Form condition);
    List<Order> selectByCondition(Scr0201Form condition);
    Order selectByKey(@Param("orderNo") String orderNo);
}
```

```xml
<!-- src/main/resources/sqlmap/OrderMapper.xml:6-41（略节） -->
<resultMap id="orderResultMap" type="com.example.order.entity.Order">
  <id     column="ORDER_NO"      property="orderNo"/>
  <result column="CUSTOMER_NAME" property="customerName"/>
  <result column="STATUS"        property="statusCode"/>  <!-- 歴史的経緯、変更禁止 -->
  <!-- …略 -->
</resultMap>

<sql id="searchCondition">
  <where>
    <if test="keyword != null and keyword != ''">
      CUSTOMER_NAME LIKE '%' || #{keyword} || '%'
    </if>
    <if test="statusCode != null and statusCode != ''">
      AND STATUS = #{statusCode}
    </if>
  </where>
</sql>

<select id="selectByCondition" parameterType="com.example.order.form.Scr0201Form"
        resultMap="orderResultMap">
  SELECT ORDER_NO, CUSTOMER_NAME, STATUS, ORDER_DATE, AMOUNT
  FROM T_ORDER
  <include refid="searchCondition"/>
  ORDER BY ${sortColumn}          <!-- BLogic 白名单解析済みのみ -->
  LIMIT #{limit} OFFSET #{offset}
</select>
```
