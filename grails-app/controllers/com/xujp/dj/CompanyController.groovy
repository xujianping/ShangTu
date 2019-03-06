package com.xujp.dj

import com.util.JSONData
import grails.converters.JSON

class CompanyController {
    static allowedMethods = [delete: "POST"]

    def index = {
        render(view: "/company/list", params: params)
    }

    /**
     * 查询列表
     */
    def list = {
        params.offset = params.start
        params.max = params.limit

        def filter = searchCondition(params)
        def data = Company.createCriteria().list(params, filter)
        def jsonData = new JSONData(data: data, totalCount: Company.createCriteria().count(filter))
        render jsonData as JSON
    }

    /**
     * 保存
     */
    def save = {
        def jsonData = [success: true]
        boolean isNew = (params?.id == null || params?.id == "")
        try {
            def company

            if (isNew) {
                company = new Company(params)
            } else {
                company = Company.get(params.id)
                if (!company) {
                    jsonData = [success: false]
                    render jsonData as JSON
                    return
                }
                company.properties = params
            }

            if (company.save(flush: true)) {
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
            def company = Company.get(params.id)

            if (company) {
                try {
                    company.delete(flush: true)
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
            def company = Company.get(params.id)
            if (!company) {
                jsonData = new JSONData(success: false)
                render jsonData as JSON
                return;
            } else {
                def dataInfo = [success: true, data: company]
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
        def filter = {
            if (params?.bookName) {
                ilike("bookName", "")
            }
        }
        return filter
    }
}
