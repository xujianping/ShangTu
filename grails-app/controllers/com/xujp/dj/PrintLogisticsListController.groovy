package com.xujp.dj

/***
 * 打印物流单
 */
import com.util.enums.OrderState
import com.xujp.dj.Order
import com.xujp.dj.Station
import grails.converters.JSON
import groovy.sql.Sql

import java.text.SimpleDateFormat

class PrintLogisticsListController {
    def springSecurityService
    def orderService
    def dataSource
    def index = {
        def sdf = new SimpleDateFormat('yyyy-MM-dd')
        render(view: 'index', model: [startDate: "${sdf.format(new Date())} 00:00:00", endDate: "${sdf.format(new Date())} 23:59:59"])
    }
    def notLeaveCount = {
        def jsonData
        def sqlStation = ""
        def sqlCompany = ""
        if (params?.stationId) {
            sqlStation = "and t.target_station_id = ${params?.stationId.toLong()}"
        }
        def ids = []
        if (params?.companyId instanceof String[]) {
            params?.companyId?.each { id ->
                ids << id
            }
        } else {
            params?.companyId?.split(',').each { id ->
                ids << id
            }
        }
        if (ids.indexOf('-1') == -1) {
            sqlCompany = "and  t.company_id in (${ids.join(',')})"
        }
        OrderState
        def sql_str = """
            select count(t.id) as COUNT  from dj_order t where
             t.order_state in('WARE_ENTERED')
            """ + sqlCompany + """
            """ + sqlStation + """
        """
        println(sql_str)
        Sql sql = new Sql(dataSource)
        def sum = sql.rows(sql_str)[0].COUNT
        if (sum) {
            jsonData = [success: false, alertMsg: "还有${sum}单未出库，是否打印？"]
        } else {
            jsonData = [success: false, alertMsg: "本站点全部出库，是否打印？"]
        }
        sql.close()
        render jsonData as JSON
        return

    }

    def print = {
        def sdf = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss')
        def sqlCompany = ""
        def ids = []
        if (params?.companyId instanceof String[]) {
            params?.companyId?.each { id ->
                ids << id
            }
        } else {
            params?.companyId?.split(',').each { id ->
                ids << id
            }
        }

        if (ids.indexOf('-1') == -1) {
            sqlCompany = " and o.company.id in (${ids.join(',')})"
        }
        def station = Station.get(params?.stationId?.toLong())

        def list = Order.executeQuery("""
            select  new map( c.companyName as companyName,
              o.wareLeaveDate as wareLeaveDate,
              o.freightNo as freightNo,
              o.wareLeavePackNo as wareLeavePackNo,
              o.customer as  customer,
              o.address as address,o.orderType as orderType,
              o.receivable as receivable
            ) from Order o left join  o.company as c
            where 1=1
            and o.wareLeaveDate >= to_date('${params?.startDate}','yyyy-MM-dd hh24:mi:ss')
             and o.wareLeaveDate <=  to_date('${params?.endDate}','yyyy-MM-dd hh24:mi:ss')
             and o.targetStation.id =${params?.stationId}
            ${sqlCompany}
            """, [])

        render(view: 'print', model: [stationName: station?.stationName, values: list, oper: springSecurityService?.currentUser?.realname])
    }
}
