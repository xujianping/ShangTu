package com.xujp.dj.auth

import com.util.JSONData
import grails.converters.JSON

class RoleController {
        static allowedMethods = [delete: "POST"]
        def springSecurityService
        def messageSource

        def index = {
            render(view: "/role/list", params: params)
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
            def data = Role.createCriteria().list(params, filter)
            def jsonData = new JSONData(data: data, totalCount: Role.createCriteria().count(filter))

            //println(jsonData as JSON)
            render jsonData as JSON
        }

        /**
         * 保存
         */
        def save = {
            log.info(params)
            def jsonData = [success: true]
            boolean isNew = (params?.id == null || params?.id == "")
            try {
                def role

                if (isNew) {
                   role = new Role(params)
                } else {
                    role = Role.get(params.id)
                    if (!role) {
                        jsonData = [success: false]
                        render jsonData as JSON
                        return
                    }

                    if (role.authority == 'ROLE_SUPER_ADMIN'){
                        jsonData = [success: false, alertMsg: "超级管理员不能修改!"]
                        render jsonData as JSON
                        return
                    }

                    role.properties = params
                    if (!params.columns)
                        role.columns = ''
                }

                if (role.save(flush: true)) {
                    List actions = null
                    if (params["actions"] instanceof String)
                        actions = [params["actions"]]
                    else
                        actions = params["actions"] as List
                    String roleName = role.authority
                    boolean found = false
                    List requestmaps = RequestMap.findAll()
                    //修改
                    requestmaps.each{rm->
                        if (!rm.action) return
                        if (!rm.configAttribute) return

                        List parts = rm.configAttribute.split(',')
                        if (parts.remove(roleName)){
                            found = false
                            actions.each{
                                if(found)   return

                                if (rm.action.id == Long.parseLong(it)){
                                    found = true
                                }
                            }
                            if (!found){
                                rm.configAttribute = parts.join(',')
                                rm.save()
                            }
                        }
                    }

                    //新增
                    actions.each{
                        found = false
                        requestmaps.each{rm->
                            if (!rm.action) return
                            if (found)  return

                            if (rm.action.id == Long.parseLong(it)){
                                if (rm.configAttribute){
                                    List parts = rm.configAttribute.split(',')
                                    if(!parts.contains(roleName)){
                                       rm.configAttribute = rm.configAttribute + "," + roleName
                                       rm.save()
                                    }
                                }else{
                                    rm.configAttribute = roleName
                                    rm.save()
                                }
                                found = true
                                return
                            }
                        }

                        if (!found){
                            //需要新增一个request map
                            RequestMap map = new RequestMap()
                            map.configAttribute = 'ROLE_SUPER_ADMIN,'+roleName
                            def act = Action.findById(Long.parseLong(it))
                            map.action = act
                            map.url = '/'+act.controllerName +'/**'
                                
                            map.save(flush: true)
                        }
                    }

                    springSecurityService.clearCachedRequestmaps();
                    render jsonData as JSON
                    return
                } else {
                    def msg =''
                    role.errors.allErrors.each{ error ->
                        msg += "<br/>"+messageSource.getMessage(error,Locale.default) +"!"
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
                log.error(e.getMessage())
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
                def role = Role.get(params.id)

                if (role) {
                    if (role.authority == 'ROLE_SUPER_ADMIN'){
                        jsonData = [success: false, alertMsg: "超级管理员不能删除!"]
                        render jsonData as JSON
                        return
                    }
                    try {
                       def roleName = role.authority
                       role.delete(flush: true)
                        RequestMap.findAll().each{ rm->
                           if (!rm.configAttribute) return

                           List parts = rm.configAttribute.split(',')
                           if (parts.remove(roleName)){
                               rm.configAttribute = parts.join(',')
                               rm.save()
                           }
                       }
                       springSecurityService.clearCachedRequestmaps();
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
                def role = Role.get(params.id)
                if (!role) {
                    jsonData = new JSONData(success: false)
                    render jsonData as JSON
                    return;
                } else {
                    def dataInfo = [success: true, data:role]
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

        /**
         * 显示权限
         */
        def actions = {
            def role = params.role
            def result = Action.list([sort: 'id']).groupBy {it.groupName}.collect { group->
                [text: group.key, expanded: true, children: group.value.collect{item->
                    [id: item.id,
                            text: item.title,
                            leaf: true,
                            checked: (!role) ? false :(RequestMap.findByAction(item)?.configAttribute?.contains(role) ?: false)]
                }]
            }
            render result as JSON
        }
}
