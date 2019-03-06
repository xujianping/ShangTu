package com.xujp.dj

import com.util.JSONData
import com.util.enums.OrderState
import com.util.enums.StationType
import grails.converters.JSON

class StationLeaveController {
    def springSecurityService
    def orderService
    def shortMessageService
    def vipShopPhoneService

    def index() {
        def stations = springSecurityService.currentUser?.station?.selfAndChildren
        def notManagerStation = []
        stations.each { stat ->
            if (stat.stationType == StationType.ST) {
                notManagerStation << stat
            }
        }
        render(view: 'index', model: [stations: notManagerStation])
    }

    /**
     * 根据配点ID取快递人员
     */
    def getPosterByStation = {
        def jsonData = [success: true]
        def list = []
        try {
            def stationId = params?.stationId
            list = Poster.findAllByStationAndEnabled(Station.get(stationId?.toLong()), true, [sort: 'posterName', order: 'asc'])
            jsonData = new JSONData(success: true, alertMsg: "获取快递员成功!", data: list)
            render jsonData as JSON
            return
        } catch (Exception e) {
            log.error("获取快递员失败！" + e.printStackTrace())
            jsonData = new JSONData(success: false, alertMsg: "获取快递员失败", data: list)
            render jsonData as JSON
            return
        }
    }

    /**
     * 站点出库
     */
    def save = {
        def jsonData = [success: true]
        def orderData = []
        Calendar calendar = Calendar.instance
        calendar.add(Calendar.MONTH, -3)
        try {
//            def stationId = params?.stationId
            orderData = Order.executeQuery("""
             select new map(t.id as id,t.freightNo as freightNo,t.targetStation as targetStation,
                t.orderType as orderType,t.orderState as orderState,t.customer as customer,c.companyName as companyName,
                t.address as address,t.goodsName as goodsName,t.phoneNo as phoneNo,
                t.receivable as receivable,t.payable as payable,t.targetStation.id as stationId,t.isFinished as isFinished
             ) from Order t left join t.company c where
              t.freightNo = ?
              and t.dateCreated>=?
              and t.dateCreated <= ?
              and t.isFinished = ?
            """, [params?.freightNo.trim(),calendar.getTime(), new Date(),false])

            if (!orderData) {
                jsonData = new JSONData(success: false, alertMsg: "订单【${params?.freightNo}】不存在！", soundMsg: '无信息')
                render jsonData as JSON
                return
            }else{
                def orderMap = orderData.get(0)
//                if (orderMap['stationId'] != params?.stationId.toLong()) {
//                    jsonData = new JSONData(success: false, alertMsg: "订单【${params?.freightNo}】不属于本站点！", soundMsg: "不属于本站")
//                    render jsonData as JSON
//                    return
//                }
                if (orderMap['orderState'] != OrderState.STATION_ENTERED) {
                    jsonData = new JSONData(success: false, alertMsg: "订单【${params?.freightNo}】状态为${orderMap['orderState']}！", soundMsg: "状态错误")
                    render jsonData as JSON
                    return
                }
                println(orderMap)
                if (orderMap['isFinished']) {
                    jsonData = new JSONData(success: false, alertMsg: "订单【${params?.freightNo}】已完成！", soundMsg: "已完成")
                    render jsonData as JSON
                    return
                }
                def poster = Poster.get(params?.posterId)
                orderService.stationLeave(orderMap,poster)
                def data = ['id': orderMap['id'], 'freightNo': orderMap['freightNo'], 'orderType': orderMap['orderType'], 'customer': orderMap['customer'],
                            'mobileNo': orderMap['phoneNo'], 'receivable': orderMap['receivable'],'companyName': orderMap['companyName'], 'goodsName': orderMap['goodsName'],
                            'address': orderMap['address']]
                jsonData = new JSONData(success: true, alertMsg: "${orderMap['orderType']}站点出库成功", soundMsg: "成功${orderMap['orderType']}", data: data)
                render jsonData as JSON
                return

            }

        } catch (Exception e) {
            log.error(e)
            jsonData = new JSONData(success: false, alertMsg: "站点出库失败,请重试!", soundMsg: '错误')
            render jsonData as JSON
            return
        }
    }

    /***
     * 批量出库
     */

    def batchSave = {
        def jsonData
        def failMessage = ""
        def num = 0
        def data = []
        def resultData = []
        def sendOrders = []
//        def poster = Poster.get(params?.posterId)
        def poster

        def freightNosList = []
        Calendar calendar = Calendar.instance
        calendar.add(Calendar.MONTH, -3)
        try {
            params?.freightNos.eachLine { freightNo ->
                if (!freightNo.trim())
                    return
                num++
                freightNosList << "'${freightNo.trim()}'"
            }
                def orders = Order.executeQuery("""
             select new map(t.id as id,t.freightNo as freightNo,t.targetStation as targetStation,
                t.orderType as orderType,t.orderState as orderState,t.customer as customer,t.company.companyName as companyName,
                t.address as address,t.goodsName as goodsName,
                t.receivable as receivable,t.targetStation.id as stationId,t.isFinished as isFinished
             ) from Order t where
              t.freightNo in (${freightNosList.join(',')})
              and t.dateCreated>=?
              and t.dateCreated <= ?
              and t.isFinished = ?
            """, [calendar.getTime(), new Date(),false])
            if (!orders) {
                jsonData = new JSONData(success: false, alertMsg: "所有订单不存在或不符合出库条件", data: null)
                render jsonData as JSON
                return
            } else {
                orders.each {
//                    if (it['stationId'] != params?.stationId.toLong()) {
//                        failMessage += "【${it['freightNo']}】不属于本站点!\r\n"
//                        return
//                    }

                    if (it['orderState'] != OrderState.STATION_ENTERED) {
                        failMessage += "【${it['freightNo']}】状态为${it['orderState']}!\r\n"
                        return
                    }
                    if (it['isFinished']) {
                        failMessage += "【${it['freightNo']}】已经完成!\r\n"
                        return
                    }
                    def order = Order.get(it['id'])
                    sendOrders << order
                    def values = ['id': it['id'], 'freightNo': it['freightNo'], 'orderType': it['orderType'], 'customer': it['customer'],
                                   'receivable': it['receivable'], 'payable': it['payable'], 'companyName': it['companyName'], 'goodsName': it['goodsName'],
                                  'address': it['address']]

                    resultData << values
                }

                if (!failMessage) {
                    orderService.stationLeaveBath(sendOrders,poster)
                    jsonData = new JSONData(success: true, alertMsg: failMessage, data: resultData, totalCount: num, remarkMsg: resultData.size())
                    render jsonData as JSON
                    return
                }else{
                    jsonData = new JSONData(success: false, alertMsg: failMessage)
                    render jsonData as JSON
                    return
                }

            }
        }catch (Exception e){
            log.error(e.printStackTrace())
            jsonData = new JSONData(success: false, alertMsg: "出库失败,请重试!", data: null)
            render jsonData as JSON
            return
        }

    }

    }
