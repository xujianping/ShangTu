package com.xujp.dj

import com.util.enums.*
import dj.BusinessException

import java.text.SimpleDateFormat

class OrderService {
    def sdfyMd = new SimpleDateFormat('yyyy-MM-dd')
    def sdfyMdHms = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss')
    def messageSource
    def springSecurityService
    /**
     * 根据站点获得子站的ids(包括本站)
     * @param station
     * @return
     */
    def getSelfChildIdsByStation(Station station) {
        def stationIds = '-1'

        station?.selfAndChildren?.each { st ->
            stationIds += ',' + st?.id.toString()
        }
        return stationIds
    }
/***
 * 单条
 * 中心录入订单并入库
 * @param freightNo
 * @return
 */
    def orderWareEnter(String freightNo) {
        def currentUser = springSecurityService?.currentUser
        def order = Order.findByFreightNo(freightNo)
        if (!order) {
            order = new Order()
            order.freightNo = freightNo
            order.orderType = OrderType.DELIVER_ORDER
            order.orderState = OrderState.WARE_ENTERED
            order.completeState = CompleteState.ON_WAY
            order.wareEnterDate = new Date()
            order.initialStation = Station.get(0)
            //保存历史记录
            def orderHistory = new OrderHistory(
                    [
                            oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                            operMsg   : HistoryType.WARE_ENTER_CONFIRM.toString(),
                            webMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                            companyMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                            sysMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                            remark:'',
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory)
            if (order.save(flush: true)) {
                return "入库成功"
            } else {
                def msg = ''
                order.errors.allErrors.each { error ->
                    msg += "<br/>" + messageSource.getMessage(error, Locale.default) + "!"
                }
                throw new BusinessException("订单【${freightNo}】错误${msg}")
            }
        } else if(order.orderType == OrderType.HQ_DEPLOY_ORDER){
                if(order.orderState != OrderState.DEPLOY_STATION_LEAVED ){
                    throw new BusinessException("订单【${freightNo}】状态为【${order.orderState}】,状态错误！")
                }
                if(!order.isComplete){
                    throw new BusinessException("订单【${freightNo}】信息未补全前禁止入库！")
                }
            order.completeState = CompleteState.ON_WAY
            order.wareEnterDate = new Date()
            order.orderState = OrderState.WARE_ENTERED
            //保存历史记录
            def orderHistory = new OrderHistory(
                    [
                            oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                            operMsg   : HistoryType.WARE_ENTER_CONFIRM.toString(),
                            webMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                            companyMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                            sysMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                            remark:'',
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory)
            if (order.save(flush: true)) {
                return "直调入库成功"
            } else {
                def msg = ''
                order.errors.allErrors.each { error ->
                    msg += "<br/>" + messageSource.getMessage(error, Locale.default) + "!"
                }
                throw new BusinessException("订单【${freightNo}】错误${msg}")
            }

        }else if(order.orderType == OrderType.DEPLOY_ORDER) {
            throw new BusinessException("订单【${freightNo}】为【${order.orderType}】,禁止中心入库。")
        }else{
            throw new BusinessException("订单【${freightNo}】为【配送单】已经录入并入库。")
        }
    }
/***
 * 批量
 * 中心录入订单并入库
 * @param orders
 * @return
 */
    def wareBatchEnter(def orders) {
        def currentUser = springSecurityService?.currentUser
        orders.each{freightNo->
            def order = Order.findByFreightNo(freightNo)
            if(order){
                order.completeState = CompleteState.ON_WAY
                order.orderState = OrderState.WARE_ENTERED
                order.deployEnterDate = new Date()
                //保存历史记录
                def orderHistory = new OrderHistory(
                        [
                                oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                                operMsg   : HistoryType.WARE_ENTER_CONFIRM.toString(),
                                webMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                                companyMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                                sysMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                                remark:'',
                                orderInfo : order.orderType.toString()
                        ]
                )
                order.addToOrderHistorys(orderHistory)
                order.save(flush: true)
            }else{
                order =   new Order()
                order.freightNo = freightNo
                order.orderType = OrderType.DELIVER_ORDER
                order.orderState = OrderState.WARE_ENTERED
                order.completeState = CompleteState.ON_WAY
                order.wareEnterDate = new Date()
                order.initialStation = Station.get(0)
                //保存历史记录
                def orderHistory = new OrderHistory(
                        [
                                oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                                operMsg   : HistoryType.WARE_ENTER_CONFIRM.toString(),
                                webMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                                companyMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                                sysMsg: HistoryType.WARE_ENTER_CONFIRM.toString(),
                                remark:'',
                                orderInfo : order.orderType.toString()
                        ]
                )
                order.addToOrderHistorys(orderHistory)
                order.save(flush: true)
            }
        }
    }

/***
 * 货品出库
 * @param order
 * @param params
 * @return
 */

    def wareLeave(Order order, def params){
        def currentUser = springSecurityService?.currentUser
        order.wareLeaveDate = new   Date()
        order.wareLeaveBatch = params.batchNo
        order.wareLeavePackNo =  params.packingNo
        if(order.orderType == OrderType.DELIVER_ORDER){
            order.targetStation = Station.get(params.stationId.toLong())
        }
        order.orderState = OrderState.WARE_LEAVED
        //保存历史记录
        def orderHistory = new OrderHistory(
                [
                        oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                        operMsg   : HistoryType.WARE_LEAVED_CONFIRM.toString(),
                        webMsg: HistoryType.WARE_LEAVED_CONFIRM.toString(),
                        companyMsg: HistoryType.WARE_LEAVED_CONFIRM.toString(),
                        sysMsg: HistoryType.WARE_LEAVED_CONFIRM.toString(),
                        remark:'',
                        orderInfo : order.orderType.toString()
                ]
        )
        order.addToOrderHistorys(orderHistory)
        order.save(flush: true)
    }

    /***
     * 补全订单信息
     */
//    def completeOrder(def is){
//        def times = System.currentTimeMillis()
//        def currentUser = springSecurityService?.currentUser
//        def orderExcelImporter = new OrderExcelImporter(is)
//        List<Map> list = orderExcelImporter.orders
//        def freightNos = []
//
//        if (list.empty) {
//            throw new BusinessException('未取到文件中的数据.请检查文件!')
//        }else {
//            list.each { map ->
//                freightNos << map['freightNo']
//            }
//            if (freightNos.unique().size() != list.size()) {
//                throw new BusinessException("文件中有运单号重复！")
//            }
//            list.each { map ->
//                if(!map['companyName']){
//                    throw new BusinessException("序列号为${map['importNo']}的公司名不能为空")
//                }else if(!Company.findByCompanyName(map['companyName'])){
//                    throw new BusinessException("序列号为${map['importNo']}的公司不存在")
//                }
//                if(!map['freightNo']){
//                    throw new BusinessException("序列号为${map['importNo']}的运单号不能为空")
//                }
//                if(!map['startCity']){
//                    throw new BusinessException("序列号为${map['importNo']}的发出城市不能为空")
//                }
//                if(!map['endCity']){
//                    throw new BusinessException("序列号为${map['importNo']}的收货城市不能为空")
//                }
//                if(!map['customerCode']){
//                    throw new BusinessException("序列号为${map['importNo']}的收货店铺代码不能为空")
//                }
//                if(!map['customer']){
//                    throw new BusinessException("序列号为${map['importNo']}的收货人不能为空")
//                }
//                if(!map['address']){
//                    throw new BusinessException("序列号为${map['importNo']}的地址不能为空")
//                }
//                if(!map['weight']){
//                    throw new BusinessException("序列号为${map['importNo']}的重量不能为空")
//                }
//                if(!map['volume']){
//                    throw new BusinessException("序列号为${map['importNo']}的体积不能为空")
//                }
//                def order
//                order = Order.findByFreightNo(map['freightNo'])
//                if(!order){
//                    throw new BusinessException("序列号为${map['importNo']}的订单不存在")
//                }else if(order.isComplete){
//                    throw new BusinessException("序列号为${map['importNo']}的订单信息已经补全")
//                }else{
//                    if(!order.targetStation){
//                        throw new BusinessException("序列号为${map['importNo']}的订单还未指派目标站点，不能补录")
//                    }
//                    order.company = Company.findByCompanyName(map['companyName'])
//                    order.startCity  =map['startCity']
//                    order.carrier = map['carrier']
//                    order.companyCode = map['companyCode']
//                    order.carrierFreightNo = map['carrierFreightNo']
//                    order.endCity = map['endCity']
//                    order.customerCode = map['customerCode']
//                    order.customer =map['customer']
//                    order.address = map['address']
//                    order.phoneNo = map['phoneNo']
//                    order.operationType = map['operationType']
//                    order.boxNum = map['boxNum'].toBigDecimal()
//                    order.packageNum = map['packageNum'].toBigDecimal()
//                    order.otherNum = map['otherNum'].toBigDecimal()
//                    order.goodsName = map['goodsName']
//                    order.receivable = map['receivable'].toBigDecimal()
//                    order.cost = map['receivable'].toBigDecimal()
//                    order.weight = map['weight'].toBigDecimal()
//                    order.volume = map['volume'].toBigDecimal()
//                    order.remark1 = map['remark1']
//                    order.isComplete = true
//                    //保存历史记录
//                    def orderHistory = new OrderHistory(
//                            [
//                                    oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
//                                    operMsg   : HistoryType.ORDER_COMPLETE.toString(),
//                                    webMsg:'',
//                                    companyMsg: '',
//                                    sysMsg:'',
//                                    remark:'',
//                                    orderInfo : order.orderType.toString()
//                            ]
//                    )
//                    order.addToOrderHistorys(orderHistory)
//                    order.save(flush: true)
//                }
//            }
//        }
//        def endTimes = System.currentTimeMillis()
//        log.info("总单数：[${list.size()}]条,补录成功，耗时：${(endTimes - times) / 1000 / 60}分")
//        return "总单数：[${list.size()}]条,补录成功，耗时：${(endTimes - times) / 1000 / 60}分"
//
//    }
/***
 * 站点入库
 * @param orderMap
 */
    def stationEnter(def orderMap){
        def currentUser = springSecurityService?.currentUser
        def order = Order.load(orderMap['id'])
        order.stationEnterDate = new Date()
        order.orderState = OrderState.STATION_ENTERED
        //保存历史记录
        def orderHistory = new OrderHistory(
                [
                        oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                        operMsg   : HistoryType.STATION_ENTER_CONFIRM.toString(),
                        webMsg: HistoryType.STATION_ENTER_CONFIRM.toString(),
                        companyMsg: HistoryType.STATION_ENTER_CONFIRM.toString(),
                        sysMsg: HistoryType.STATION_ENTER_CONFIRM.toString(),
                        remark:'',
                        orderInfo : order.orderType.toString()
                ]
        )
        order.addToOrderHistorys(orderHistory)
        order.save(flush: true)
    }

    /***
     * 站点出库
     *
     */
    def stationLeave(def orderMap,def poster){
        def order =  Order.load(orderMap['id'])
        order.orderState = OrderState.STATION_LEAVED
        order.stationLeaveDate = new Date()
//        order.poster = poster
//        //保存历史记录
//        def orderHistory = new OrderHistory(
//                [
//                        oper      : "${springSecurityService?.currentUser?.realname}【${springSecurityService?.currentUser?.station?.stationName}】",
//                        operMsg   : HistoryType.DISPATCH_POSTER.toString(),
//                        webMsg:HistoryType.DISPATCH_POSTER.toString(),
//                        companyMsg: HistoryType.DISPATCH_POSTER.toString(),
//                        sysMsg:HistoryType.DISPATCH_POSTER.toString(),
//                        remark:'',
//                        orderInfo : order.orderType.toString()
//                ]
//        )
//        order.addToOrderHistorys(orderHistory)
        //保存历史记录
        def orderHistory1 = new OrderHistory(
                [
                        oper      : "${springSecurityService?.currentUser?.realname}【${springSecurityService?.currentUser?.station?.stationName}】",
                        operMsg   : HistoryType.STATION_LEAVED_CONFIRM.toString(),
                        webMsg: HistoryType.STATION_LEAVED_CONFIRM.toString(),
                        companyMsg: HistoryType.STATION_LEAVED_CONFIRM.toString(),
                        sysMsg: HistoryType.STATION_LEAVED_CONFIRM.toString(),
                        remark:'',
                        orderInfo : order.orderType.toString()
                ]
        )
        order.addToOrderHistorys(orderHistory1)
        order.save(flush: true)
    }

    /***
     * 站点批量出库
     */
    def stationLeaveBath(def orders,def poster){
        orders.each{order->
            order.orderState = OrderState.STATION_LEAVED
            order.stationLeaveDate = new Date()
//            order.poster = poster
//            //保存历史记录
//            def orderHistory = new OrderHistory(
//                    [
//                            oper      : "${springSecurityService?.currentUser?.realname}【${springSecurityService?.currentUser?.station?.stationName}】",
//                            operMsg   : HistoryType.DISPATCH_POSTER.toString(),
//                            webMsg:HistoryType.DISPATCH_POSTER.toString(),
//                            companyMsg: HistoryType.DISPATCH_POSTER.toString(),
//                            sysMsg:HistoryType.DISPATCH_POSTER.toString(),
//                            remark:'',
//                            orderInfo : order.orderType.toString()
//                    ]
//            )
//            order.addToOrderHistorys(orderHistory)
            //保存历史记录
            def orderHistory1 = new OrderHistory(
                    [
                            oper      : "${springSecurityService?.currentUser?.realname}【${springSecurityService?.currentUser?.station?.stationName}】",
                            operMsg   : HistoryType.STATION_LEAVED_CONFIRM.toString(),
                            webMsg: HistoryType.STATION_LEAVED_CONFIRM.toString(),
                            companyMsg: HistoryType.STATION_LEAVED_CONFIRM.toString(),
                            sysMsg: HistoryType.STATION_LEAVED_CONFIRM.toString(),
                            remark:'',
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory1)
            order.save(flush: true)
        }
    }

    /**
     * 查找订单集合
     * @param searchList
     * @param searchType
     * @return
     */

    def searchOrders(def searchList, def searchType) {
        def timeStyle = "yyyy-MM-dd hh24:mi:ss"
        def dateStyle = "yyyy-MM-dd"

        Calendar calendar = Calendar.getInstance();
        Calendar now = Calendar.getInstance();
        calendar.add(Calendar.MONTH, -3);

        def sql = """
                select  new map(o.id as id,o.address as address,o.freightNo as freightNo,o.isFinished as finished,o.completeState as completeState,
                o.orderState as orderState,o.orderType as orderType,c.companyName as companyName,
                o.customer as customer,p.posterName as posterName,o.receivable as receivable,
                o.payable as payable,o.goodsName as goodsName,o.targetStation.id as stationId)
                from Order o left join o.company c left join o.poster p
                 where 1=1
                and o.dateCreated >= to_date('${sdfyMdHms.format(calendar.time)}','${timeStyle}')
                and o.dateCreated <= to_date('${sdfyMdHms.format(now.time)}','${timeStyle}')
                """
        if (searchType == 'Scanning') {
            sql = sql + "and o.freightNo in (${searchList.get('freightNos').join(",")})"
        } else if (searchType == 'timeOuted') {
            sql += """
                and od.completeState = '${searchList.get('completeState').name()}'
                and od.goodsState = '${searchList.get('goodsState').name()}'
                and od.finished = ${searchList.get('finished')}
                and od.station.id in (${searchList.get('stationIds').join(',')})
             """
        } else if (searchType == 'searched') {
            searchList.each { m ->
                if (m.key == 'companyId' && m.value) {
                    sql += "and o.company.id = ${m.value} "
                }
                if (m.key == 'address' && m.value) {
                    sql += "and o.address like '%${m.value}%' "
                }
                if (m.key == 'stime' && m.value) {
                    sql += "and od.stationLeaveDate >= to_date('${m.value}','${timeStyle}') "
                }
                if (m.key == 'etime' && m.value) {
                    sql += "and od.stationLeaveDate <= to_date('${m.value}','${timeStyle}') "
                }
                if (m.key == 'goodsState') {
                    sql += "and od.goodsState =  '${m.value.name()}' "
                }
                if (m.key == 'finished') {
                    sql += "and od.finished =  ${m.value} "
                }
                if (m.key == 'poster' && m.value) {
                    sql += "and od.poster.id = ${m.value} "
                }
                if (m.key == 'stationIds') {
                    sql += "and od.station.id in(${m.value.join(',')}) "
                }
                if (m.key == 'completeState') {
                    sql += "and od.completeState <>  '${m.value.name()}' "
                }
            }

        } else if (searchType == 'completeSearch') {
            searchList.each { m ->
                if (m.key == 'finished') {
                    sql += "and o.isFinished =  ${m.value} "
                }
                if (m.key == 'stime' && m.value) {
                    sql += "and o.stationLeaveDate >= to_date('${m.value}','${timeStyle}') "
                }
                if (m.key == 'etime' && m.value) {
                    sql += "and o.stationLeaveDate <= to_date('${m.value}','${timeStyle}') "
                }
                if (m.key == 'poster' && m.value) {
                    sql += "and o.poster.id = ${m.value} "
                }
                if (m.key == 'stationIds') {
                    sql += "and o.targetStation.id in(${m.value.join(',')}) "
                }
                if (m.key == 'freightNo' && m.value) {
                    sql += "and( o.freightNo =  '${m.value}')"
                }
                sql += "and( o.orderState = 'STATION_LEAVED')"
            }
        }
        def orderData = Order.executeQuery(sql, [])
        return orderData
    }
/***
 * 订单提交妥投
 * @param ids
 * @return
 */
    def orderComplete(def ids){
        def currentUser = springSecurityService?.currentUser
        ids.split(',').each{id->
            def order = Order.load(id)
            order.finishedDate = new Date()
            order.orderState = OrderState.STATION_LEAVED
            order.completeState = CompleteState.COMPLETED
            order.isFinished = true

            //保存历史记录
            def orderHistory = new OrderHistory(
                    [
                            oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                            operMsg   : HistoryType.FINISH_COLLECTED.toString(),
                            webMsg: HistoryType.FINISH_COLLECTED.toString(),
                            companyMsg: HistoryType.FINISH_COLLECTED.toString(),
                            sysMsg: HistoryType.FINISH_COLLECTED.toString(),
                            remark:'',
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory)
            order.save(flush: true)
        }
    }

    /***
     * 单条
     * 站点录入订单并入库
     * 普通直调订单或者是中心直调
     * @param freightNo
     * @return
     */
    def deployStationEnter(String freightNo,def orderType) {
        def currentUser = springSecurityService?.currentUser
        def order = Order.findByFreightNo(freightNo)
        if (!order) {
            order = new Order()
            order.freightNo = freightNo
            order.orderType = orderType
            order.orderState = OrderState.DEPLOY_STATION_ENTERED
            order.completeState = CompleteState.ON_WAY
            order.deployStationEnterDate = new Date()
            order.initialStation = currentUser?.station
            //保存历史记录
            def orderHistory = new OrderHistory(
                    [
                            oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                            operMsg   : HistoryType.DEPLOY_STATION_ENTER_CONFIRM.toString(),
                            webMsg:"",
                            companyMsg: "",
                            sysMsg: HistoryType.DEPLOY_STATION_ENTER_CONFIRM.toString(),
                            remark:'',
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory)
            if (order.save(flush: true)) {
                return "入库成功"
            } else {
                def msg = ''
                order.errors.allErrors.each { error ->
                    msg += "<br/>" + messageSource.getMessage(error, Locale.default) + "!"
                }
                throw new BusinessException("订单【${freightNo}】错误${msg}")
            }
        } else  {
            throw new BusinessException("订单【${freightNo}】已存在")
        }
    }

    /***
     * 直调货品出库
     * @param order
     * @param params
     * @return
     */

    def deployStationLeave(Order order, def params){
        def currentUser = springSecurityService?.currentUser
        order.deployStationLeaveDate = new   Date()
        order.stationLeaveBatch = params.batchNo
        order.stationLeavePackNo =  params.packingNo
//        order.targetStation = Station.get(params.stationId.toLong())
        order.orderState = OrderState.DEPLOY_STATION_LEAVED
        //保存历史记录
        def orderHistory = new OrderHistory(
                [
                        oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                        operMsg   : HistoryType.DEPLOY_STATION_LEAVED_CONFIRM.toString(),
                        webMsg: HistoryType.WARE_LEAVED_CONFIRM.toString(),
                        companyMsg: HistoryType.DEPLOY_STATION_LEAVED_CONFIRM.toString(),
                        sysMsg: HistoryType.DEPLOY_STATION_LEAVED_CONFIRM.toString(),
                        remark:'',
                        orderInfo : order.orderType.toString()
                ]
        )
        order.addToOrderHistorys(orderHistory)
        order.save(flush: true)
    }

    /**
     * 订单删除
     * @param oreders
     * @param freightNos
     */
    def deleteOrder(def orders, def freightNos) {
        orders.each { order ->
            order.delete()
        }
        log.info("${springSecurityService?.currentUser?.realname}删除订单：${freightNos.replaceAll('\\r\\n', ',')}")
    }

    /***
     * 订单提交异常终结
     * @param ids
     * @param reason
     * @param remark
     * @return
     */
    def orderAbnormal(def ids,def reason,def remark){
        def currentUser = springSecurityService?.currentUser
        ids.split(',').each{id->
            def order = Order.load(id)
            order.finishedDate = new Date()
            order.orderState = OrderState.STATION_LEAVED
            order.completeState = CompleteState.ABNORMAL_FINISHED
            order.abnormalRemark = reason+remark
            order.isFinished = true

            //保存历史记录
            def orderHistory = new OrderHistory(
                    [
                            oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                            operMsg   : HistoryType.ERROR_END.toString(),
                            webMsg: HistoryType.ERROR_END.toString(),
                            companyMsg: HistoryType.ERROR_END.toString(),
                            sysMsg: HistoryType.ERROR_END.toString(),
                            remark:reason+remark,
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory)
            order.save(flush: true)
        }
    }
/****
 * 订单拒收
 * @param ids
 * @param reason
 * @param remark
 * @return
 */
    def orderReject(def ids,def reason,def remark){
        def currentUser = springSecurityService?.currentUser
        ids.split(',').each{id->
            def order = Order.load(id)
            order.finishedDate = new Date()
            order.orderState = OrderState.STATION_LEAVED
            order.completeState = CompleteState.REJECTED
            order.abnormalRemark = reason+remark
            order.isFinished = true

            //保存历史记录
            def orderHistory = new OrderHistory(
                    [
                            oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                            operMsg   : HistoryType.SUBMIT_REJECT.toString(),
                            webMsg: HistoryType.SUBMIT_REJECT.toString(),
                            companyMsg: HistoryType.SUBMIT_REJECT.toString(),
                            sysMsg: HistoryType.SUBMIT_REJECT.toString(),
                            remark:reason+remark,
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory)
            order.save(flush: true)
        }
    }

/**
 * 订单基本信息修改
 * @param order
 * @param params
 * @return
 */
    def orderUpdate(Order order, def params) {
        log.info(params)
        def currentUser = springSecurityService?.currentUser
        if (!order) {
            throw new BusinessException("数据错误！请重试!")
        }
        order.orderNo = params?.orderNo
        def updateStr = "修改内容："
        if (order.orderType.toString() != OrderType.getType(params.orderType)) {
            updateStr+="订单类型--原来内容【${order.orderType.toString()}】现在内容【${OrderType.getType(params.orderType).toString()}】"
            order.orderType = OrderType.getType(params.orderType)
        }
        order.targetStation = Station.get(params?.targetStation.toLong())
        order.initialStation = Station.get(params?.initialStation.toLong())
        order.customer = params?.customer
        order.address = params?.address
        order.company = Company.get(params?.company.toLong())
        order.goodsName = params?.goodsName
        order.phoneNo = params?.phoneNo
        order.receivable = params?.receivable.toBigDecimal()
        order.weight = params?.weight.toBigDecimal()
        order.volume = params?.volume.toBigDecimal()
        order.cost = params?.cost.toBigDecimal()
        order.orderState = params?.orderState
        order.completeState = params?.completeState
        order.isFinished = params?.isFinished.toInteger()
        order.boxNum = params?.boxNum.toInteger()
        order.packageNum = params?.packageNum.toInteger()
        order.otherNum = params?.otherNum.toInteger()
        order.remark1 = params?.remark1
        //保存历史记录
        def orderHistory = new OrderHistory(
                [
                        oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                        operMsg   : HistoryType.ORDER_UPDATE.toString(),
                        webMsg:'',
                        companyMsg: '',
                        sysMsg: HistoryType.ORDER_UPDATE.toString(),
                        remark:'',
                        orderInfo : order.orderType.toString()
                ]
        )
        order.addToOrderHistorys(orderHistory)
        order.save(flush: true)
        return true
    }
/****
 * 投递员修改
 * @param orderIds
 * @param posterId
 * @param user
 */
    def posterUpdate(def orderIds, def posterId, def user){
        def oper = "${user?.realname}【${user?.station?.stationName}】"
        Poster poster = Poster.get(posterId.toLong())
        orderIds.each{
            def order = Order.load(it.toLong())
            order.poster = poster
            //保存历史记录
            def orderHistory = new OrderHistory(
                    [
                            oper      : oper,
                            operMsg   : HistoryType.UPDATE_POSTER.toString(),
                            webMsg:'',
                            companyMsg: '',
                            sysMsg: HistoryType.UPDATE_POSTER.toString(),
                            remark:'',
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory)
            order.save(flush: true)
        }
    }

    /**
     * 提交之前查询
     * @param orderIds
     * @return
     */

    def searchBeforeConfirm(def orderIds) {
        def timeStyle = "yyyy-MM-dd hh24:mi:ss"
        def dateStyle = "yyyy-MM-dd"

        Calendar calendar = Calendar.getInstance();
        Calendar now = Calendar.getInstance();
        calendar.add(Calendar.MONTH, -3);

        def sql = """
                select  new map(o.id as id,o.address as address,o.freightNo as freightNo,o.isFinished as finished,o.completeState as completeState,
                o.orderState as orderState,o.orderType as orderType,c.companyName as companyName,
                o.customer as customer,p.posterName as posterName,o.receivable as receivable,
                o.payable as payable,o.goodsName as goodsName,o.targetStation.id as stationId)
                from Order o left join o.company c left join o.poster p
                 where 1=1
                and o.dateCreated >= to_date('${sdfyMdHms.format(calendar.time)}','${timeStyle}')
                and o.dateCreated <= to_date('${sdfyMdHms.format(now.time)}','${timeStyle}')
                and o.id = ?
                """
        def orderDate = Order.executeQuery(sql, [orderIds.toLong()])
        return orderDate
    }


    def orderCompleteOther(def ids,def acceptor){
        def currentUser = springSecurityService?.currentUser
        ids.split(',').each{id->
            def order = Order.load(id)
            order.finishedDate = new Date()
            order.orderState = OrderState.STATION_LEAVED
            order.completeState = CompleteState.COMPLETED
            order.isFinished = true
            order.completeName = acceptor
            //保存历史记录
            def orderHistory = new OrderHistory(
                    [
                            oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
                            operMsg   : HistoryType.FINISH_COLLECTED.toString(),
                            webMsg: HistoryType.FINISH_COLLECTED.toString(),
                            companyMsg: HistoryType.FINISH_COLLECTED.toString(),
                            sysMsg: HistoryType.FINISH_COLLECTED.toString(),
                            remark:'',
                            orderInfo : order.orderType.toString()
                    ]
            )
            order.addToOrderHistorys(orderHistory)
            order.save(flush: true)
        }
    }

    /***
     * 补全直调类订单信息
     */
//    def completeDeployOrder(def is){
//        def times = System.currentTimeMillis()
//        def currentUser = springSecurityService?.currentUser
//        def orderExcelImporter = new DeployOrderExcelImporter(is)
//        List<Map> list = orderExcelImporter.orders
//        def freightNos = []
//
//        if (list.empty) {
//            throw new BusinessException('未取到文件中的数据.请检查文件!')
//        }else {
//            list.each { map ->
//                freightNos << map['freightNo']
//            }
//            if (freightNos.unique().size() != list.size()) {
//                throw new BusinessException("文件中有运单号重复！")
//            }
//            list.each { map ->
//                if(!map['companyName']){
//                    throw new BusinessException("序列号为${map['importNo']}的公司名不能为空")
//                }else if(!Company.findByCompanyName(map['companyName'])){
//                    throw new BusinessException("序列号为${map['importNo']}的公司不存在")
//                }
//                if(!map['freightNo']){
//                    throw new BusinessException("序列号为${map['importNo']}的运单号不能为空")
//                }
//                if(!map['startCity']){
//                    throw new BusinessException("序列号为${map['importNo']}的发出城市不能为空")
//                }
//                if(!map['endCity']){
//                    throw new BusinessException("序列号为${map['importNo']}的收货城市不能为空")
//                }
//                if(!map['customerCode']){
//                    throw new BusinessException("序列号为${map['importNo']}的收货店铺代码不能为空")
//                }
//                if(!map['customer']){
//                    throw new BusinessException("序列号为${map['importNo']}的收货人不能为空")
//                }
//                if(!map['address']){
//                    throw new BusinessException("序列号为${map['importNo']}的地址不能为空")
//                }
//                if(!map['weight']){
//                    throw new BusinessException("序列号为${map['importNo']}的重量不能为空")
//                }
//                if(!map['volume']){
//                    throw new BusinessException("序列号为${map['importNo']}的体积不能为空")
//                }
//                if(!map['stationName']){
//                    throw new BusinessException("序列号为${map['importNo']}的目标站点不能为空")
//                }
//                def order
//                order = Order.findByFreightNo(map['freightNo'])
//                if(!order){
//                    throw new BusinessException("序列号为${map['importNo']}的订单不存在")
//                }else if(order.isComplete){
//                    throw new BusinessException("序列号为${map['importNo']}的订单信息已经补全")
//                }else{
//                    def station = Station.findByStationNameAndStationType(map['stationName'], StationType.ST)
//                    if(!station){
//                        throw new BusinessException("序列号为${map['importNo']}的目标站点不存在，请正确填写！")
//                    }
//                    order.targetStation = station
//                    order.company = Company.findByCompanyName(map['companyName'])
//                    order.startCity  =map['startCity']
//                    order.carrier = map['carrier']
//                    order.companyCode = map['companyCode']
//                    order.carrierFreightNo = map['carrierFreightNo']
//                    order.endCity = map['endCity']
//                    order.customerCode = map['customerCode']
//                    order.customer =map['customer']
//                    order.address = map['address']
//                    order.phoneNo = map['phoneNo']
//                    order.operationType = map['operationType']
//                    order.boxNum = map['boxNum'].toBigDecimal()
//                    order.packageNum = map['packageNum'].toBigDecimal()
//                    order.otherNum = map['otherNum'].toBigDecimal()
//                    order.goodsName = map['goodsName']
//                    order.receivable = map['receivable'].toBigDecimal()
//                    order.cost = map['receivable'].toBigDecimal()
//                    order.weight = map['weight'].toBigDecimal()
//                    order.volume = map['volume'].toBigDecimal()
//                    order.remark1 = map['remark1']
//                    order.isComplete = true
//                    //保存历史记录
//                    def orderHistory = new OrderHistory(
//                            [
//                                    oper      : "${currentUser?.realname}【${currentUser?.station?.stationName}】",
//                                    operMsg   : HistoryType.ORDER_COMPLETE.toString(),
//                                    webMsg:'',
//                                    companyMsg: '',
//                                    sysMsg:'',
//                                    remark:'',
//                                    orderInfo : order.orderType.toString()
//                            ]
//                    )
//                    order.addToOrderHistorys(orderHistory)
//                    order.save(flush: true)
//                }
//            }
//        }
//        def endTimes = System.currentTimeMillis()
//        log.info("总单数：[${list.size()}]条,补录成功，耗时：${(endTimes - times) / 1000 / 60}分")
//        return "总单数：[${list.size()}]条,补录成功，耗时：${(endTimes - times) / 1000 / 60}分"
//
//    }

}
