package com.xujp.dj

import com.util.JSONData
import com.util.enums.CompleteState
import com.util.enums.OrderState
import com.util.enums.OrderType
import com.xujp.dj.Order
import com.xujp.dj.OrderHistory
import com.xujp.dj.Station
import grails.converters.JSON
import groovy.time.TimeCategory

import java.text.SimpleDateFormat

class OrderController {
    static allowedMethods = [delete: "POST"]
    def springSecurityService
    def orderService
    def timeSdf = new SimpleDateFormat('yyyy-MM-dd HH:mm:ss')
    def sdf = new SimpleDateFormat('yyyy-MM-dd')
    def timeStyle = "yyyy-MM-dd hh24:mi:ss"
    def exportService
    def index = {
        def now = new Date()
        def day = sdf.format(now)
        params.startDate = "${day} 00:00:00"
        params.endDate = "${day} 23:59:59"
        use(TimeCategory) {
            params.beginDepartureDate = "${sdf.format(now - 3.months)} 00:00:00"
        }
        render(view: "/order/list", params: params, model: [station: springSecurityService?.currentUser?.station])
    }

    /**
     * 查询列表
     */
    def list = {
        params.offset = params.start
        params.max = params.limit

        def filter = searchCondition(params)
        def datas = Order.createCriteria().list(params, filter)
        def dataList = []
        datas.each {data->
            dataList << [id:data?.id,freightNo:data?.freightNo,orderType:data?.orderType,
                         initialStation:data?.initialStation?.stationName,targetStation:data?.targetStation?.stationName,
                         customer:data?.customer,customerCode:data?.customerCode,phoneNo:data?.phoneNo,
                         company:data?.company?.companyName,companyCode:data?.company?.companyCode,goodsName:data?.goodsName,
                         orderState:data?.orderState, completeState:data?.completeState, isComplete:data?.isComplete,
                         isFinished:data?.isFinished,isAbnormal:data?.isAbnormal,abnormalReasion:data?.abnormalReasion,
                         boxNum:data?.boxNum,packageNum:data?.packageNum,otherNum:data?.otherNum,remark1:data?.remark1,
                         remark2:data?.remark2,completeName:data?.completeName,receivable:data?.receivable
            ]
        }
        def jsonData = new JSONData(data: dataList, totalCount: Order.createCriteria().count(filter))
        render jsonData as JSON
    }
    /**
     *   根据订单号查订单历史信息
     */
    def orderHistoryInfo = {
        def jsonData
        try {
            def orderHistoryList = OrderHistory.findAllByOrder(Order.get(params?.orderId), [sort: "dateCreated", order: "asc"])
            jsonData = [success: true, data: orderHistoryList]
        } catch (Exception e) {
            jsonData = new JSONData(success: false)
        }
        render jsonData as JSON
    }
    /**
     * 保存
     */
    def save = {
        def jsonData = [success: true]
        boolean isNew = (params?.id == null || params?.id == "")
        try {
            def order

            if (isNew) {
                order = new Order(params)
            } else {
                order = Order.get(params.id)
                if (!order) {
                    jsonData = [success: false]
                    render jsonData as JSON
                    return
                }
                order.properties = params
            }

            if (order.save(flush: true)) {
                render jsonData as JSON
                return
            } else {
                if (isNew) {
                    jsonData = [success: false, alertMsg: '新增信息验证失敗,请重新输入!']
                    render jsonData as JSON
                    return
                } else {
                    jsonData = [success: false, alertMsg: '修改信息失败']
                    render jsonData as JSON
                    return
                }
            }
        } catch (org.springframework.dao.OptimisticLockingFailureException e) {
            log.error(e.getMessage());
            if (isNew) {
                jsonData = [success: false, alertMsg: '新增信息失敗,数据已被其它操作修改,请重试!']
                render jsonData as JSON
                return
            } else {
                jsonData = [success: false, alertMsg: '修改信息失敗,数据已被其它操作修改,请重试!']
                render jsonData as JSON
                return
            }
        }
        catch (Exception e) {
            log.error(e.getMessage());
            if (isNew)
                jsonData = [success: false, alertMsg: '新增信息失敗,请检查数据后重新输入!']
            else
                jsonData = [success: false, alertMsg: '修改信息失敗,请检查数据后重新输入!']
        }

        render jsonData as JSON;
    }

