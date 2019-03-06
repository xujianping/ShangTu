package com.xujp.dj

import com.util.JSONData
import com.util.enums.CompleteState
import com.util.enums.OrderState
import com.xujp.dj.Order
import com.xujp.dj.Poster
import dj.BusinessException
import grails.converters.JSON

import java.text.SimpleDateFormat

/***
 * 订单妥投
 */
class OrderCompleteController {
    def springSecurityService
    def orderService

    def index() {
        def sdf = new SimpleDateFormat('yyyy-MM-dd')
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

    /**
     * 保存妥投已收款
     */
    def saveFinishd = {
        def jsonData = [success: true]
        try {
            def orderData = Order.executeQuery("select new map(o.id as id ,o.isFinished as isFinished, o.freightNo as freightNo ,o.orderType as orderType,o.company.companyName as companyName, o.completeState as completeState , o.orderState as orderState) from Order o  where o.id in (${params.ids})", [])

            def hasError = false
            for (def orderMap in orderData) {
                if (orderMap.isFinished) {
                    jsonData = [success: false, alertMsg: "【${orderMap['freightNo']}】已经完成不能提交!"]
                    render jsonData as JSON
                    hasError = true
                    break
                }
                if (orderMap.orderState != OrderState.STATION_LEAVED) {
                    jsonData = [success: false, alertMsg: "【${orderMap['freightNo']}】状态为${orderMap.orderState}不能提交!"]
                    render jsonData as JSON
                    hasError = true
                    break
                }
                if (orderMap.completeState == CompleteState.REJECTED || orderMap.completeState == CompleteState.ABNORMAL_FINISHED || orderMap.completeState == CompleteState.COMPLETED) {
                    jsonData = [success: false, alertMsg: "【${orderMap['freightNo']}】状态为${orderMap.completeState}不能提交!"]
                    render jsonData as JSON
                    hasError = true
                    break
                }
            }
            orderService.orderComplete( params?.ids)
            jsonData = new JSONData(success: true)
            render jsonData as JSON
            return
        }
        catch (BusinessException e) {
            jsonData = new JSONData(success: false, alertMsg: e.message, soundMsg: '已收款')
            render jsonData as JSON
            return
        } catch (Exception e) {
            log.error(e.printStackTrace())
            jsonData = new JSONData(success: false, alertMsg: "保存妥投已收款失败,请重试!", soundMsg: '错误')
            render jsonData as JSON
            return
        }
    }


    /**
     *  查询订单单条妥投扫描
     */
    def scanningOrder = {
        def jsonData = [success: true]
        try {
            def stationIds = session.getValue('stationIds')
            def freightNos = []
            freightNos << "'${params?.freightNo.trim()}'"
            def searchList = ['freightNos': freightNos]
            def orderData = orderService.searchOrders(searchList, 'Scanning')
            if (!orderData) {
                jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】订单不存在!", soundMsg: '无信息', data: null)
                render jsonData as JSON
                return
            } else {
                def orderMap = orderData.get(0)
                if (!stationIds.contains(orderMap['stationId'])) {
                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】不属于本站点!", soundMsg: '不属于本站点', data: null)
                    render jsonData as JSON
                    return
                }
//                if (!orderMap['posterName']) {
//                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】无投递人员，请分配投递人员!", soundMsg: '失败', data: null)
//                    render jsonData as JSON
//                    return
//                }
                if (orderMap['finished']) {
                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】已完!不能提交!", soundMsg: '失败', data: null)
                    render jsonData as JSON
                    return
                }
                if (orderMap['completeState'] != CompleteState.ON_WAY) {
                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】完成状态为${orderMap['completeState']}!不能提交!", soundMsg: '失败', data: null)
                    render jsonData as JSON
                    return
                }

                if (orderMap['orderState'] == OrderState.STATION_LEAVED) {
                    jsonData = new JSONData(success: true, alertMsg: "【${params?.freightNo}】扫描成功!", soundMsg: '成功', data: orderMap)
                    render jsonData as JSON
                    return
                } else {
                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】订单状态为${orderMap['orderState']},不能妥投!", soundMsg: '失败', data: null)
                    render jsonData as JSON
                    return
                }
            }

        } catch (RuntimeException e) {
            log.error(e)
            jsonData = new JSONData(success: false, alertMsg: "扫描失败,请重试!", soundMsg: '错误')
            render jsonData as JSON
            return
        }
    }

    /**
     *  查询订单批量妥投
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
            def orderData = orderService.searchOrders(searchList, 'Scanning')
            if (!orderData) {
                jsonData = new JSONData(success: false, alertMsg: "所有订单不存在!", soundMsg: '错误', data: null)
                messages << jsonData
                render messages as JSON
                return
            } else {
                orderData.each { orderMap ->
                    selectFreightNos << orderMap['freightNo']

                    if (!stationIds.contains(orderMap['stationId'])) {
                        jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】不属于本站点!", soundMsg: '不属于本站点', data: null)
                        messages << jsonData
                        return
                    }
//                    if (!orderMap['posterName']) {
//                        jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】无投递人员，请分配投递人员!", soundMsg: '失败', data: null)
//                        messages << jsonData
//                        return
//                    }
                    if (orderMap['finished']) {
                        jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】已完成!不能提交!", soundMsg: '失败', data: null)
                        messages << jsonData
                        return
                    }
                    if (orderMap['completeState'] != CompleteState.ON_WAY) {
                        jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】完成状态为${orderMap['completeState']}!不能提交!", soundMsg: '失败', data: null)
                        messages << jsonData
                        return
                    }

                    if (orderMap['orderState'] == OrderState.STATION_LEAVED) {
                        jsonData = new JSONData(success: true, alertMsg: "【${orderMap['freightNo']}】扫描成功!", soundMsg: '成功', data: orderMap)
                        messages << jsonData
                        return
                    } else {
                        jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】订单状态为${orderMap['orderState']},不能妥投!", soundMsg: '失败', data: null)
                        messages << jsonData
                        return
                    }
                }
                noSelectFreightNos = freightNos - selectFreightNos
                if (noSelectFreightNos) {
                    noSelectFreightNos.each {
                        jsonData = new JSONData(success: false, alertMsg: "【${it}】订单不存在!", soundMsg: '订单不存在', data: null)
                        messages << jsonData
                    }
                }
                render messages as JSON
            }
        } catch (RuntimeException e) {
            log.error(e)
            jsonData = new JSONData(success: false, alertMsg: "扫描失败,请重试!", soundMsg: '错误', data: null)
            messages << jsonData
            render messages as JSON
            return
        }
    }
    /**
     * 查询订单
     */
    def searchOrder = {
        def jsonData = []
        def sdf = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss')
        try {
            def stationIds = session.getValue('stationIds')
            def searchList = []
            def orderData = []
            searchList = [
                    'stime': params?.startDate, 'etime': params?.endDate,
                    'finished': false, 'poster': params.poster, 'freightNo': params?.freightNo.trim(),
                    'stationIds': stationIds
            ]
            orderData = orderService.searchOrders(searchList, 'completeSearch')
            jsonData = new JSONData(success: true, data: orderData)
            render jsonData as JSON
        } catch (RuntimeException e) {
            log.error(e)
            jsonData = new JSONData(success: false, alertMsg: "查询失败,请检查数据后重试!", soundMsg: '错误', data: null)
            render jsonData as JSON
            return
        }
    }

    /**
     * 非本人签收保存妥投已收款
     */
    def otherAcceptSaveFinishCollected = {
        println params
        def jsonData = [success: true]
        try {
            def orderData = orderService.searchBeforeConfirm(params.ids)
            def stationIds = session.getValue('stationIds')
            orderData.each{orderMap->
//                if (!orderMap['posterName']) {
//                    jsonData = new JSONData(success: false, alertMsg: "【${params?.freightNo}】无投递人员，请分配投递人员!", soundMsg: '失败', data: null)
//                    render jso
// nData as JSON
//                    return
//                }
                if (orderMap['finished']) {
                    jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】已完!不能提交!", soundMsg: '失败', data: null)
                    render jsonData as JSON
                    return
                }
                if (orderMap['completeState'] != CompleteState.ON_WAY) {
                    jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】完成状态为${orderMap['completeState']}!不能提交!", soundMsg: '失败', data: null)
                    render jsonData as JSON
                    return
                }

                if (orderMap['orderState'] == OrderState.STATION_LEAVED) {
                    orderService.orderCompleteOther(params.ids,params?.acceptor) //非本人签收
                    jsonData = new JSONData(success: true, alertMsg: "【${orderMap['freightNo']}】提交成功!", soundMsg: '成功', data: null)
                    render jsonData as JSON
                    return
                } else {
                    jsonData = new JSONData(success: false, alertMsg: "【${orderMap['freightNo']}】订单状态为${orderMap['orderState']},不能妥投!", soundMsg: '失败', data: null)
                    render jsonData as JSON
                    return
                }
            }
        }
        catch (BusinessException e) {
            jsonData = new JSONData(success: false, alertMsg: e.message, soundMsg: '已收款')
            render jsonData as JSON
            return
        } catch (Exception e) {
            log.error(e.printStackTrace())
            jsonData = new JSONData(success: false, alertMsg: "保存妥投已收款失败,请重试!", soundMsg: '错误')
            render jsonData as JSON
            return
        }
    }
}
