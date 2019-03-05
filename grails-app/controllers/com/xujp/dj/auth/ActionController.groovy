package com.xujp.dj.auth

import com.util.JSONData
import com.xujp.dj.auth.Action
import com.xujp.dj.auth.RequestMap
import grails.converters.JSON

class ActionController {
        static allowedMethods = [delete: "POST"]
        def exportService
        def messageSource
        def springSecurityService

        def index = {
            render(view: "/action/list", params: params)
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

            def data = Action.createCriteria().list(params, filter)
            def jsonData = new JSONData(data: data, totalCount: Action.createCriteria().count(filter))
            //println(jsonData as JSON)
            render jsonData as JSON
        }

        /**
         * 保存
         */
        def save = {
            def jsonData = [success: true]
            boolean isNew = (params?.id == null || params?.id == "")
            params?.isMenu = !params?.isMenu ? false:true
            try {
                def action

                if (isNew) {
                   action = new Action(params)
                } else {
                   action = Action.get(params.id)
                    if (!action) {
                        jsonData = [success: false]
                        render jsonData as JSON
                        return
                    }
                   action.properties = params
                }

                if (action.save(flush: true)) {
                    if (isNew){
                        //需要新增一个request map
                        RequestMap map = new RequestMap()
                        map.configAttribute = 'ROLE_SUPER_ADMIN'
                        map.action = action
                        map.url = '/'+action.controllerName +'/**'
                        map.save(flush: true)
                        springSecurityService.clearCachedRequestmaps();
                    }
                    render jsonData as JSON
                    return
                } else {
                    def msg =''
                    action.errors.allErrors.each{ error ->
                        msg += "<br/>"+messageSource.getMessage(error,Locale.default) +"!"
                    }
                    if (isNew) {
                        jsonData = [success: false, alertMsg:"新增信息验证失敗,请重新输入!${msg}"]
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
                def action = Action.get(params.id)

                if (action) {
                    try {
                        def rm = RequestMap.findByActionAndConfigAttribute(action,'ROLE_SUPER_ADMIN')
                        if (rm){
                            rm.delete()
                            springSecurityService.clearCachedRequestmaps();
                        }
                        action.delete(flush: true)
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
                def action = Action.get(params.id)
                if (!action) {
                    jsonData = new JSONData(success: false)
                    render jsonData as JSON
                    return;
                } else {
                    def dataInfo = [success: true, data:action]
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
//                projections { count('id') }
            }
            return filter
        }
}