    /**
     * 刪除
     */
    def delete = {
        def jsonData = [success: true]

        try {
            def order = Order.get(params.id)

            if (order) {
                try {
                    order.delete(flush: true)
                    render jsonData as JSON
                    return
                }
                catch (org.springframework.dao.DataIntegrityViolationException e) {
                    jsonData = [success: false, alertMsg: "删除失败,该记录关联其它数据!"]
                    render jsonData as JSON
                    return
                }
            } else {
                jsonData = [success: false, alertMsg: "删除失败,未知错误!"]
                render jsonData as JSON
                return
            }
        } catch (Exception e) {
            jsonData = [success: false, alertMsg: "删除失败,未知错误!"]
            render jsonData as JSON
            return
        }
    }

    /**
     * 顯示
     */
    def show = {
        def jsonData
        try {
            def order = Order.get(params.id)
            if (!order) {
                jsonData = new JSONData(success: false)
                render jsonData as JSON
                return;
            } else {
                def orderData = [id:order?.id,freightNo:order?.freightNo,orderNo:order?.orderNo,enabled:order?.enabled,
                              operationType:order?.operationType,orderType:order?.orderType,companyCode1: order?.companyCode,
                             initialStation:order?.initialStation?.stationName,targetStation:order?.targetStation?.stationName,
                             customerCode:order?.customerCode, customer:order?.customer,address:order?.address,phoneNo:order?.phoneNo,
                             company:order?.company?.companyName,companyCode:order?.company?.companyCode,  startCity:order?.startCity,endCity:order?.endCity,goodsName:order?.goodsName,
                             receivable:order?.receivable,payable:order?.payable,volume:order?.volume,weight:order?.weight,
                             boxNum:order?.boxNum,packageNum:order?.packageNum,otherNum:order?.otherNum,remark1:order?.remark1,
                             orderState:order?.orderState,completeState:order?.volume,completeState:order?.completeState,
                             abnormalRemark:order?.abnormalRemark,pickupDate:order?.pickupDate,wareEnterDate:order?.wareEnterDate,wareLeaveDate:order?.wareLeaveDate,
                             stationEnterDate:order?.stationEnterDate,stationLeaveDate:order?.stationLeaveDate,deployEnterDate:order?.deployStationEnterDate,
                             deployLeaveDate:order?.deployStationLeaveDate,finishedDate:order?.finishedDate, isFinished:order?.isFinished,
                             isAbnormal:order?.isAbnormal,abnormalReasion:order?.abnormalReasion,isComplete:order?.isComplete,remark2:order?.remark2,
                              completeName:order?.completeName
                ]
                def dataInfo = [success: true, data: orderData]
                render dataInfo as JSON
                return
            }
        } catch (Exception e) {
            jsonData = new JSONData(success: false)
        }

        render jsonData as JSON
    }

