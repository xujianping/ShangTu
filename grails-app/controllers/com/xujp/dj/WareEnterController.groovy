package com.xujp.dj

import com.util.JSONData
import com.util.enums.OrderState
import com.util.enums.OrderType
import com.xujp.dj.Order
import dj.BusinessException
import grails.converters.JSON

import java.text.SimpleDateFormat

class WareEnterController {
    def orderService
    def springSecurityService
    Calendar calendar = Calendar.instance
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");

    def index() {
        render(view: 'list')
    }

    def save = {
        def jsonData = new JSONData()
        try {
            def msg = orderService.orderWareEnter(params?.freightNo)
            jsonData = new JSONData(success: true, alertMsg: msg, soundMsg: "成功")
            render jsonData as JSON
        } catch (BusinessException e) {
            log.error(e.getMessage())
            jsonData = new JSONData(success: false, alertMsg: e.message, soundMsg: "错误")
        } catch (Exception e) {
            log.error(e.printStackTrace())
            jsonData = new JSONData(success: false, alertMsg: '未知错误!请重试。', soundMsg: "错误")
        }
        render jsonData
    }

    def enterBathOrder = {
        def messages = []
        def jsonData = []
        def orders = []
        def freightNos = []
        try {
            params?.freightNos.eachLine { freightNo ->
                freightNos << freightNo
                def order  = Order.findByFreightNo(freightNo)
                if(order){
                    if(order.orderType == OrderType.HQ_DEPLOY_ORDER){
                        if(!order.isComplete){
                            jsonData = new JSONData(success: false, alertMsg: "订单【${freightNo}】信息未补全前禁止入库！")
                            messages << jsonData
                            return
                        }
                        if(order.orderState != OrderState.DEPLOY_STATION_LEAVED ){
                            jsonData = new JSONData(success: false, alertMsg: "订单【${freightNo}】状态为【${order.orderState}】,状态错误！")
                            messages << jsonData
                            return
                        }
                        orders << freightNo
                        return
                    }else if(order.orderType == OrderType.DEPLOY_ORDER){
                        jsonData = new JSONData(success: false, alertMsg: "【${freightNo}】为直调单，禁止中心入库！!")
                        messages << jsonData
                        return
                    }else{
                        jsonData = new JSONData(success: false, alertMsg: "【${freightNo}】为配送单，已经录入!")
                        messages << jsonData
                        return
                    }
                }else{
                    orders << freightNo
                }
            }
                if (orders.size() != freightNos.size()) {
                    render messages as JSON
                    return
                } else {
                    orderService.wareBatchEnter(orders)
                    jsonData = new JSONData(success: true, alertMsg: "该批订单入库成功")
                    messages << jsonData
                    render messages as JSON
                    return
                }


        } catch (Exception e) {
            log.error(e)
            e.printStackTrace()
            jsonData = new JSONData(success: false, alertMsg: "货品入库失败，请重试！")
            messages << jsonData
            render messages as JSON
        }
    }
}
