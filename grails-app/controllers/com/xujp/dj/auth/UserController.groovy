package com.xujp.dj.auth

import com.util.JSONData
import com.xujp.dj.auth.Role
import com.xujp.dj.auth.User
import com.xujp.dj.auth.UserRole
import grails.converters.JSON
import pl.touk.excel.export.WebXlsxExporter
import pl.touk.excel.export.getters.MessageFromPropertyGetter

class UserController {
    def springSecurityService
    static allowedMethods = [delete: "POST"]
    def exportService
    def messageSource

    def index = {
        render(view: "/user/list", params: params)
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
        def jsonData = new JSONData(data: User.createCriteria().list(params, filter).collect {
            [id: it.id, username: it.username, realname: it.realname, station: [id: it.station?.id, name: it.station?.stationName], roles: it.authorities
                    , password: it.password, manager: it.manager, accountExpired: it.accountExpired, accountLocked: it.accountLocked, enabled: it.enabled,
                    passwordExpired: it.passwordExpired, phoneColumns: it.phoneColumns
            ]
        }, totalCount: User.createCriteria().count(filter))

        render jsonData as JSON
    }

    /**
     * 保存
     */
    def save = {
        def jsonData = [success: true]
        boolean isNew = (params?.id == null || params?.id == "")
        try {
            params?.enabled = !params?.enabled ? false : true
            params?.manager = !params?.manager ? false : true
            if (params?.password)
                params.password = springSecurityService.encodePassword(params.password)

            def user
            if (isNew) {
                user = new User(params)
            } else {
                user = User.get(params.id)
                if (!user) {
                    jsonData = [success: false]
                    render jsonData as JSON
                    return
                }
                if (!params?.password)
                    params.password = user.password
                user.properties = params
                if (!params.phoneColumns)
                    user.phoneColumns = ''
            }

            if (user.save(flush: true)) {
                if (!isNew) {
                    UserRole.removeAll(user)
                }
                if (params.roles instanceof String) {
                    params.roles = [params.roles]
                }
                params.roles?.each {role ->
                    if (!UserRole.create(user, Role.get(role), true)) {
                        jsonData = [success: false, alertMsg: "设定角色失败"]
                        render jsonData as JSON
                        return
                    }
                }
                render jsonData as JSON
                return
            } else {
                def msg = ''
                user.errors.allErrors.each { error ->
                    msg += "<br/>" + messageSource.getMessage(error, Locale.default)
                }
                if (isNew) {
                    jsonData = [success: false, alertMsg: "新增信息验证失敗,请重新输入!${msg}"]
                    render jsonData as JSON
                    return
                } else {
                    jsonData = [success: false, alertMsg: '修改信息失败!${msg}']
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
            def user = User.get(params.id)
            if (user) {
                try {
                    UserRole.findAllByUser(user).each {
                        it.delete()
                    }
                    user.delete(flush: true)
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
            def user = User.get(params.id)
            if (!user) {
                jsonData = new JSONData(success: false)
                render jsonData as JSON
                return;
            } else {
                def dataInfo = [success: true, data: user, roles: user.authorities.collect {
                    [id: it.id, name: it.name]
                }]
                render dataInfo as JSON
                return
            }
        } catch (Exception e) {
            jsonData = new JSONData(success: false)
        }

    }

    /**
     * 导出
     */
    def export = {
        List<User> users = User.createCriteria().list(params, filter)
        def headers = ['id', 'actor', 'bookName']
        def withProperties = ['name', new MessageFromPropertyGetter(messageSource, 'type'), 'price.value']

        new WebXlsxExporter().with {
            setResponseHeaders(response)
            fillHeader(headers)
            add(users, withProperties)
            save(response.outputStream)
        }

    }

    /**
     * 查询封装
     * @param params
     * @return
     */
    def searchCondition(params) {
        def filter = {
            if (params?.username) {
                ilike("username", "%${params.username}%")
            }
            if (params?.realname) {
                ilike("realname", "%${params.realname}%")
            }

        }
        return filter
    }
}