    /**
     * 查询封装
     * @param params
     * @return
     */
    def searchCondition(params) {
        println(params)
        Station currentStation = springSecurityService.currentUser?.station
        def stationIds = null
        if (currentStation?.id != 0) {
            stationIds = currentStation.getSelfAndChildren().id
        }
        def filter = {
            if (stationIds) {
                or{
                    targetStation{
                        inList("id", stationIds)
                    }
                    initialStation{
                        inList("id", stationIds)
                    }
                }
            }
            if(params?.freightNoSearch){
                ilike('freightNo',"${params?.freightNoSearch}%")
            }
            if(params?.orderNoSearch){
                ilike('orderNo',"${params?.orderNoSearch}%")
            }
            if (params?.orderTypeSearch) {
                def orderTypes = []
                if (params?.orderTypeSearch instanceof String[]) {
                    params?.orderTypeSearch.each { id ->
                        orderTypes << OrderType.getType(id)
                    }
                } else {
                    params?.orderTypeSearch.split(',').each { id ->
                        orderTypes << OrderType.getType(id)
                    }
                }
                inList("orderType", orderTypes)
            }

            if (params?.companySearch) {
                def ids = []
                if (params?.companySearch instanceof String[]) {
                    params?.companySearch?.each { id ->
                        ids << id
                    }
                } else {
                    params?.companySearch?.split(',').each { id ->
                        ids << id
                    }
                }
                sqlRestriction("company_id in (${ids.join(',')})")
            }
            if (params?.targetStationSearch) {
                def station
                def ids = []
                params?.targetStationSearch.split(",").each { stationId ->
                    station = Station.load(stationId?.toLong())
                    ids << orderService.getSelfChildIdsByStation(station)
                }
                    sqlRestriction("target_station_id in (${ids.join(',')})")
            }
            if (params?.initialStationSearch) {
                def station
                def ids = []
                params?.initialStationSearch.split(",").each { stationId ->
                    station = Station.load(stationId?.toLong())
                    ids << orderService.getSelfChildIdsByStation(station)
                }
                sqlRestriction("initial_station_id in (${ids.join(',')})")
            }

            if (params?.orderStateSearch) {
                def orderState = []
                if (params?.orderStateSearch instanceof String[]) {
                    params?.orderStateSearch.each { id ->
                        orderState << OrderState.getType(id)
                    }
                } else {
                    params?.orderStateSearch.split(',').each { id ->
                        orderState << OrderState.getType(id)
                    }
                }
                inList("orderState", orderState)
            }
            if (params?.completeStateSearch) {
                def completeState = []
                if (params?.completeStateSearch instanceof String[]) {
                    params?.completeStateSearch.each { id ->
                        completeState << CompleteState.getType(id)
                    }
                } else {
                    params?.completeStateSearch.split(',').each { id ->
                        completeState << CompleteState.getType(id)
                    }
                }
                inList("completeState", completeState)
            }
            if(params?.customerSearch){
                ilike('customer',"${params?.customerSearch}%")
            }
            if(params?.addressSearch){
                ilike('address',"${params?.addressSearch}%")
            }
            if(params?.mobileNoSearch){
                ilike('mobileNo',"${params?.mobileNoSearch}%")
            }
            if(params?.phoneNoSearch){
                ilike('phoneNo',"${params?.phoneNoSearch}%")
            }
            if(params?.goodsNameSearch){
                ilike('goodsName',"${params?.goodsNameSearch}%")
            }
            if (params?.volumeSearch) {
                try {
                    BigDecimal volume = new BigDecimal(params.volumeSearch)
                    eq("volume", volume)
                } catch (Exception e) {}
            }
            if (params?.weightSearch) {
                try {
                    BigDecimal weight = new BigDecimal(params.weightSearch)
                    eq("weight", weight)
                } catch (Exception e) {}
            }
            if (params?.costSearch) {
                try {
                    BigDecimal cost = new BigDecimal(params.costSearch)
                    eq("cost", cost)
                } catch (Exception e) {}
            }
            if (params?.isFinishedSearch) {
                def finished = params?.isFinishedSearch
                    sqlRestriction("is_Finished = ${finishedSearch}")
            }
            if (params?.isCompleteSearch) {
                def isComplete = params?.isCompleteSearch
                sqlRestriction("is_Complete = ${isCompleteSearch}")
            }
            if (params?.isAbnormalSearch) {
                def isAbnormalSearch = params?.isAbnormalSearch
                sqlRestriction("is_Abnormal = ${isAbnormalSearch}")
            }
            if (params?.beginWareEnterDate) {
                def beginWareEnterDate = timeSdf.parse(params?.beginWareEnterDate)

                    ge("wareEnterDate", beginWareEnterDate)
            }
            if (params?.endWareEnterDate) {
                def endWareEnterDate = timeSdf.parse(params?.endWareEnterDate)

                    le("wareEnterDate", endWareEnterDate)
            }
            if (params?.beginWareLeaveDate) {
                def beginWareLeaveDate = timeSdf.parse(params?.beginWareLeaveDate)

                ge("wareLeaveDate", beginWareLeaveDate)
            }
            if (params?.endWareLeaveDate) {
                def endWareLeaveDate = timeSdf.parse(params?.endWareLeaveDate)

                le("wareLeaveDate", endWareLeaveDate)
            }
            if (params?.beginStationEnterDate) {
                def beginStationEnterDate = timeSdf.parse(params?.beginStationEnterDate)

                ge("stationEnterDate", beginStationEnterDate)
            }
            if (params?.endStationEnterDate) {
                def endStationEnterDate = timeSdf.parse(params?.endStationEnterDate)

                le("stationEnterDate", endStationEnterDate)
            }
            if (params?.beginStationLeaveDate) {
                def beginStationLeaveDate = timeSdf.parse(params?.beginStationLeaveDate)

                ge("stationLeaveDate", beginStationLeaveDate)
            }
            if (params?.endStationLeaveDate) {
                def endStationLeaveDate = timeSdf.parse(params?.endStationLeaveDate)

                le("stationLeaveDate", endStationLeaveDate)
            }
            if (params?.beginDeployEnterDate) {
                def beginDeployEnterDate = timeSdf.parse(params?.beginDeployEnterDate)

                ge("deployStationEnterDate", beginDeployEnterDate)
            }
            if (params?.endDeployEnterDate) {
                def endDeployEnterDate = timeSdf.parse(params?.endDeployEnterDate)

                le("deployStationEnterDate", endDeployEnterDate)
            }
            if (params?.freightNos) {
                def freghtNos = []
                params?.freightNos.eachLine { freightNo ->
                    freghtNos << "'" + freightNo + "'"
                }
                sqlRestriction("freight_No in (${freghtNos.join(',')})")
            }
            if(params?.abnormalReasionSearch){
                ilike('abnormalReasionSearch',"${params?.abnormalReasionSearch}%")
            }
        }

        return filter
    }

