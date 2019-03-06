package com.xujp.dj

import com.util.JSONData
import com.util.enums.HistoryType
import com.xujp.dj.Order
import com.xujp.dj.OrderHistory
import grails.converters.JSON

class ScanerOverController {
    def springSecurityService
    def index() {}
    /**
     * 顯示
     */
    def searchOrder = {
        def jsonData
        try {
            def order = Order.findByFreightNo(params?.freightNo)
            if (!order) {
                jsonData = new JSONData(success: false)
                render jsonData as JSON
                return;
            } else {
                if (!order.isAbnormal){
                    jsonData = new JSONData(success: false,alertMsg: "该订单不是异常订单，禁止操作！")
                    render jsonData as JSON
                    return;
                }
                def orderData = [id              : order?.id, freightNo: order?.freightNo, orderNo: order?.orderNo, enabled: order?.enabled,
                                 operationType   : order?.operationType, orderType: order?.orderType,
                                 initialStation  : order?.initialStation?.stationName, targetStation: order?.targetStation?.stationName,
                                 customerCode    : order?.customerCode, customer: order?.customer, address: order?.address, phoneNo: order?.phoneNo,
                                 company         : order?.company?.companyName, startCity: order?.startCity, endCity: order?.endCity, goodsName: order?.goodsName,
                                 receivable      : order?.receivable, payable: order?.payable, volume: order?.volume, weight: order?.weight,
                                 boxNum          : order?.boxNum, packageNum: order?.packageNum, otherNum: order?.otherNum, remark1: order?.remark1,
                                 orderState      : order?.orderState, completeState: order?.volume, completeState: order?.completeState,
                                 abnormalRemark  : order?.abnormalRemark, pickupDate: order?.pickupDate, wareEnterDate: order?.wareEnterDate, wareLeaveDate: order?.wareLeaveDate,
                                 stationEnterDate: order?.stationEnterDate, stationLeaveDate: order?.stationLeaveDate, deployEnterDate: order?.deployEnterDate,
                                 deployLeaveDate : order?.deployLeaveDate, finishedDate: order?.finishedDate, isFinished: order?.isFinished,
                                 isAbnormal      : order?.isAbnormal, abnormalReasion: order?.abnormalReasion, isComplete: order?.isComplete
                ]
                def dataInfo = [success: true, data: orderData]
                render dataInfo as JSON
                return
            }
        } catch (Exception e) {
            jsonData = new JSONData(success: false)
        }

        render jsonData as JSON
    }

    /****提报异常*/
    def saveOrder = {
        def currentUser = springSecurityService?.currentUser
        def jsonData
        try {
            def order = Order.load(params?.id)
            if (!order) {
                jsonData = new JSONData(success: false,alertMsg: "订单查询错误！")
                render jsonData as JSON
                return;
            } else {
                order.remark2 = params?.remark2
                order.isAbnormal = false
                //保存历史记录
                def orderHistory = new OrderHistory(
                        [
                                oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                                operMsg   : HistoryType.OVER_SCANER.toString(),
                                webMsg:'',
                                companyMsg: '',
                                sysMsg: HistoryType.OVER_SCANER.toString(),
                                remark:'',
                                orderInfo : order.orderType.toString()
                        ]
                )
                order.addToOrderHistorys(orderHistory)
                order.save(flush: true)
                jsonData = new JSONData(success: true,alertMsg: "订单异常处理成功！")

            }
        }catch (Exception e) {
            jsonData = new JSONData(success: false,alertMsg: e.printStackTrace())
        }
        render jsonData as JSON
    }
}
