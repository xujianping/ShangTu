package com.xujp.dj
/**
 * 订单扫描信息表
 */
class OrderScanning {
    /** 创建日期 */
    Date dateCreated
    /** 扫描人*/
    String oper
    /** 扫描内容*/
    String scanMsg

    static belongsTo = [order: Order]

    static constraints = {
    }
    static mapping = {
        order lazy: true
        batchSize:30
        table 'dj_order_scanning'
    }
}