    /**
     * 导出
     */
    def export = {
        def filter = searchCondition(params)
        def orders = Order.createCriteria().list(params, filter)

        def colm = ['importNo', 'companyName', 'companyCodes', 'freightNo','startCity','companyCode','carrier','carrierFreightNo',
                    'endCity','customerCode','customer','phoneNo','address','operationType','boxNum','packageNum'
                    ,'otherNum','weight','volume','goodsName','receivable','remark1','stationName', 'completeName',
                    'wareEnterDate','wareLeaveDate','stationEnterDate','stationLeaveDate','deployEnterDate','deployLeaveDate',
                'deployStationEnterDate','deployStationLeaveDate', 'finishedDate','pickupDate']
        def tit = [importNo:'序号',companyName: '委托客户',companyCodes: '客户代码', freightNo: '工作单号', startCity: '发出城市',
                   companyCode: '发出店铺代码', carrier: '承运商', carrierFreightNo: '承运商单号',
                   endCity: '收货城市', customerCode: '收货店铺代码',customer: '收货人',phoneNo: '收货人电话',
                   address: '收货人地址', operationType: '操作性质',boxNum: '箱', packageNum: '包',
                   otherNum: '其它',weight: '重量', volume: '体积', goodsName: '货物品名',
                   receivable: '应收金额', remark1: '备注',stationName:'目标站点','completeName':'揽收人',
                   wareEnterDate:'中心入库日期',wareLeaveDate:'中心出库日期',stationEnterDate:'站点入库日期',
                   stationLeaveDate:'站点出库日期',deployEnterDate:'直调入库日期',deployLeaveDate:'直调出库日期',
                   deployStationEnterDate:'直调站点入库日期',deployStationLeaveDate:'直调站点出库日期',pickupDate:'收货日期',
                   'finishedDate':'完成时间']
        def datas = []
        def i = 0
        orders.each{order->
            i++
            datas << [importNo:i,companyName:order?.company?.companyName,companyCodes:order?.company?.companyCode,freightNo:order?.freightNo,
                      startCity:order?.startCity,companyCode:order?.companyCode,carrier:order?.carrier,
                      carrierFreightNo:order?.carrierFreightNo,endCity:order?.endCity,customerCode:order?.customerCode,
                      customer:order?.customer,phoneNo:order?.phoneNo,address:order?.address,operationType:order?.operationType,
                      boxNum:order?.boxNum,packageNum:order?.packageNum,otherNum:order?.otherNum,weight:order?.weight,
                      volume:order?.volume,goodsName:order?.goodsName,receivable:order?.receivable,remark1:order?.remark1,
                      stationName:order?.targetStation?.stationName,finishedDate:order?.finishedDate?timeSdf.format(order?.finishedDate):'',
                      deployEnterDate:order?.deployEnterDate?timeSdf.format(order?.deployEnterDate):'',
                      pickupDate:order?.pickupDate?timeSdf.format(order?.pickupDate):'',
                      wareEnterDate:order?.wareEnterDate?timeSdf.format(order?.wareEnterDate):'',
                      wareLeaveDate:order?.wareLeaveDate?timeSdf.format(order?.wareLeaveDate):'',
                      stationEnterDate:order?.stationEnterDate?timeSdf.format(order?.stationEnterDate):'',
                      stationLeaveDate:order?.stationLeaveDate?timeSdf.format(order?.stationLeaveDate):'',
                      deployLeaveDate:order?.deployLeaveDate?timeSdf.format(order?.deployLeaveDate):'',
                      deployStationEnterDate:order?.deployStationEnterDate?timeSdf.format(order?.deployStationEnterDate):'',
                      deployStationLeaveDate:order?.deployStationLeaveDate?timeSdf.format(order?.deployStationLeaveDate):'',
                      completeName:order.completeName]
        }
        if(datas.size() >= 30000){
            response.contentType = grailsApplication.config.grails.mime.types['csv']
            response.setHeader("Content-disposition", "attachment; filename=orders.csv")
            exportService.export("csv", response.outputStream, datas, colm, tit, [:], ["encoding": "gbk"]);
        }else{
            response.contentType = ConfigurationHolder.config.grails.mime.types['excel']
            response.setHeader("Content-disposition", "attachment; filename=orders.xls")
            exportService.export("excel", response.outputStream, datas, colm, tit, [:], [:]);
        }
        if (!response.outputStream){
            response.outputStream.close()
        }
        orders = null
    }
}
