package com.xujp.dj
/**
 * 订单的货品详情表
 */
class OrderGoods {
    /***商品包号**/
    String goodsNo
    /***商品名称**/
    String goodsName
    /***商品编码**/
    String goodsCode
    /** 货品重量*/
    BigDecimal goodsWeight = BigDecimal.ZERO
    /**货品体积 */
    BigDecimal goodsVolume = BigDecimal.ZERO
    /** 货品价值*/
    BigDecimal goodsCost = BigDecimal.ZERO
    /** 货品数量*/
    Integer goodsNum = 1

    static belongsTo = [order: Order]

    static constraints = {
        goodsCode nullable: true
    }
    static  mapping = {
        table('dj_order_goods')

    }
}
