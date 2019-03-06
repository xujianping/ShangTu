package com.xujp.dj

import com.util.JSONData
import com.xujp.dj.SystemParam
import com.xujp.dj.SystemParamGroup
import grails.converters.JSON

/**
 * 参数管理
 */
class ParamManagerController {
    def messageSource
    def springSecurityService
    def index = {}

    def listParams = {
        def paras = []
        def group = SystemParamGroup.get(params.id)
        if (group) {
            paras = SystemParam.findAllByGroup(group)
        }
        render new JSONData(success: true, data: paras) as JSON
    }

    def listGroups = {
        def jsonData = [success: true, data: SystemParamGroup.list()]
        render jsonData as JSON
    }

    def groupShow = {
        def jsonData
        try {
            def group = SystemParamGroup.get(params.id)
            if (!group) {
                jsonData = new JSONData(success: false)
                render jsonData as JSON
                return;
            } else {
                def dataInfo = [success: true, data: group]
                render dataInfo as JSON
                return
            }
        } catch (Exception e) {
            jsonData = new JSONData(success: false)
        }

        render jsonData as JSON
    }

    def groupSave = {
        def jsonData = [success: true]
        boolean isNew = (params?.id == null || params?.id == "")
        try {
            def group

            if (!params.groupName) {
                jsonData = [success: false, alertMsg: '参数组名不能为空，请先输入要增加的参数组名!']
                render jsonData as JSON
                return
            }
            if (isNew) {
                if (SystemParamGroup.findByGroupName(params.groupName)) {
                    jsonData = [success: false, alertMsg: '参数组名已经存在，请选择其他名称!']
                    render jsonData as JSON
                    return
                }
                group = new SystemParamGroup(params)
            } else {
                if (SystemParamGroup.findByIdNotEqualAndGroupName(params.id, params.groupName)) {
                    jsonData = [success: false, alertMsg: '参数组名已经存在，请选择其他名称!']
                    render jsonData as JSON
                    return
                }
                group = SystemParamGroup.get(params.id)
                if (!group) {
                    jsonData = [success: false]
                    render jsonData as JSON
                    return
                }
                group.properties = params
            }

            if (group.save(flush: true)) {
                jsonData = [success: true, id: group.id]
                render jsonData as JSON
                return
            } else {
                def msg = ''
                group.errors.allErrors.each { error ->
                    msg += "<br/>" + messageSource.getMessage(error, Locale.default)
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
    def groupDelete = {
        def jsonData = [success: true]

        try {
            def group = SystemParamGroup.get(params.id)

            if (group) {
                try {
                    SystemParam.findAllByGroup(group).each {
                        it.delete(flush: true)
                    }
                    group.delete(flush: true)
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

    def paramSave = {
        def jsonData = [success: true]
        boolean isNew = (params?.id == null || params?.id == "")
        try {
            def param

            if (!params.gId) {
                jsonData = [success: false, alertMsg: '请先选择参数分组!']
                render jsonData as JSON
                return
            }

            def group = SystemParamGroup.get(params.gId)
            if (!group) {
                jsonData = [success: false, alertMsg: '分组不存在!']
                render jsonData as JSON
                return
            }
            params.group = group;

            if (!params.paramCode) {
                jsonData = [success: false, alertMsg: '参数名称不能为空，请先输入要增加的参数名称!']
                render jsonData as JSON
                return
            }
            if (isNew) {
                if (SystemParam.findByParamCodeAndGroup(params.paramCode, group)) {
                    jsonData = [success: false, alertMsg: '参数名称已经存在，请选择其他名称!']
                    render jsonData as JSON
                    return
                }
                param = new SystemParam(params)
            } else {
                def ls = SystemParam.createCriteria().list {
                    ne('id', params.id.toLong())
                    eq('paramCode', params.paramCode)
                    eq('group', group)
                    maxResults(1)
                }
                if (ls && !ls.empty) {
                    jsonData = [success: false, alertMsg: '参数名称已经存在，请选择其他名称!']
                    render jsonData as JSON
                    return
                }
                param = SystemParam.get(params.id)
                if (!group) {
                    jsonData = [success: false]
                    render jsonData as JSON
                    return
                }
                param.properties = params
            }

            if (param.save(flush: true)) {
                jsonData = [success: true]
                render jsonData as JSON
                return
            } else {
                def msg = ''
                param.errors.allErrors.each { error ->
                    msg += "<br/>" + messageSource.getMessage(error, Locale.default)
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

    def paramShow = {
        def jsonData
        try {
            def param = SystemParam.get(params.id)
            if (!param) {
                jsonData = new JSONData(success: false)
                render jsonData as JSON
                return;
            } else {
                def dataInfo = [success: true, data: param]
                render dataInfo as JSON
                return
            }
        } catch (Exception e) {
            jsonData = new JSONData(success: false)
        }

        render jsonData as JSON
    }

    def paramDelete = {
        def jsonData = [success: true]

        try {
            def param = SystemParam.get(params.id)

            if (param) {
                try {
                    param.delete(flush: true)
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
}
