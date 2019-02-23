package com.xujp.dj
/****
 * 订单操作历史信息表
 */
class OrderHistory {
    /** 创建日期*/
    Date dateCreated
    /**修改日期*/
    Date lastUpdated
    /** 操作人*/
    String oper
    /** 操作内容*/
    String operMsg
    /** web查询内容*/
    String webMsg
    /** 电商显示内容*/
    String companyMsg
    /** 系统对接内容*/
    String sysMsg
    /** 系统对接是否发送成功(用于状态上传)*/
    Boolean sysSendTag = false
    /** 备注*/
    String remark
    /** 订单内容*/
    String orderInfo
    /**是否有效*/
    Boolean enabled = true
    /** 对方系统成功响应的数据*/
    String sysResponseMsg



    static belongsTo = [order: Order]

    static constraints = {
        companyMsg nullable: true
        sysMsg nullable: true
        webMsg nullable: true
        sysSendTag nullable: true
        remark nullable: true
        orderInfo nullable: true
        companyMsg size: 0..2000
        webMsg size: 0..2000
        sysMsg size: 0..2000
        sysResponseMsg nullable: true
        sysResponseMsg size: 0..2000
    }
    static mapping = {
        order lazy: true
        batchSize:30
        table 'dj_order_history'

    }
}
