package com.xujp.dj

import com.util.JSONData
import com.xujp.dj.Order
import grails.converters.JSON

class DeleteOrderController {
    def orderService

    def index() {}

    def remove ={
        def jsonData = [success: true]
        def order
        def msg = ''
        def orders = []
        params?.freightNos.eachLine {  freightNo ->
            order= Order.findByFreightNo(freightNo.trim())
            if (!order){
                msg += "订单【${freightNo}】不存在。\n\t"
            }else{
                orders << order
            }
        }
        if (!orders){
            jsonData = new JSONData(success: false, alertMsg: '所有订单不存在，请检查!')
            render jsonData as JSON
            return
        }
        if (msg!=''){
            jsonData = new JSONData(success: false, alertMsg: msg)
            render jsonData as JSON
            return
        }
        try{
            orderService.deleteOrder(orders,params?.freightNos)
        } catch(Exception e){
            log.error("删除订单异常！" + e)
            jsonData = new JSONData(success: false, alertMsg: '系统异常，请刷新页面后重试！')
        }
        render jsonData as JSON
        return
    }
}
