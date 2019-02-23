package com.xujp.dj

import com.util.enums.CompleteState
import com.util.enums.OrderState
import com.util.enums.OrderType

/***
 * 订单信息
 */
class Order {
    /** 运单号 */
    String freightNo
    /** 订单号*/
    String orderNo
    /** 是否有效 */
    boolean enabled = true
    /***操作性质*/
    String operationType
    /** 订单类型*/
    OrderType orderType
    /**出发站点**/
    Station initialStation
    /**所属站点**/
    Station targetStation
    /** 收货店铺代码*/
    String customerCode
    /** 收件人*/
    String customer
    /** 收件人地址*/
    String address
    /** 收件人电话 */
    String phoneNo
    /** 电商公司*/
    Company company
    /** 发货城市*/
    String startCity
    /** 收货城市*/
    String endCity
    /** 商品名*/
    String goodsName
    /** 应收款*/
    BigDecimal receivable = BigDecimal.ZERO
    /** 应退款 */
    BigDecimal payable = BigDecimal.ZERO
    /** 货品总重量*/
    BigDecimal weight = BigDecimal.ZERO
    /**货品总体积 */
    BigDecimal volume = BigDecimal.ZERO
    /** 货品价值*/
    BigDecimal cost = BigDecimal.ZERO
    /** 包数量 */
    Integer boxNum = 0
    /** 箱数量 */
    Integer packageNum = 0
    /** 货品数量 */
    Integer otherNum = 0
    /**备注1*/
    String remark1
    /**备注2*/
    String remark2
    /**备注3*/
    String remark3
    /**承运商**/
    String carrier
    /**承运商单号**/
    String carrierFreightNo
    /**订单状态*/
    OrderState orderState
    /**完成状态*/
    CompleteState completeState
    /**是否完成*/
    Boolean isFinished = false
    /**终结原因*/
    String abnormalRemark
    /**是否补全信息*/
    Boolean isComplete = false
    /** 创建日期*/
    Date dateCreated
    /**收货日期*/
    Date pickupDate
    /**中心入库日期*/
    Date wareEnterDate
    /**中心出库日期*/
    Date wareLeaveDate
    /**站点入库日期*/
    Date stationEnterDate
    /**站点出库日期*/
    Date stationLeaveDate
    /**直调入库日期*/
    Date deployEnterDate
    /**直调出库日期*/
    Date deployLeaveDate
    /**直调入库日期*/
    Date deployStationEnterDate
    /**直调出库日期*/
    Date deployStationLeaveDate
    /**完成时间*/
    Date finishedDate
    /**库房出库批次*/
    String wareLeaveBatch
    /**库房出库包裹*/
    String wareLeavePackNo
    /**站点出库批次*/
    String stationLeaveBatch
    /**站点出库包裹*/
    String stationLeavePackNo
    /**收件员**/
    Poster receverPoster
    /**投递员**/
    Poster poster
    /**是否异常件**/
    Boolean isAbnormal = false
    /**异常原因**/
    String abnormalReasion
    /**签收人**/
    String completeName
    /***出发店铺代码**/
    String companyCode

    static hasMany = [
                      orderHistorys: OrderHistory,
                      orderScannings: OrderScanning,
                      orderGoods: OrderGoods
    ]

    static constraints = {
        freightNo nullable: true,unique: true
        orderNo nullable: true
        companyCode nullable: true
        orderType nullable: true
        targetStation nullable: true
        initialStation nullable: true
        customer nullable: true
        address nullable: true
        company nullable: true
        goodsName nullable: true
        phoneNo nullable: true
        orderState nullable: true
        completeState nullable: true
        abnormalRemark nullable: true
        pickupDate nullable: true
        wareEnterDate nullable: true
        wareLeaveDate nullable: true
        stationEnterDate nullable: true
        stationLeaveDate nullable: true
        deployEnterDate nullable: true
        deployLeaveDate nullable: true
        deployStationEnterDate nullable: true
        deployStationLeaveDate nullable: true
        finishedDate nullable: true
        remark1 nullable: true
        remark2 nullable: true
        remark3 nullable: true
        wareLeaveBatch nullable: true
        wareLeavePackNo nullable: true
        stationLeaveBatch nullable: true
        stationLeavePackNo nullable: true
        receverPoster nullable: true
        poster nullable: true
        carrier nullable: true
        carrierFreightNo nullable: true
        customerCode nullable: true
        endCity nullable: true
        operationType nullable: true
        startCity nullable: true
        abnormalReasion  nullable: true
        completeName nullable: true
    }
    static mapping = {
//        targetStation cache: 'read-write'
//        initialStation cache: 'read-write'
        company cache: 'read-write'
        table 'dj_order'
    }
}
