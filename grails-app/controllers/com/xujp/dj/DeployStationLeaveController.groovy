package com.xujp.dj

import com.util.JSONData
import com.util.enums.OrderState
import com.util.enums.StationType
import com.xujp.dj.Order
import com.xujp.dj.Station
import grails.converters.JSON
import groovy.time.TimeCategory

import java.text.SimpleDateFormat

class DeployStationLeaveController {
    def orderService
    def springSecurityService
    Calendar calendar = Calendar.instance
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
    def index() {
        def spd = new SimpleDateFormat("yyMMdd");
        def date = new Date()
        def batchNoData = []
        use(TimeCategory) {
            for (int i = 0; i < 2; i++) {
                batchNoData <<"DL" + spd.format(date - i.days)
            }
        }

        def stations = Station.findAllByStationType(StationType.ST,[sort: 'stationCode'])

        render(view: 'index', model: [batchNoData:batchNoData,stations:stations])

    }

    def save = {
        def jsonData = [success: true]
        try {
            def order = Order.findByFreightNo(params?.freightNo)
            if(!order){
                jsonData = new JSONData(success: false, alertMsg: "订单不存在", soundMsg: "不存在")
                render jsonData as JSON
                return
            }else{
                if(order.orderState != OrderState.DEPLOY_STATION_ENTERED ){
                    jsonData = new JSONData(success: false, alertMsg: "订单状态为[${order.orderState.toString()}],不能出库！", soundMsg: "状态错误")
                    render jsonData as JSON
                    return
                }
                if(order.isFinished){
                    jsonData = new JSONData(success: false, alertMsg: "订单已完成,不能入库！", soundMsg: "已完成")
                    render jsonData as JSON
                    return
                }
                orderService.deployStationLeave(order,params)
                jsonData = new JSONData(success: true, alertMsg: "直调订单出库成功！", soundMsg: "成功")
                render jsonData as JSON
                return
            }
        } catch (Exception e) {
            log.info(e.printStackTrace())
            jsonData = new JSONData(success: false, alertMsg: "货品出库失败，请重试！", soundMsg: '错误')
            render jsonData as JSON
        }
    }
}
