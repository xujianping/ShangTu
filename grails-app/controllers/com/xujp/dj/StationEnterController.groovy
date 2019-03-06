package com.xujp.dj

import com.util.JSONData
import com.util.enums.OrderState
import com.util.enums.OrderType
import com.util.enums.StationType
import com.xujp.dj.Order
import grails.converters.JSON
import groovy.sql.Sql

import java.text.SimpleDateFormat

/**
 * 站点入库
 */
class StationEnterController {
    def springSecurityService
    def orderService
    def dataSource
    def index() {
        def sdf = new SimpleDateFormat('yyMMdd')
        def stations = springSecurityService.currentUser?.station?.selfAndChildren
        def notManagerStation = []
        stations.each { stat ->
            if (stat.stationType == StationType.ST) {
                notManagerStation << stat
            }
        }

        def beachNos = []
        for (def i = 0; i < 30; i++) {
            def BatchNo = 'WL' + sdf.format(new Date() - i)
            def value = [key: BatchNo, value: BatchNo]
            beachNos << value
            def BatchNoDL = 'DL' + sdf.format(new Date() - i)
            def valueDL = [key: BatchNoDL, value: BatchNoDL]
            beachNos << valueDL
        }
        render(view: 'index', model: [stations: notManagerStation, bathNos: beachNos])
    }
/***
 * 获取包裹号
 */
    def getPackNo = {
        def jsonData = [success: true]
        def list = []
        try {
            def stationId = params?.stationId
            def batchNo = params?.batchNo
            if (!stationId || !batchNo) {
                jsonData = new JSONData(success: true, data: list)
                render jsonData as JSON
                return
            }
            def sql_str = """
                select distinct  t.ware_leave_pack_no as PACKNO from dj_order t
                    where t.ware_Leave_Batch = '"""+batchNo+"""'
                         and t.target_station_id = ${stationId}
            """
            if(batchNo.contains('DL')){
                sql_str = """
                select distinct  t.station_leave_pack_no as PACKNO from dj_order t
                where t.station_Leave_Batch = '"""+batchNo+"""'
                     and t.target_station_id = ${stationId}
                """
            }

            Sql sql = new Sql(dataSource)
            def value = []
            sql.rows(sql_str).each { no ->
                value = [packKey: no['PACKNO'], pachValue: no['PACKNO']]
                list << value
            }
            sql.close()
            jsonData = new JSONData(success: true, alertMsg: "获取包裹号成功", data: list)
            render jsonData as JSON
            return
        }catch (Exception e ){
            log.error("站点入库获取包裹号失败!" + e.printStackTrace())
            jsonData = new JSONData(success: false, alertMsg: "获取包裹号失败!", data: list)
            render jsonData as JSON
            return
        }
    }

    /**
     * 待扫描订单
     */
    def getNotScanningOrder = {
        def stationId = params?.stationId
        def batchNo = params?.batchNo
        def packNo = params?.packNo
        def showAbel = params?.showAbel ?true:false
        def jsonData
        Calendar calendar = Calendar.instance
        calendar.add(Calendar.MONTH , -1)
        def orderState
        def hql = """
                select new map(o.id as id  , o.freightNo as freightNo , o.customer as customer,
                                o.company as company , o.address as address)
                from Order o
                where 1=1 """
        if(batchNo.toString().contains('WL')){
            orderState = OrderState.WARE_LEAVED
            hql +=""" and o.targetStation.id = ? and o.orderState = ? and o.wareLeaveBatch=?  and o.wareLeavePackNo = ?"""
        }else{
            orderState = OrderState.DEPLOY_STATION_LEAVED
            hql +=""" and o.targetStation.id = ? and o.orderState = ? and o.stationLeaveBatch=?  and o.stationLeavePackNo = ?
                 and o.orderType = '${OrderType.DEPLOY_ORDER.name()}'"""
        }
        hql +="""
                and o.dateCreated >= ?
                and o.dateCreated <= ?
                """
        def orders =  Order.executeQuery(hql,[stationId.toLong(), orderState, batchNo?.trim(), packNo?.trim(), calendar.getTime(), new Date()])

        if (showAbel) {
            jsonData = new JSONData(data: orders, totalCount: orders.size())
        }else{
            jsonData = new JSONData( totalCount: orders.size())
        }
        orders = null
        render jsonData as JSON
    }

    /***
     * 入库
     */
    def save={
        Calendar calendar = Calendar.instance
        calendar.add(Calendar.MONTH , -3)
        def jsonData = [success: true]
        def currentStation = springSecurityService.currentUser?.station
        def packNo = params?.packNo
        def freightNo = params?.freightNo
        try {
            def orderData = Order.executeQuery("""
                select new map(
                   o.id as id,o.orderState as orderState,o.isComplete as isComplete,st.id as stationId,o.orderType as orderType,
                   st.stationName as stationName,o.freightNo as freightNo,o.customer as customer ,
                   o.company as company ,o.address as address
                )
                from Order o left join o.targetStation st
                where
                    o.freightNo = ?
                    and o.dateCreated >= ?
                   and o.dateCreated <= ?
               """,[freightNo,calendar.getTime(),new Date()])
            def orderMap
            if(!orderData){
                jsonData = new JSONData(success: false, alertMsg: "订单【${params?.freightNo}】不存在！", soundMsg: '无信息')
                render jsonData as JSON
                return
            }else{
                orderMap = orderData.get(0)
                if (orderMap['stationId']!= params?.stationId.toLong() ) {
                    jsonData = new JSONData(success: false, alertMsg: "订单【${params?.freightNo}】不属于本站！", soundMsg: "不属于本站")
                    render jsonData as JSON
                    return
                }
                if (!orderMap['isComplete']) {
                    jsonData = new JSONData(success: false, alertMsg: "订单【${params?.freightNo}】信息未补全,不能入库", soundMsg: "信息未补全")
                    render jsonData as JSON
                    return
                }
                if(orderMap['orderType'] == OrderType.DELIVER_ORDER){
                    if(orderMap['orderState'] != OrderState.WARE_LEAVED ){
                        jsonData = new JSONData(success: false, alertMsg: "配送单【${params?.freightNo}】状态为${orderMap['orderState']}", soundMsg: "状态错误")
                        render jsonData as JSON
                        return
                    }
                }else if(orderMap['orderType'] == OrderType.DEPLOY_ORDER){
                    if(orderMap['orderState'] != OrderState.DEPLOY_STATION_LEAVED ){
                        jsonData = new JSONData(success: false, alertMsg: "直调单【${params?.freightNo}】状态为${orderMap['orderState']}", soundMsg: "状态错误")
                        render jsonData as JSON
                        return
                    }
                }else if(orderMap['orderType'] == OrderType.HQ_DEPLOY_ORDER){
                    if(orderMap['orderState'] != OrderState.WARE_LEAVED ){
                        jsonData = new JSONData(success: false, alertMsg: "中心直调单【${params?.freightNo}】状态为${orderMap['orderState']}", soundMsg: "状态错误")
                        render jsonData as JSON
                        return
                    }
                }

                orderService.stationEnter(orderMap)
                jsonData = new JSONData(success: true, alertMsg: "订单入库成功！", soundMsg: '成功',data:orderMap)
                render jsonData as JSON
                return
            }

        }catch (Exception e) {
            log.error(e.printStackTrace())
            jsonData = new JSONData(success: false, alertMsg: "站点入库失败，请重试！", soundMsg: '入库失败，请重试')
            render jsonData as JSON
            return
        }
    }
}
