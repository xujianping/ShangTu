package com.xujp.dj

import com.util.JSONData
import com.util.enums.OrderType
import dj.BusinessException
import grails.converters.JSON

import java.text.SimpleDateFormat

/****
 * 直调站点入库
 * 相当与录入订单
 */
class DeployStationEnterController {
    def orderService
    def springSecurityService
    Calendar calendar = Calendar.instance
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
    def index() {
        render(view: 'list')
    }

    def save = {
        log.info(params)
        def jsonData = new JSONData()
        try {
            def msg = orderService.deployStationEnter(params?.freightNo, OrderType.getType(params?.orderType))
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
}
