package com.xujp.dj.auth

import com.util.JSONData
import com.xujp.dj.auth.RequestMap
import grails.converters.JSON

class RequestMapController {
    static allowedMethods = [delete: "POST"]
    def exportService

    def index = {
        render(view: "/requestMap/list", params: params)
    }

    /**
     * 查询列表
     */
    def list = {
        params.offset = params.start
        params.max = params.limit

        def filter = searchCondition(params)

        def data = RequestMap.createCriteria().list(params, filter)
        def jsonData = new JSONData(data: data, totalCount: RequestMap.createCriteria().count(filter))
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
            def requestMap

            if (isNew) {
                requestMap = new RequestMap(params)
            } else {
                requestMap = RequestMap.get(params.id)
                if (!requestMap) {
                    jsonData = [success: false]
                    render jsonData as JSON
                    return
                }
                requestMap.properties = params
            }

            if (requestMap.save(flush: true)) {
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
            def requestMap = RequestMap.get(params.id)

            if (requestMap) {
                try {
                    requestMap.delete(flush: true)
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
            def requestMap = RequestMap.get(params.id)
            if (!requestMap) {
                jsonData = new JSONData(success: false)
                render jsonData as JSON
                return;
            } else {
                def dataInfo = [success: true, data: requestMap]
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
    }

    /**
     * 查询封装
     * @param params
     * @return
     */
    def searchCondition(params) {
        def filter = {
            if (params?.bookName) {
                ilike("bookName", "")
            }

        }
        return filter
    }
}
