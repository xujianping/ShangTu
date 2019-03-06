package com.xujp.dj

import com.util.JSONData
import com.util.enums.StationType
import com.xujp.dj.Order
import com.xujp.dj.Poster
import com.xujp.dj.Station
import grails.converters.JSON

import java.text.SimpleDateFormat

/***
 * 打印配送单
 */
class PrintDeliveryListController {
    def springSecurityService
    def orderService
    def index() {
        def sdf = new SimpleDateFormat('yyyy-MM-dd')
        def stations = springSecurityService.currentUser?.station?.selfAndChildren
        def notManagerStation = []
        stations.each { stat ->
            if (stat.stationType == StationType.ST) {
                notManagerStation << stat
            }
        }
        render(view: 'index', model: [startDate: "${sdf.format(new Date())} 00:00:00", endDate: "${sdf.format(new Date())} 23:59:59", stations: notManagerStation])
    }

    /**
     * 根据站点ID取快递人员
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

    def print = {
        def sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
//        def posterId = params?.posterId
        def ids = params?.ids
        def startDate = params?.startDate
        def endDate = params?.endDate
        def stationIds = session.getValue('stationIds')
//        def posterName = Poster.get(posterId.toLong())?.posterName
        def sql = """
            select new map(o.id as id ,c.companyName as companyName,o.stationLeaveDate as stationLeaveDate,
             o.freightNo as freightNo ,o.customer as customer,o.address as address,
             o.orderType as orderType,o.receivable as receivable,o.phoneNo as phoneNo
            ) from Order o  left join o.company c where
            o.targetStation.id in (${stationIds.join(",")})
        """
        if (ids)
            sql += " and o.id in (${ids})"
        if (params?.startDate) {
            sql+= " and o.stationLeaveDate >= to_date('${params?.startDate}','yyyy-MM-dd hh24:mi:ss')"
        }
        if (params?.endDate) {
            sql+= " and o.stationLeaveDate <=  to_date('${params?.endDate}','yyyy-MM-dd hh24:mi:ss')"
        }
//        if (posterId) {
//            sql+= " and o.poster.id = ${posterId}"
//        }
        def orderData = Order.executeQuery(sql,[])

        render(view: 'print', model: [orders: orderData, oper: session.getValue('user')?.realname])
    }

}
