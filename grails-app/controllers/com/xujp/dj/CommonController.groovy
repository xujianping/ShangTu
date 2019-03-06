package com.xujp.dj

import com.util.Menu
import com.xujp.dj.auth.Role
import grails.converters.JSON
import groovy.xml.StreamingMarkupBuilder

/**
 * 公用页面（都有权限访问）
 */
class CommonController {

    def index={}

    def station = {
        def stationId = params?.stationId == null || params?.stationId == '' ? 0 : params?.stationId
        def selectType = params?.selectType == null ? 'ALL' : params?.selectType
        def station = Station.get(stationId?.toLong())
        def menu = new Menu(station, selectType)
        render menu as JSON
    }


    def roles = {
        def result = Role.list([sort: 'id']).collect {
            [id: it.id, name: it.name]
        }
        render result as JSON
    }
    /**
     * 获取历史记录列表
     */
    def getList(def freightNo) {
        def list = []
        Calendar calendar = Calendar.instance
        calendar.add(Calendar.MONTH, -3)
        list = OrderHistory.executeQuery("""
            select new map(oh.order.id as id,oh.operMsg as operMsg,oh.dateCreated as dateCreated,oh.oper as oper)
            from OrderHistory oh where oh.order.id = (
            select o.id from Order o where o.freightNo = ?
            )
            and oh.dateCreated  >=?
            and oh.dateCreated  <=?
            order by oh.dateCreated asc
        """, [freightNo, calendar.getTime(), new Date()])
        return list
    }

    def searchOrder = {
        def outType = params?.outType ? params?.outType : 'xml'
        def freightNo = params?.freightNo

        if (!freightNo) {
            render "运单号不能为空"
            return
        }
//        List<OrderHistory> orderHistoryList = OrderHistory.createCriteria().list {
//            order {
//                eq("freightNo", freightNo)
//            }
//            order('dateCreated', 'asc')
//        }
//
//        orderHistoryList.unique(new OrderHistoryComparator("operMsg"))
        def orderHistoryList = null
        orderHistoryList = getList(freightNo)
        if (outType.equalsIgnoreCase('json')) {
            def jsonStr = []
            if (orderHistoryList) {
                orderHistoryList?.each { orderHistory ->
                    def res = []
                    res = [date: orderHistory.dateCreated.format('yyyy-MM-dd HH:mm:ss'),
                           desc: orderHistory?.operMsg+" 查询电话：【028-87483229】", oper: orderHistory?.oper]
                    jsonStr.add(orderHis: res)
                }
                def order = Order.findByFreightNo(freightNo)
                def otherStr = ""
                if(order.isFinished){
                    otherStr =  order.completeName?order.completeName:'本人签收'
                }
                jsonStr.add(orthers: otherStr)
                orderHistoryList = null
            } else {
                def res = [date: '',
                           desc: '未查到相关数据，请联系电商公司！', oper: '']
                jsonStr.add(orderHis: res)
                jsonStr.add(orthers: "")

            }
            String callbackName = params?.jsoncallback
            def s = jsonStr as JSON
            String renderStr = callbackName + "(" + s + ")"
            render(contentType: 'text/plain;charset=UTF-8"', text: renderStr)
            return
        } else if (outType.equalsIgnoreCase('html')) {
            String html = "<table>"
            if (orderHistoryList) {
                orderHistoryList?.each { orderHistory ->
                    html += "<tr>"
                    html += "<td>${orderHistory.dateCreated.format('yyyy-MM-dd HH:mm:ss')}</td>"
                    html += "<td>${orderHistory?.operMsg} 查询电话：【028-87483229】</td>"
                    html += "<td>${orderHistory?.oper}</td>"
//                    if (orderHistory?.webMsg) {
//                        if (orderHistory?.operMsg == HistoryType.DISPATCH_POSTER.toString()) {
//                            def poster = Order.load(orderHistory.id).orderDelivery.poster
//                            html += "<td>${orderHistory.dateCreated.format('yyyy-MM-dd HH:mm:ss')}</td>"
//                            html += "<td>配送员【${poster?.posterName}】已经取件,正在配送.查询电话：【${poster?.mobileNo}】</td>"
//                            html += "<td>${orderHistory?.oper}</td>"
//                        } else if (orderHistory?.operMsg == HistoryType.WARE_ENTER_CONFIRM.toString() || orderHistory?.operMsg == HistoryType.WARE_LEAVED_CONFIRM.toString()) {
//                            html += "<td>${orderHistory.dateCreated.format('yyyy-MM-dd HH:mm:ss')}</td>"
//                            html += "<td>${orderHistory?.webMsg} 查询电话：【4000285666】</td>"
//                            html += "<td>${orderHistory?.oper}</td>"
//                        } else if (orderHistory?.operMsg == HistoryType.STATION_ENTER_CONFIRM.toString()) {
//                            def queryOrder = Order.findByFreightNo(freightNo);
//                            def phone = queryOrder.orderDelivery.station.phone
//                            def msg = orderHistory?.webMsg
//                            if (phone) {
//                                msg = msg + " 查询电话：【" + phone + "】"
//                            }
//                            html += "<td>${orderHistory.dateCreated.format('yyyy-MM-dd HH:mm:ss')}</td>"
//                            html += "<td>" + msg + "</td>"
//                            html += "<td>${orderHistory?.oper}</td>"
//                        } else {
//                            html += "<td>${orderHistory.dateCreated.format('yyyy-MM-dd HH:mm:ss')}</td>"
//                            html += "<td>${orderHistory?.webMsg}</td>"
//                            html += "<td>${orderHistory?.oper}</td>"
//                        }
//                    }
                    html += "</tr>"
                }
                orderHistoryList = null
            } else {
                html += "<tr>"
                html += "<td>&nbsp;</td>"
                html += "<td>未查到相关数据，请联系电商公司！</td>"
                html += "<td>&nbsp;</td>"
                html += "</tr>"
            }
            html += "</table>"
            render html
            return
        } else {
            def xml = new StreamingMarkupBuilder()
            xml.encoding = 'UTF-8'
            def s = {
                mkp.xmlDeclaration()
                orderHis() {
                    if (orderHistoryList) {
                        orderHistoryList?.each { orderHistory ->
                            date(orderHistory.dateCreated.format('yyyy-MM-dd HH:mm:ss'))
                            desc(orderHistory?.operMsg + " 查询电话：【028-87483229】")
                            oper(orderHistory?.oper)
                        }
                        orderHistoryList = null
                    } else {
                        date('')
                        desc('未查到相关数据，请联系电商公司！')
                        oper('')
                    }
                }
            }
            render(contentType: 'application/xml', text: xml.bind(s)?.toString())
            return
        }
    }

}
