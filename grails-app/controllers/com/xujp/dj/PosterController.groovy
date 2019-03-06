package com.xujp.dj

import com.util.JSONData
import com.util.enums.StationType
import com.xujp.dj.Poster
import com.xujp.dj.Station
import grails.converters.JSON

/**
 * 配送员管理
 */
class PosterController {
    static allowedMethods = [delete: "POST"]
    def exportService
    def messageSource
    def springSecurityService
    def orderService

    def index = {
        def currentUser = springSecurityService.currentUser
        def currentStation = springSecurityService.currentUser?.station
        def stations = []
        currentStation.getSelfAndChildren().each { station ->
            if (station.stationType == StationType.ST) {
                stations << station
            }
        }
        render(view: "/poster/list", model: [ stations: stations])
    }

    /**
     * 查询列表
     */
    def list = {
        params.offset = params.start
        params.max = params.limit
        params['sort'] = 'id'
        params['order'] = 'desc'

        def filter = searchCondition(params)
        def datas = Poster.createCriteria().list(params, filter)
        def dataList = []
        datas.each {data->
            dataList << [id:data?.id,enabled:data?.enabled,posterName:data?.posterName,mobileNo:data?.mobileNo,
                         posLoginNo:data?.posLoginNo,station:data?.station?.stationName
            ]
        }
        def jsonData = new JSONData(data: dataList, totalCount: Poster.createCriteria().count(filter))

        //println(jsonData as JSON)
        render jsonData as JSON
    }

    /**
     * 保存
     */
    def save = {
        def jsonData = [success: true]
        boolean isNew = (params?.id == null || params?.id == "")
        try {
            params.enabled = !params?.enabled ? false : true
            def poster

            if (isNew) {
                poster = new Poster(params)
                def max = Poster.findByStation(poster.station, [sort: 'posLoginNo', order: 'desc'])
                if (max?.posLoginNo) {
                    poster.posLoginNo = (max.posLoginNo.toInteger() + 1).toString()
                } else {
                    poster.posLoginNo = poster.station.id + "001"
                }
                poster.posPwd = params.posPwd.encodeAsMD5()
            } else {
                poster = Poster.get(params.id)
                if (!poster) {
                    jsonData = [success: false]
                    render jsonData as JSON
                    return
                }
                if (params?.posPwd && params?.posPwd?.trim() != '') {
                    poster.posPwd = params.posPwd.encodeAsMD5()
                }
                poster.mobileNo = params?.mobileNo
                poster.posterName = params?.posterName
                if (!(params?.station?.id instanceof String[])) {
                    poster.station = Station.load(params?.station.id.toLong())
                }
                poster.enabled = params?.enabled
            }

            if (poster.save(flush: true)) {
                render jsonData as JSON
                return
            } else {
                def msg = ''
                poster.errors.allErrors.each { error ->
                    msg += "<br/>" + messageSource.getMessage(error, Locale.default) + "!"
                }
                if (isNew) {
                    jsonData = [success: false, alertMsg: "新增信息验证失敗,请重新输入!${msg}"]
                    render jsonData as JSON
                    return
                } else {
                    jsonData = [success: false, alertMsg: "修改信息失败!${msg}"]
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
            def poster = Poster.get(params.id)

            if (poster) {
                try {
                    poster.delete(flush: true)
                    render jsonData as JSON
                    return
                }
                catch (org.springframework.dao.DataIntegrityViolationException e) {
                    jsonData = [success: false, alertMsg: "删除失败,该记录关联其它数据!"]
                    render jsonData as JSON
                    return
                }
            }
            else {
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
            def poster = Poster.get(params.id)
            if (!poster) {
                jsonData = new JSONData(success: false)
                render jsonData as JSON
                return;
            } else {
                def dataInfo = [success: true, data: poster]
                render dataInfo as JSON
                return
            }
        } catch (Exception e) {
            jsonData = new JSONData(success: false)
        }

        render jsonData as JSON
    }

    /**
     * 导出
     */
    def export = {
        def filter = searchCondition(params)
        def posters = Poster.createCriteria().list(params, filter)
        response.contentType = ConfigurationHolder.config.grails.mime.types['excel']
        response.setHeader("Content-disposition", "attachment; filename=poster.xls")
        exportService.export("excel", response.outputStream, posters, ['id', 'actor', 'bookName'], [id: 'id', actor: '作者', bookName: '书名'], [:], [:]);
        if (!response.outputStream){
            response.outputStream.close()
        }
        posters = null
    }

    /**
     * 查询封装
     * @param params
     * @return
     */
    def searchCondition(params) {
//        def currentStation = springSecurityService.currentUser?.station
//        def stationIds = orderService.getSelfChildIdsByStation(currentStation)

        def filter = {
//            sqlRestriction("station_id in ( ${stationIds})")
            if (params?.posterName) {
                ilike("posterName", "%${params.posterName}%")
            }
            if (params?.posLoginNo) {
                ilike("posLoginNo", "%${params.posLoginNo}%")
            }

        }
        return filter
    }
}
