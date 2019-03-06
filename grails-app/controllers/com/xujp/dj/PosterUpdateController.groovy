package com.xujp.dj

import com.util.JSONData
import com.util.enums.OrderState
import com.xujp.dj.Order
import com.xujp.dj.Poster
import grails.converters.JSON

import java.text.SimpleDateFormat

class PosterUpdateController {

    def springSecurityService
    def orderService
    def timeSdf = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss')
    def sdf = new SimpleDateFormat('yyyy-MM-dd')
    def vipShopPhoneService
    def index = {
        def currentStation = session.getValue('currentStation')
        def stations = [currentStation]
        currentStation?.allChildren?.each { st ->
            stations.add(st)
        }
        def posters = []
        Poster.findAllByStationInListAndEnabled(stations, true).each {
            posters.add([it.id, it.posterName])
        }
        params.posters = posters as JSON
    }

    def searchOrders(def searchList) {
        def sql = """
                select new map (
                o.id as id ,o.isFinished as isFinished,o.completeState as completeState,o.orderState as orderState,
                o.freightNo as freightNo,o.orderType as orderType,o.customer as customer,o.address as address,
                o.goodsName as goodsName,p.posterName as posterName,
                o.targetStation.id as targetStation,c.companyName as companyName
                 ) from Order o left join o.company c left join o.poster p where 1=1
                 and o.freightNo in (${searchList.get('freightNos').join(",")})
            """
        def orderData = Order.executeQuery(sql, [])
        return orderData
    }

    /**
     *  订单单条扫描
     */
    def scanningOrder = {
        def jsonData
        try {
            def stationIds = session.getValue('stationIds')
            def freightNos = []
            freightNos << "'${params?.freightNo.trim()}'"
            def searchList = ['freightNos': freightNos]
            def orderData = searchOrders(searchList)

            if (!orderData) {
                jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】订单不存在!", soundMsg: '无信息', data: null)
                render jsonData as JSON
                return
            } else {
                def orderMap = orderData.get(0)
                orderData = null
                if (!stationIds.contains(orderMap['targetStation'])) {
                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】不属于本站点!", soundMsg: '不属于本站点', data: null)
                    render jsonData as JSON
                    return
                }
                /*
                if (orderMap['finished']) {
                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】已完成!", soundMsg: '已完成', data: null)
                    render jsonData as JSON
                    return
                }
                */
                if (orderMap['orderState'] >= OrderState.STATION_LEAVED && orderMap['posterName']) {
                    jsonData = new JSONData(success: true, alertMsg: "【${params?.freightNo}】查询成功!", data: orderMap)
                    render jsonData as JSON
                    return
                } else if (!orderMap['posterName']) {
                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】未分配投递人员不能修改!", data: null)
                    render jsonData as JSON
                    return
                } else {
                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】状态为${orderMap['orderState']}不能修改!", data: null)
                    render jsonData as JSON
                    return
                }

            }
        } catch (RuntimeException e) {
            log.error(e)
            jsonData = new JSONData(success: false, alertMsg: "查询失败,请重试!",)
            render jsonData as JSON
            return
        }
    }

    /**
     *  订单批量扫描
     */
    def scanningBathOrder = {
        def messages = []
        def jsonData = []
        def allFreightNos = []
        def freightNos = []
        def selectFreightNos = []
        def noSelectFreightNos = []
        try {
            def stationIds = session.getValue('stationIds')

            params?.freightNos.eachLine { freightNo ->
                freightNos << freightNo
                allFreightNos << "'${freightNo.trim()}'"
            }
            def searchList = ['freightNos': allFreightNos]
            def orderData = searchOrders(searchList)
            if (!orderData) {
                jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】订单不存在!", soundMsg: '无信息', data: null)
                render jsonData as JSON
                return
            } else {
                orderData.each { orderMap ->
                    selectFreightNos << orderMap['freightNo']
                    if (!stationIds.contains(orderMap['targetStation'])) {
                        jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】不属于本站点!", soundMsg: '不属于本站点', data: null)
                        messages << jsonData
                        return
                    }

                    if (orderMap['orderState'] >= OrderState.STATION_LEAVED && orderMap['posterName']) {
                        jsonData = new JSONData(success: true, alertMsg: "【${orderMap['freightNo']}】查询成功!", data: orderMap)
                        messages << jsonData
                        return
                    } else if (!orderMap['posterName']) {
                        jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】未分配投递人员不能修改!", data: null)
                        messages << jsonData
                        return
                    } else {
                        jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】状态为${orderMap['OrderState']}不能修改!", data: null)
                        messages << jsonData
                        return
                    }
                }
                noSelectFreightNos = freightNos - selectFreightNos
                if (noSelectFreightNos) {
                    noSelectFreightNos.each {
                        jsonData = new JSONData(success: false, alertMsg: "【${it}】订单不存在!", soundMsg: '不存在', data: null)
                        messages << jsonData
                    }
                }
                orderData = null
                render messages as JSON
            }
        } catch (RuntimeException e) {
            log.error(e)
            jsonData = new JSONData(success: false, alertMsg: "扫描失败,请重试!", data: null)
            messages << jsonData
            render messages as JSON
            return
        }
    }

    /**
     * 修改投递员
     */
    def confirm = {
        log.info(params)
        def jsonData
        def posterId = params?.poster.toLong()
        def orderIds = params?.ids.split(',')
        def user = session.getValue('user')
        try {
            orderService.posterUpdate(orderIds, posterId, user)
            jsonData = [success: true, alertMsg: "修改成功！"]
            render jsonData as JSON
        } catch (Exception e) {
            log.info(e.printStackTrace())
            jsonData = [success: false, alertMsg: "数据提交异常，请重试"]
            render jsonData as JSON
            return
        }

        return
    }

}
