package com.xujp.dj

import com.util.JSONData
import com.xujp.dj.Order
import dj.BusinessException
import grails.converters.JSON

import java.text.SimpleDateFormat

class OrderUpdateController {
    def orderService
    def springSecurityService
    def sdfyMd = new SimpleDateFormat('yyyy-MM-dd')
    def sdfyMdHms = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss')
    def index() {}
    /**
     *   根据订单号查订单信息
     */
    def searchOrder = {
        def jsonData
        try {
            def order = Order.findByFreightNo(params?.freightNo)
            if (!order) {
                jsonData = new JSONData(success: false, data: "查找不到订单信息")
                render jsonData as JSON
                return
            } else {
                def dataInfo = [success: true, data: order]
                render dataInfo as JSON
                return
            }
        } catch (Exception e) {
            log.error(e.getMessage())
            jsonData = new JSONData(success: false, data: "系统异常，请刷新重试")
        }
        render jsonData as JSON
    }
    /**
     *   保存订单基本信息
     */
    def saveOrder = {
        println(params)
        def jsonData = [success: true]
        try {
            def order = Order.get(params?.id.toLong())
            orderService.orderUpdate(order ,params)
            jsonData = [success: true , alertMsg: "订单基本信息修改成功！"]
            render jsonData as JSON
        }catch (BusinessException e){
            log.error(e.getMessage())
            jsonData = new JSONData([success: false, alertMsg: e.message])
        }catch (Exception e) {
            log.error(e)
            jsonData = new JSONData([success: false, alertMsg: '修改错误！请检查输入数据'])
        }
        render jsonData
    }
}
